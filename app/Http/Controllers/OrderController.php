<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\MenuItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class OrderController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $restaurantId = auth()->user()->restaurant_id;

        $orders = Order::with(['orderItems.menuItem', 'table'])
            ->where('restaurant_id', $restaurantId)
            ->where('status', '!=', 'draft')
            ->orderBy('created_at', 'desc')
            ->paginate(50)
            ->through(function ($order) {
                return [
                    'id' => $order->id,
                    'table_number' => $order->table ? $order->table->table_number : null,
                    'order_type' => $order->order_type,
                    'customer_name' => $order->customer_name,
                    'customer_phone' => $order->customer_phone,
                    'delivery_address' => $order->delivery_address,
                    'status' => $order->status,
                    'payment_status' => $order->payment_status,
                    'subtotal' => (float) $order->subtotal,
                    'tax' => (float) $order->tax,
                    'discount' => (float) $order->discount,
                    'delivery_fee' => (float) $order->delivery_fee,
                    'total' => (float) $order->total,
                    'notes' => $order->notes,
                    'created_at' => $order->created_at->format('M d, Y h:i A'),
                    'items' => $order->orderItems->map(fn($item) => [
                        'menu_item_id' => $item->menu_item_id,
                        'name' => $item->menuItem?->name ?? 'Item',
                        'qty' => $item->quantity,
                        'price' => (float) $item->price
                    ]),
                ];
            });

        $menuItems = MenuItem::where('restaurant_id', $restaurantId)
            ->where('available', true)
            ->select('id', 'name', 'price')
            ->get();

        $restaurant = auth()->user()->restaurant;

        return Inertia::render('Orders', [
            'orders' => $orders,
            'menu_items' => $menuItems,
            'tax_percentage' => (float) ($restaurant->tax_percentage ?? 0),
            'kitchen_bypass' => (bool) ($restaurant->kitchen_bypass ?? false),
            'currency_symbol' => $restaurant->currency_symbol ?? '$'
        ]);
    }

    /**
     * Update the order details (status, payment_status, customer details, items, notes).
     */
    public function update(Request $request, Order $order)
    {
        if ($order->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $validated = $request->validate([
            'customer_name' => 'nullable|string|max:255',
            'customer_phone' => 'nullable|string|max:50',
            'delivery_address' => 'nullable|string',
            'status' => 'required|in:pending,preparing,completed,cancelled',
            'payment_status' => 'required|in:paid,unpaid',
            'notes' => 'nullable|string',
            'items' => 'nullable|array',
            'items.*.menu_item_id' => 'required_with:items|exists:menu_items,id',
            'items.*.qty' => 'required_with:items|integer|min:1',
            'items.*.price' => 'required_with:items|numeric|min:0',
        ]);

        DB::beginTransaction();
        try {
            if ($request->has('items') && is_array($request->items)) {
                // Restore stock & ingredients for existing items before updating
                $order->load(['orderItems.menuItem.ingredients', 'orderItems.menuItem.dealItems.ingredients']);
                foreach ($order->orderItems as $existingItem) {
                    $menuItem = $existingItem->menuItem;
                    if ($menuItem) {
                        if ($menuItem->stock_quantity >= 0) {
                            $menuItem->increment('stock_quantity', $existingItem->quantity);
                        }
                        foreach ($menuItem->ingredients as $ingredient) {
                            $ingredient->increment('quantity', $ingredient->pivot->quantity * $existingItem->quantity);
                        }
                        if ($menuItem->is_deal && $menuItem->dealItems) {
                            foreach ($menuItem->dealItems as $dealItem) {
                                if ($dealItem->stock_quantity >= 0) {
                                    $dealItem->increment('stock_quantity', $dealItem->pivot->quantity * $existingItem->quantity);
                                }
                                foreach ($dealItem->ingredients as $ingredient) {
                                    $ingredient->increment('quantity', $ingredient->pivot->quantity * $dealItem->pivot->quantity * $existingItem->quantity);
                                }
                            }
                        }
                    }
                }

                // Delete old order items
                $order->orderItems()->delete();

                // Re-create new order items & recalculate subtotal
                $subtotal = 0;
                $orderItemsToInsert = [];
                $cartItemIds = collect($request->items)->pluck('menu_item_id')->toArray();
                $menuItemsMap = MenuItem::with(['ingredients', 'dealItems.ingredients'])
                    ->whereIn('id', $cartItemIds)
                    ->get()
                    ->keyBy('id');

                foreach ($request->items as $item) {
                    $menuItem = $menuItemsMap->get($item['menu_item_id']);
                    $itemSubtotal = $item['qty'] * $item['price'];
                    $subtotal += $itemSubtotal;

                    $orderItemsToInsert[] = [
                        'order_id' => $order->id,
                        'menu_item_id' => $item['menu_item_id'],
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

                if (!empty($orderItemsToInsert)) {
                    OrderItem::insert($orderItemsToInsert);
                }

                $restaurant = auth()->user()->restaurant;
                $taxPercentage = (float) ($restaurant->tax_percentage ?? 0);
                $tax = ($subtotal * $taxPercentage) / 100;
                $deliveryFee = (float) $order->delivery_fee;
                $discount = (float) $order->discount;
                $total = max(0, $subtotal + $tax + $deliveryFee - $discount);

                $order->subtotal = $subtotal;
                $order->tax = $tax;
                $order->total = $total;
                $order->is_updated = true;
            }

            $order->customer_name = $validated['customer_name'];
            $order->customer_phone = $validated['customer_phone'];
            $order->delivery_address = $validated['delivery_address'];
            $order->status = $validated['status'];
            $order->payment_status = $validated['payment_status'];
            $order->notes = $validated['notes'];
            $order->save();

            if ($validated['status'] === 'cancelled' || $validated['status'] === 'completed') {
                if ($order->table) {
                    $order->table->update(['status' => 'available']);
                }
            }

            DB::commit();
            return redirect()->back()->with('message', 'Order updated successfully.');
        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Order Update Error: ' . $e->getMessage());
            return redirect()->back()->withErrors(['error' => 'Failed to update order details.']);
        }
    }

    /**
     * Update the payment status of the order.
     */
    public function updatePaymentStatus(Request $request, Order $order)
    {
        if ($order->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $request->validate([
            'payment_status' => 'required|in:paid,unpaid'
        ]);

        $order->update([
            'payment_status' => $request->payment_status
        ]);

        return redirect()->back()->with('message', 'Payment status updated successfully.');
    }

    /**
     * Update the overall status of the order (e.g., cancelled).
     */
    public function updateStatus(Request $request, Order $order)
    {
        if ($order->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $request->validate([
            'status' => 'required|in:pending,preparing,completed,cancelled'
        ]);

        $order->update([
            'status' => $request->status
        ]);

        if ($request->status === 'cancelled' || $request->status === 'completed') {
            if ($order->table) {
                $order->table->update(['status' => 'available']);
            }
        }

        return redirect()->back()->with('message', 'Order status updated successfully.');
    }

    public function printReceipt(Order $order)
    {
        if ($order->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $order->load(['orderItems.menuItem', 'table']);
        $restaurant = auth()->user()->restaurant;

        return view('print.receipt', [
            'order' => $order,
            'restaurant' => $restaurant
        ]);
    }

    public function printKOT(Order $order)
    {
        if ($order->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $order->load(['orderItems.menuItem', 'table']);
        $restaurant = auth()->user()->restaurant;

        return view('print.kot', [
            'order' => $order,
            'restaurant' => $restaurant
        ]);
    }

    public function printBoth(Order $order)
    {
        if ($order->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $order->load(['orderItems.menuItem', 'table']);
        $restaurant = auth()->user()->restaurant;

        return view('print.both', [
            'order' => $order,
            'restaurant' => $restaurant
        ]);
    }
}
