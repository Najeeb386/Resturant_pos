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

        // Open draft bills per table (for "continue order" feature)
        $openBills = Order::where('restaurant_id', $restaurantId)
            ->where('status', 'draft')
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

        // Add all drafts for the new modal
        $allDrafts = Order::where('restaurant_id', $restaurantId)
            ->where('status', 'draft')
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
        ]);
    }

    public function checkout(Request $request)
    {
        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
            'order_id' => 'nullable|exists:orders,id',
            'table_id' => 'nullable|exists:tables,id',
            'order_type' => 'required|in:takeaway,dine_in,delivery',
            'customer_name' => 'nullable|string|max:255',
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

            $order = null;
            if ($request->order_id) {
                $order = Order::where('restaurant_id', $restaurantId)->with('orderItems')->find($request->order_id);
            }

            if ($order) {
                // Restore stock for existing items before deleting them
                foreach ($order->orderItems as $existingItem) {
                    $menuItem = MenuItem::find($existingItem->menu_item_id);
                    if ($menuItem) {
                        $menuItem->increment('stock_quantity', $existingItem->quantity);
                    }
                }
                OrderItem::where('order_id', $order->id)->delete();

                $order->update([
                    'table_id' => $request->table_id,
                    'order_type' => $request->order_type ?? ($request->table_id ? 'dine_in' : 'takeaway'),
                    'customer_name' => $request->customer_name,
                    'status' => 'pending',
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
                    'status' => 'pending',
                    'subtotal' => $request->subtotal,
                    'tax' => $request->tax,
                    'discount' => 0,
                    'total' => $request->total,
                    'notes' => 'Payment via ' . $request->payment_method,
                ]);
            }

            foreach ($request->cart as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'menu_item_id' => $item['id'],
                    'quantity' => $item['qty'],
                    'price' => $item['price'],
                ]);

                // Decrease stock quantity
                $menuItem = MenuItem::find($item['id']);
                if ($menuItem && $menuItem->stock_quantity > 0) {
                    // Prevent negative stock
                    $decrementAmount = min($item['qty'], $menuItem->stock_quantity);
                    $menuItem->decrement('stock_quantity', $decrementAmount);
                }
            }

            // After final payment, free the table (or mark for cleaning)
            if ($request->table_id) {
                $table = Table::find($request->table_id);
                $table->update(['status' => 'available']);   // Table is now free
            }

            DB::commit();

            return redirect()->back()->with([
                'message' => 'Payment completed successfully.',
                'order_id' => $order->id
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Checkout Error: ' . $e->getMessage());
            \Log::error($e->getTraceAsString());
            return redirect()->back()->withErrors(['error' => 'Failed to process checkout.']);
        }
    }

    /**
     * Save order as Draft (Open Bill) - especially useful for Dine In tables
     * Customer can add more items later before final checkout.
     */
    public function saveDraft(Request $request)
    {
        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
            'order_id' => 'nullable|exists:orders,id',
            'table_id' => 'nullable|exists:tables,id',
            'order_type' => 'required|in:takeaway,dine_in,delivery',
            'customer_name' => 'nullable|string|max:255',
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

            $existingOrder = null;
            if ($request->order_id) {
                $existingOrder = Order::where('restaurant_id', $restaurantId)->with('orderItems')->find($request->order_id);
            } elseif ($request->order_type === 'dine_in' && $request->table_id) {
                $existingOrder = Order::where('restaurant_id', $restaurantId)
                    ->where('table_id', $request->table_id)
                    ->whereIn('status', ['draft', 'pending'])
                    ->latest()
                    ->first();
            }

            if ($existingOrder) {
                // Restore stock for existing items before deleting them
                foreach ($existingOrder->orderItems as $existingItem) {
                    $menuItem = MenuItem::find($existingItem->menu_item_id);
                    if ($menuItem) {
                        $menuItem->increment('stock_quantity', $existingItem->quantity);
                    }
                }
                OrderItem::where('order_id', $existingOrder->id)->delete();

                // Update totals on existing order
                $existingOrder->update([
                    'table_id' => $request->table_id,
                    'order_type' => $request->order_type,
                    'customer_name' => $request->customer_name,
                    'subtotal' => $request->subtotal,
                    'tax' => $request->tax,
                    'total' => $request->total,
                ]);

                $order = $existingOrder;
            } else {
                // Create new draft order
                $order = Order::create([
                    'restaurant_id' => $restaurantId,
                    'table_id' => $request->table_id,
                    'user_id' => auth()->id(),
                    'order_type' => $request->order_type,
                    'customer_name' => $request->customer_name,
                    'status' => 'draft',
                    'subtotal' => $request->subtotal,
                    'tax' => $request->tax,
                    'discount' => 0,
                    'total' => $request->total,
                    'notes' => 'Draft Order - Open Bill',
                ]);
            }

            foreach ($request->cart as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'menu_item_id' => $item['id'],
                    'quantity' => $item['qty'],
                    'price' => $item['price'],
                ]);

                // Deduct stock
                $menuItem = MenuItem::find($item['id']);
                if ($menuItem && $menuItem->stock_quantity > 0) {
                    $decrementAmount = min($item['qty'], $menuItem->stock_quantity);
                    $menuItem->decrement('stock_quantity', $decrementAmount);
                }
            }

            // Mark table as occupied if dine in
            if ($request->table_id && $request->order_type === 'dine_in') {
                Table::find($request->table_id)->update(['status' => 'occupied']);
            }

            DB::commit();

            return redirect()->back()->with('message', 'Order saved as draft successfully.');

        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Draft Error: ' . $e->getMessage());
            \Log::error($e->getTraceAsString());
            return redirect()->back()->withErrors(['error' => 'Failed to save draft order.']);
        }
    }
}
