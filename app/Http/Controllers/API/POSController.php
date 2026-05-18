<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class POSController extends Controller
{
    public function createOrder(Request $request)
    {
        $request->validate([
            'restaurant_id' => 'required|exists:restaurants,id',
            'table_id' => 'nullable|exists:tables,id',
            'order_type' => 'required|in:dine_in,takeaway,delivery',
            'items' => 'required|array',
            'items.*.menu_item_id' => 'required|exists:menu_items,id',
            'items.*.quantity' => 'required|integer|min:1',
            'notes' => 'nullable|string',
        ]);

        $restaurant = \App\Models\Restaurant::find($request->restaurant_id);
        $subtotal = 0;
        $orderItems = [];

        foreach ($request->items as $item) {
            $menuItem = \App\Models\MenuItem::find($item['menu_item_id']);
            $price = $menuItem->price;
            $subtotal += $price * $item['quantity'];
            $orderItems[] = [
                'menu_item_id' => $item['menu_item_id'],
                'quantity' => $item['quantity'],
                'price' => $price,
            ];
        }

        $tax = $subtotal * 0.18; // 18% GST
        $total = $subtotal + $tax;

        $order = \App\Models\Order::create([
            'restaurant_id' => $request->restaurant_id,
            'table_id' => $request->table_id,
            'user_id' => auth()->id(),
            'order_type' => $request->order_type,
            'status' => 'pending',
            'subtotal' => $subtotal,
            'tax' => $tax,
            'total' => $total,
            'notes' => $request->notes,
        ]);

        foreach ($orderItems as $item) {
            $order->orderItems()->create($item);
        }

        return response()->json($order->load('orderItems.menuItem'));
    }

    public function getOrders(Request $request)
    {
        $orders = \App\Models\Order::where('restaurant_id', $request->restaurant_id)
            ->with('orderItems.menuItem', 'table', 'user')
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json($orders);
    }

    public function updateOrderStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,confirmed,preparing,ready,served,completed,cancelled',
        ]);

        $order = \App\Models\Order::findOrFail($id);
        $order->update(['status' => $request->status]);

        return response()->json($order);
    }
}
