<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\Request;
use Inertia\Inertia;

class KitchenController extends Controller
{
    public function index()
    {
        $restaurantId = auth()->user()->restaurant_id;

        // Fetch draft, pending, and preparing orders. Place is_updated = true at the very top!
        $orders = Order::with(['orderItems.menuItem', 'table'])
            ->where('restaurant_id', $restaurantId)
            ->whereIn('status', ['draft', 'pending', 'preparing'])
            ->orderBy('is_updated', 'desc')
            ->orderBy('updated_at', 'desc')
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($order) {
                return [
                    'id' => $order->id,
                    'table' => $order->table ? 'Table ' . $order->table->table_number : ($order->order_type === 'delivery' ? 'Delivery' : 'Takeaway'),
                    'status' => $order->status,
                    'is_updated' => (bool) $order->is_updated,
                    'time' => $order->updated_at->format('H:i'),
                    'items' => $order->orderItems->map(function ($item) {
                        return [
                            'id' => $item->id,
                            'name' => $item->menuItem ? $item->menuItem->name : 'Unknown Item',
                            'qty' => $item->quantity,
                            'is_new' => (bool) $item->is_new,
                        ];
                    }),
                ];
            });

        return Inertia::render('Kitchen', [
            'orders' => $orders
        ]);
    }

    public function liveOrders()
    {
        $restaurantId = auth()->user()->restaurant_id;

        $orders = Order::with(['orderItems.menuItem', 'table'])
            ->where('restaurant_id', $restaurantId)
            ->whereIn('status', ['draft', 'pending', 'preparing'])
            ->orderBy('is_updated', 'desc')
            ->orderBy('updated_at', 'desc')
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($order) {
                return [
                    'id' => $order->id,
                    'table' => $order->table ? 'Table ' . $order->table->table_number : ($order->order_type === 'delivery' ? 'Delivery' : 'Takeaway'),
                    'status' => $order->status,
                    'is_updated' => (bool) $order->is_updated,
                    'time' => $order->updated_at->format('H:i'),
                    'items' => $order->orderItems->map(function ($item) {
                        return [
                            'id' => $item->id,
                            'name' => $item->menuItem ? $item->menuItem->name : 'Unknown Item',
                            'qty' => $item->quantity,
                            'is_new' => (bool) $item->is_new,
                        ];
                    }),
                ];
            });

        return response()->json([
            'orders' => $orders,
            'count' => $orders->count()
        ]);
    }

    public function updateStatus(Request $request, Order $order)
    {
        if ($order->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $request->validate([
            'status' => 'required|in:draft,pending,preparing,completed'
        ]);

        $order->update(['status' => $request->status]);

        return back();
    }

    public function confirmUpdate(Request $request, Order $order)
    {
        if ($order->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $order->update(['is_updated' => false]);
        $order->orderItems()->update(['is_new' => false]);

        return back();
    }
}
