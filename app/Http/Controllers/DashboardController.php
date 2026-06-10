<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\MenuItem;
use Inertia\Inertia;
use Illuminate\Support\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        if (auth()->user()->role_id === 1) {
            return redirect('/admin/dashboard');
        }

        // Smart redirects for staff members who don't have dashboard access
        if (auth()->user()->role_id === 4) { // Waiter
            return redirect('/pos');
        }
        if (auth()->user()->role_id === 5) { // Kitchen
            return redirect('/kitchen');
        }
        if (auth()->user()->role_id === 6) { // Delivery
            return redirect('/orders');
        }

        $restaurantId = auth()->user()->restaurant_id;
        $restaurant = auth()->user()->restaurant;

        // Today's metrics
        $today = Carbon::today();
        
        $todaysOrders = Order::where('restaurant_id', $restaurantId)
            ->whereDate('created_at', $today)
            ->get();

        $totalRevenue = $todaysOrders->sum('total');
        $totalOrders = $todaysOrders->count();
        $activeOrders = Order::where('restaurant_id', $restaurantId)
            ->whereIn('status', ['pending', 'preparing'])
            ->count();
            
        // Low stock items
        $lowStockItems = MenuItem::where('restaurant_id', $restaurantId)
            ->where('stock_quantity', '<=', 10)
            ->count();

        // Recent Orders
        $recentOrders = Order::with('table')
            ->where('restaurant_id', $restaurantId)
            ->orderBy('created_at', 'desc')
            ->take(5)
            ->get()
            ->map(function ($order) {
                return [
                    'id' => $order->id,
                    'table' => $order->table ? 'Table ' . $order->table->table_number : 'Takeaway',
                    'total' => $order->total,
                    'status' => $order->status,
                    'time' => $order->created_at->diffForHumans()
                ];
            });

        return Inertia::render('Dashboard', [
            'stats' => [
                'revenue' => $totalRevenue,
                'orders' => $totalOrders,
                'active' => $activeOrders,
                'lowStock' => $lowStockItems
            ],
            'recentOrders' => $recentOrders,
            'currency' => $restaurant->currency_symbol ?? '$'
        ]);
    }
}
