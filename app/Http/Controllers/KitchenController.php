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

        $orders = Order::with(['items.menuItem', 'table'])
            ->where('restaurant_id', $restaurantId)
            ->whereIn('status', ['pending', 'preparing'])
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($order) {
                return [
                    'id' => $order->id,
                    'table' => $order->table ? 'Table ' . $order->table->table_number : 'Takeaway',
                    'status' => $order->status,
                    'time' => $order->created_at->format('H:i'),
                    'items' => $order->items->map(function ($item) {
                        return [
                            'id' => $item->id,
                            'name' => $item->menuItem ? $item->menuItem->name : 'Unknown Item',
                            'qty' => $item->quantity,
                        ];
                    }),
                ];
            });

        return Inertia::render('Kitchen', [
            'orders' => $orders
        ]);
    }

    public function updateStatus(Request $request, Order $order)
    {
        if ($order->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $request->validate([
            'status' => 'required|in:pending,preparing,completed'
        ]);

        $order->update(['status' => $request->status]);

        return back();
    }
}
