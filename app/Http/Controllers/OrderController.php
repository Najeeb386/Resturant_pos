<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\Request;
use Inertia\Inertia;

class OrderController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $restaurantId = auth()->user()->restaurant_id;

        $orders = Order::with('orderItems.menuItem')
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
                    'delivery_fee' => (float) $order->delivery_fee,
                    'total' => (float) $order->total,
                    'created_at' => $order->created_at->format('M d, Y h:i A'),
                    'items' => $order->orderItems->map(fn($item) => [
                        'name' => $item->menuItem?->name ?? 'Item',
                        'qty' => $item->quantity,
                        'price' => (float) $item->price
                    ]),
                ];
            });

        return Inertia::render('Orders', [
            'orders' => $orders,
            'kitchen_bypass' => (bool) auth()->user()->restaurant->kitchen_bypass,
            'currency_symbol' => auth()->user()->restaurant->currency_symbol ?? '$'
        ]);
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

        // If table was attached and order is cancelled or completed, maybe free the table?
        // PosController handles table freeing on checkout. If cancelled from dashboard, free it.
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
}
