<?php

namespace App\Http\Controllers;

use App\Models\MenuCategory;
use App\Models\MenuItem;
use App\Models\Table;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\DB;

class PosController extends Controller
{
    public function index()
    {
        $restaurantId = auth()->user()->restaurant_id;
        $restaurant = auth()->user()->restaurant;
        
        $categories = MenuCategory::where('restaurant_id', $restaurantId)->get();
        $menuItems = MenuItem::where('restaurant_id', $restaurantId)->get();
        $tables = Table::where('restaurant_id', $restaurantId)->get();

        // Open running bills per table (where unpaid and not completed)
        $openBills = Order::where('restaurant_id', $restaurantId)
            ->where('payment_status', 'unpaid')
            ->whereIn('status', ['draft', 'pending', 'preparing'])
            ->whereNotNull('table_id')
            ->with('orderItems.menuItem')
            ->latest()
            ->get()
            ->groupBy('table_id')
            ->map(function ($orders) {
                $order = $orders->first();
                return [
                    'order_id' => $order->id,
                    'customer_name' => $order->customer_name,
                    'items' => $order->orderItems->map(fn($item) => [
                        'id' => $item->menu_item_id,
                        'name' => $item->menuItem?->name ?? 'Item',
                        'price' => (float) $item->price,
                        'qty' => $item->quantity,
                    ])->toArray(),
                    'subtotal' => (float) $order->subtotal,
                    'tax' => (float) $order->tax,
                    'total' => (float) $order->total,
                ];
            });

        // All drafts/open bills for modal
        $allDrafts = Order::where('restaurant_id', $restaurantId)
            ->where('payment_status', 'unpaid')
            ->whereIn('status', ['draft', 'pending', 'preparing'])
            ->with(['orderItems.menuItem', 'table'])
            ->latest()
            ->get()
            ->map(function ($order) {
                return [
                    'id' => $order->id,
                    'table_id' => $order->table_id,
                    'table_number' => $order->table ? $order->table->table_number : null,
                    'order_type' => $order->order_type,
                    'customer_name' => $order->customer_name,
                    'customer_phone' => $order->customer_phone,
                    'delivery_address' => $order->delivery_address,
                    'delivery_fee' => (float) $order->delivery_fee,
                    'items' => $order->orderItems->map(fn($item) => [
                        'id' => $item->menu_item_id,
                        'name' => $item->menuItem?->name ?? 'Item',
                        'price' => (float) $item->price,
                        'qty' => $item->quantity,
                    ])->toArray(),
                    'subtotal' => (float) $order->subtotal,
                    'tax' => (float) $order->tax,
                    'total' => (float) $order->total,
                    'created_at' => $order->created_at->format('Y-m-d h:i A'),
                ];
            });

        return Inertia::render('POS', [
            'categories' => $categories,
            'menuItems' => $menuItems,
            'tables' => $tables,
            'restaurant' => $restaurant,
            'openBills' => $openBills,
            'allDrafts' => $allDrafts,
            'flash' => [
                'message' => session('message'),
                'order_id' => session('order_id')
            ],
        ]);
    }

    public function checkout(Request $request)
    {
        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
            'order_id' => 'nullable|exists:orders,id',
            'table_id' => 'nullable|exists:tables,id',
            'order_type' => 'required|in:takeaway,dine_in,delivery',
            'customer_name' => 'nullable|string|max:255',
            'customer_phone' => 'nullable|required_if:order_type,delivery|string|max:20',
            'delivery_address' => 'nullable|required_if:order_type,delivery|string',
            'delivery_fee' => 'nullable|numeric',
            'cart' => 'required|array|min:1',
            'cart.*.id' => 'required|exists:menu_items,id',
            'cart.*.qty' => 'required|integer|min:1',
            'cart.*.price' => 'required|numeric',
            'subtotal' => 'required|numeric',
            'tax' => 'required|numeric',
            'total' => 'required|numeric',
            'payment_method' => 'required|string',
        ]);

        if ($validator->fails()) {
            \Log::error('Checkout Validation Failed: ' . json_encode($validator->errors()));
            return redirect()->back()->withErrors($validator->errors());
        }

        DB::beginTransaction();
        try {
            $restaurantId = auth()->user()->restaurant_id;

            $cartItemIds = collect($request->cart)->pluck('id')->toArray();
            $menuItemsMap = MenuItem::with(['ingredients', 'dealItems.ingredients'])
                ->whereIn('id', $cartItemIds)
                ->get()
                ->keyBy('id');

            $restaurant = auth()->user()->restaurant;
            $kitchenBypass = (bool) ($restaurant->kitchen_bypass ?? false);
            $targetStatus = $kitchenBypass ? 'completed' : 'pending';

            $order = null;
            if ($request->order_id) {
                $order = Order::where('restaurant_id', $restaurantId)->with('orderItems')->find($request->order_id);
            }

            if ($order) {
                $existingItemIds = $order->orderItems->pluck('menu_item_id')->toArray();
                $existingMenuItemsMap = MenuItem::with(['ingredients', 'dealItems.ingredients'])
                    ->whereIn('id', $existingItemIds)
                    ->get()
                    ->keyBy('id');

                foreach ($order->orderItems as $existingItem) {
                    $menuItem = $existingMenuItemsMap->get($existingItem->menu_item_id);
                    if ($menuItem) {
                        $menuItem->increment('stock_quantity', $existingItem->quantity);
                        
                        foreach ($menuItem->ingredients as $ingredient) {
                            $ingredient->increment('quantity', $ingredient->pivot->quantity * $existingItem->quantity);
                        }

                        if ($menuItem->is_deal && $menuItem->dealItems) {
                            foreach ($menuItem->dealItems as $dealItem) {
                                $dealItem->increment('stock_quantity', $dealItem->pivot->quantity * $existingItem->quantity);
                                foreach ($dealItem->ingredients as $ingredient) {
                                    $ingredient->increment('quantity', $ingredient->pivot->quantity * $dealItem->pivot->quantity * $existingItem->quantity);
                                }
                            }
                        }
                    }
                }
                OrderItem::where('order_id', $order->id)->delete();

                $order->update([
                    'table_id' => $request->table_id,
                    'order_type' => $request->order_type ?? ($request->table_id ? 'dine_in' : 'takeaway'),
                    'customer_name' => $request->customer_name,
                    'customer_phone' => $request->customer_phone,
                    'delivery_address' => $request->delivery_address,
                    'delivery_fee' => $request->delivery_fee ?? 0,
                    'payment_status' => $request->payment_method === 'Cash on Delivery' ? 'unpaid' : 'paid',
                    'status' => $targetStatus,
                    'subtotal' => $request->subtotal,
                    'tax' => $request->tax,
                    'total' => $request->total,
                    'notes' => 'Payment via ' . $request->payment_method,
                ]);
            } else {
                $order = Order::create([
                    'restaurant_id' => $restaurantId,
                    'table_id' => $request->table_id,
                    'user_id' => auth()->id(),
                    'order_type' => $request->order_type ?? ($request->table_id ? 'dine_in' : 'takeaway'),
                    'customer_name' => $request->customer_name,
                    'customer_phone' => $request->customer_phone,
                    'delivery_address' => $request->delivery_address,
                    'delivery_fee' => $request->delivery_fee ?? 0,
                    'payment_status' => $request->payment_method === 'Cash on Delivery' ? 'unpaid' : 'paid',
                    'status' => $targetStatus,
                    'subtotal' => $request->subtotal,
                    'tax' => $request->tax,
                    'discount' => 0,
                    'total' => $request->total,
                    'notes' => 'Payment via ' . $request->payment_method,
                ]);
            }

            $orderItemsToInsert = [];
            foreach ($request->cart as $item) {
                $menuItem = $menuItemsMap->get($item['id']);

                $orderItemsToInsert[] = [
                    'order_id' => $order->id,
                    'menu_item_id' => $item['id'],
                    'quantity' => $item['qty'],
                    'price' => $item['price'],
                    'cost_price' => $menuItem ? $menuItem->cost_price : 0,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];

                if ($menuItem && $menuItem->stock_quantity > 0) {
                    $decrementAmount = min($item['qty'], $menuItem->stock_quantity);
                    $menuItem->decrement('stock_quantity', $decrementAmount);
                }

                if ($menuItem && $menuItem->ingredients) {
                    foreach ($menuItem->ingredients as $ingredient) {
                        $qtyToDeduct = $ingredient->pivot->quantity * $item['qty'];
                        $ingredient->decrement('quantity', $qtyToDeduct);
                    }
                }

                if ($menuItem && $menuItem->is_deal && $menuItem->dealItems) {
                    foreach ($menuItem->dealItems as $dealItem) {
                        $qtyToDeduct = $dealItem->pivot->quantity * $item['qty'];
                        if ($dealItem->stock_quantity > 0) {
                            $decrementAmount = min($qtyToDeduct, $dealItem->stock_quantity);
                            $dealItem->decrement('stock_quantity', $decrementAmount);
                        }
                        foreach ($dealItem->ingredients as $ingredient) {
                            $ingQtyToDeduct = $ingredient->pivot->quantity * $qtyToDeduct;
                            $ingredient->decrement('quantity', $ingQtyToDeduct);
                        }
                    }
                }
            }

            OrderItem::insert($orderItemsToInsert);

            if ($request->table_id) {
                Table::where('id', $request->table_id)->update(['status' => 'available']);
            }

            DB::commit();

            return redirect()->back()->with([
                'message' => 'Payment completed successfully.',
                'order_id' => $order->id
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Checkout Error: ' . $e->getMessage());
            return redirect()->back()->withErrors(['error' => 'Failed to process checkout.']);
        }
    }

    public function saveDraft(Request $request)
    {
        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
            'order_id' => 'nullable|exists:orders,id',
            'table_id' => 'nullable|exists:tables,id',
            'order_type' => 'required|in:takeaway,dine_in,delivery',
            'customer_name' => 'nullable|string|max:255',
            'customer_phone' => 'nullable|string|max:20',
            'delivery_address' => 'nullable|string',
            'delivery_fee' => 'nullable|numeric',
            'cart' => 'required|array|min:1',
            'cart.*.id' => 'required|exists:menu_items,id',
            'cart.*.qty' => 'required|integer|min:1',
            'cart.*.price' => 'required|numeric',
            'subtotal' => 'required|numeric',
            'tax' => 'required|numeric',
            'total' => 'required|numeric',
        ]);

        if ($validator->fails()) {
            \Log::error('Draft Validation Failed: ' . json_encode($validator->errors()));
            return redirect()->back()->withErrors($validator->errors());
        }

        DB::beginTransaction();
        try {
            $restaurantId = auth()->user()->restaurant_id;

            $cartItemIds = collect($request->cart)->pluck('id')->toArray();
            $menuItemsMap = MenuItem::with(['ingredients', 'dealItems.ingredients'])
                ->whereIn('id', $cartItemIds)
                ->get()
                ->keyBy('id');

            $existingOrder = null;
            if ($request->order_id) {
                $existingOrder = Order::where('restaurant_id', $restaurantId)->with('orderItems')->find($request->order_id);
            } elseif ($request->order_type === 'dine_in' && $request->table_id) {
                $existingOrder = Order::where('restaurant_id', $restaurantId)
                    ->where('table_id', $request->table_id)
                    ->where('payment_status', 'unpaid')
                    ->latest()
                    ->first();
            }

            $previousItemQuantities = [];
            if ($existingOrder) {
                foreach ($existingOrder->orderItems as $existingItem) {
                    $previousItemQuantities[$existingItem->menu_item_id] = $existingItem->quantity;
                }

                $existingItemIds = $existingOrder->orderItems->pluck('menu_item_id')->toArray();
                $existingMenuItemsMap = MenuItem::with(['ingredients', 'dealItems.ingredients'])
                    ->whereIn('id', $existingItemIds)
                    ->get()
                    ->keyBy('id');

                foreach ($existingOrder->orderItems as $existingItem) {
                    $menuItem = $existingMenuItemsMap->get($existingItem->menu_item_id);
                    if ($menuItem) {
                        $menuItem->increment('stock_quantity', $existingItem->quantity);

                        foreach ($menuItem->ingredients as $ingredient) {
                            $ingredient->increment('quantity', $ingredient->pivot->quantity * $existingItem->quantity);
                        }

                        if ($menuItem->is_deal && $menuItem->dealItems) {
                            foreach ($menuItem->dealItems as $dealItem) {
                                $dealItem->increment('stock_quantity', $dealItem->pivot->quantity * $existingItem->quantity);
                                foreach ($dealItem->ingredients as $ingredient) {
                                    $ingredient->increment('quantity', $ingredient->pivot->quantity * $dealItem->pivot->quantity * $existingItem->quantity);
                                }
                            }
                        }
                    }
                }
                OrderItem::where('order_id', $existingOrder->id)->delete();

                $existingOrder->update([
                    'table_id' => $request->table_id,
                    'order_type' => $request->order_type,
                    'customer_name' => $request->customer_name,
                    'customer_phone' => $request->customer_phone,
                    'delivery_address' => $request->delivery_address,
                    'delivery_fee' => $request->delivery_fee ?? 0,
                    'payment_status' => 'unpaid',
                    'status' => 'draft',
                    'subtotal' => $request->subtotal,
                    'tax' => $request->tax,
                    'total' => $request->total,
                    'is_updated' => true,
                    'updated_at' => now(),
                ]);

                $order = $existingOrder;
            } else {
                $order = Order::create([
                    'restaurant_id' => $restaurantId,
                    'table_id' => $request->table_id,
                    'user_id' => auth()->id(),
                    'order_type' => $request->order_type,
                    'customer_name' => $request->customer_name,
                    'customer_phone' => $request->customer_phone,
                    'delivery_address' => $request->delivery_address,
                    'delivery_fee' => $request->delivery_fee ?? 0,
                    'payment_status' => 'unpaid',
                    'status' => 'draft',
                    'subtotal' => $request->subtotal,
                    'tax' => $request->tax,
                    'discount' => 0,
                    'total' => $request->total,
                    'notes' => 'Draft Order - Open Bill',
                ]);
            }

            $orderItemsToInsert = [];
            foreach ($request->cart as $item) {
                $menuItem = $menuItemsMap->get($item['id']);
                $prevQty = $previousItemQuantities[$item['id']] ?? 0;
                $isNewItem = $existingOrder ? ($item['qty'] > $prevQty) : false;

                $orderItemsToInsert[] = [
                    'order_id' => $order->id,
                    'menu_item_id' => $item['id'],
                    'quantity' => $item['qty'],
                    'is_new' => $isNewItem,
                    'price' => $item['price'],
                    'cost_price' => $menuItem ? $menuItem->cost_price : 0,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];

                if ($menuItem && $menuItem->stock_quantity > 0) {
                    $decrementAmount = min($item['qty'], $menuItem->stock_quantity);
                    $menuItem->decrement('stock_quantity', $decrementAmount);
                }

                if ($menuItem && $menuItem->ingredients) {
                    foreach ($menuItem->ingredients as $ingredient) {
                        $qtyToDeduct = $ingredient->pivot->quantity * $item['qty'];
                        $ingredient->decrement('quantity', $qtyToDeduct);
                    }
                }

                if ($menuItem && $menuItem->is_deal && $menuItem->dealItems) {
                    foreach ($menuItem->dealItems as $dealItem) {
                        $qtyToDeduct = $dealItem->pivot->quantity * $item['qty'];
                        if ($dealItem->stock_quantity > 0) {
                            $decrementAmount = min($qtyToDeduct, $dealItem->stock_quantity);
                            $dealItem->decrement('stock_quantity', $decrementAmount);
                        }
                        foreach ($dealItem->ingredients as $ingredient) {
                            $ingQtyToDeduct = $ingredient->pivot->quantity * $qtyToDeduct;
                            $ingredient->decrement('quantity', $ingQtyToDeduct);
                        }
                    }
                }
            }

            OrderItem::insert($orderItemsToInsert);

            if ($request->table_id && $request->order_type === 'dine_in') {
                Table::where('id', $request->table_id)->update(['status' => 'occupied']);
            }

            DB::commit();

            return redirect()->back()->with([
                'message' => 'Order saved as draft successfully.',
                'order_id' => $order->id
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Draft Error: ' . $e->getMessage());
            return redirect()->back()->withErrors(['error' => 'Failed to save draft order.']);
        }
    }
}
