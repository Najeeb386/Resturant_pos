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
                'order_type' => $request->table_id ? 'dine_in' : 'takeaway',
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

            if ($request->table_id) {
                $table = Table::find($request->table_id);
                $table->update(['status' => 'cleaning']);
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
}
