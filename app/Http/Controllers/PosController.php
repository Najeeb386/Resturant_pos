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

        return Inertia::render('POS', [
            'categories' => $categories,
            'menuItems' => $menuItems,
            'tables' => $tables,
            'restaurant' => $restaurant,
        ]);
    }

    public function checkout(Request $request)
    {
        $request->validate([
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

        DB::beginTransaction();
        try {
            $restaurantId = auth()->user()->restaurant_id;

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

            // Update table status based on order type
            if ($request->table_id) {
                $table = Table::find($request->table_id);
                if ($request->order_type === 'dine_in') {
                    $table->update(['status' => 'occupied']);
                } else {
                    $table->update(['status' => 'cleaning']);
                }
            }

            DB::commit();

            return redirect()->back()->with([
                'message' => 'Payment completed successfully.',
                'order_id' => $order->id
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->withErrors(['error' => 'Failed to process checkout.']);
        }
    }

    /**
     * Save order as Draft (Open Bill) - especially useful for Dine In tables
     * Customer can add more items later before final checkout.
     */
    public function saveDraft(Request $request)
    {
        $request->validate([
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

        DB::beginTransaction();
        try {
            $restaurantId = auth()->user()->restaurant_id;

            // For Dine In, try to find existing open draft order on the same table
            $existingOrder = null;
            if ($request->order_type === 'dine_in' && $request->table_id) {
                $existingOrder = Order::where('restaurant_id', $restaurantId)
                    ->where('table_id', $request->table_id)
                    ->whereIn('status', ['draft', 'pending'])
                    ->latest()
                    ->first();
            }

            if ($existingOrder) {
                // Append items to existing open order
                foreach ($request->cart as $item) {
                    // Check if item already exists in order
                    $existingItem = OrderItem::where('order_id', $existingOrder->id)
                        ->where('menu_item_id', $item['id'])
                        ->first();

                    if ($existingItem) {
                        $existingItem->increment('quantity', $item['qty']);
                    } else {
                        OrderItem::create([
                            'order_id' => $existingOrder->id,
                            'menu_item_id' => $item['id'],
                            'quantity' => $item['qty'],
                            'price' => $item['price'],
                        ]);
                    }

                    // Deduct stock
                    $menuItem = MenuItem::find($item['id']);
                    if ($menuItem && $menuItem->stock_quantity > 0) {
                        $decrementAmount = min($item['qty'], $menuItem->stock_quantity);
                        $menuItem->decrement('stock_quantity', $decrementAmount);
                    }
                }

                // Update totals on existing order
                $existingOrder->subtotal += $request->subtotal;
                $existingOrder->tax += $request->tax;
                $existingOrder->total += $request->total;
                $existingOrder->save();

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
            }

            // Mark table as occupied if dine in
            if ($request->table_id && $request->order_type === 'dine_in') {
                Table::find($request->table_id)->update(['status' => 'occupied']);
            }

            DB::commit();

            return redirect()->back()->with('message', 'Order saved as draft successfully.');

        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->withErrors(['error' => 'Failed to save draft order.']);
        }
    }
}
