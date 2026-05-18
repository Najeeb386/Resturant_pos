<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class KitchenController extends Controller
{
    public function getOrders(Request $request)
    {
        $orders = \App\Models\Order::where('restaurant_id', $request->restaurant_id)
            ->whereIn('status', ['pending', 'confirmed', 'preparing', 'ready'])
            ->with('orderItems.menuItem', 'table')
            ->orderBy('created_at')
            ->get();

        return response()->json($orders);
    }

    public function updateOrderItemStatus(Request $request, $orderId, $itemId)
    {
        $orderItem = \App\Models\OrderItem::where('order_id', $orderId)
            ->where('id', $itemId)
            ->firstOrFail();

        // For simplicity, assume status is ready when updated
        // In real, might have status for each item

        return response()->json($orderItem);
    }
}
