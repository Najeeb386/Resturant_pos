<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Expense;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Carbon\Carbon;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $restaurantId = auth()->user()->restaurant_id;
        $range = $request->query('range', 'today'); // today, week, month, year, all

        $queryStart = match($range) {
            'today' => Carbon::today(),
            'week' => Carbon::now()->startOfWeek(),
            'month' => Carbon::now()->startOfMonth(),
            'year' => Carbon::now()->startOfYear(),
            default => Carbon::createFromTimestamp(0),
        };

        // Orders Query
        $orders = Order::where('restaurant_id', $restaurantId)
            ->where('created_at', '>=', $queryStart)
            ->where('payment_status', 'paid');

        $grossSales = (clone $orders)->sum('total');
        $orderCount = (clone $orders)->count();
        $cashSales = (clone $orders)->where('notes', 'like', '%Cash%')->sum('total');
        $cardSales = (clone $orders)->where('notes', 'not like', '%Cash%')->sum('total');

        // COGS Query (Cost of Goods Sold)
        // We join order_items to calculate total cost_price * quantity for the paid orders in this range
        $cogs = OrderItem::whereHas('order', function ($q) use ($restaurantId, $queryStart) {
            $q->where('restaurant_id', $restaurantId)
              ->where('created_at', '>=', $queryStart)
              ->where('payment_status', 'paid');
        })->selectRaw('SUM(quantity * cost_price) as total_cogs')->value('total_cogs') ?? 0;

        // Expenses Query
        $expenses = Expense::where('restaurant_id', $restaurantId)
            ->where('date', '>=', $queryStart)
            ->sum('amount');

        // Net Profit Calculation
        $netProfit = $grossSales - $cogs - $expenses;

        // Item Profitability
        $itemStats = OrderItem::whereHas('order', function ($q) use ($restaurantId, $queryStart) {
                $q->where('restaurant_id', $restaurantId)
                  ->where('created_at', '>=', $queryStart)
                  ->where('payment_status', 'paid');
            })
            ->join('menu_items', 'order_items.menu_item_id', '=', 'menu_items.id')
            ->selectRaw('
                menu_items.name, 
                SUM(order_items.quantity) as total_sold,
                SUM(order_items.quantity * order_items.price) as revenue,
                SUM(order_items.quantity * order_items.cost_price) as cost
            ')
            ->groupBy('menu_items.id', 'menu_items.name')
            ->orderByDesc('revenue')
            ->limit(10)
            ->get()
            ->map(function ($item) {
                $item->profit = $item->revenue - $item->cost;
                $item->margin = $item->revenue > 0 ? round(($item->profit / $item->revenue) * 100, 2) : 0;
                return $item;
            });

        $settings = \DB::table('platform_settings')->first() ?? (object) ['currency_symbol' => '$'];

        return Inertia::render('Reports/Index', [
            'range' => $range,
            'currencySymbol' => $settings->currency_symbol,
            'summary' => [
                'grossSales' => round($grossSales, 2),
                'cogs' => round($cogs, 2),
                'expenses' => round($expenses, 2),
                'netProfit' => round($netProfit, 2),
                'orderCount' => $orderCount,
                'cashSales' => round($cashSales, 2),
                'cardSales' => round($cardSales, 2),
            ],
            'itemStats' => $itemStats,
        ]);
    }
}
