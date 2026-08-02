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
        $restaurant = auth()->user()->restaurant;
        $currencySymbol = $restaurant->currency_symbol ?? '$';
        
        $range = $request->query('range', 'today'); // today, week, month, year, all, custom
        $startDateParam = $request->query('start_date', Carbon::today()->format('Y-m-d'));
        $endDateParam = $request->query('end_date', Carbon::today()->format('Y-m-d'));

        if ($range === 'custom' && $startDateParam && $endDateParam) {
            $queryStart = Carbon::parse($startDateParam)->startOfDay();
            $queryEnd = Carbon::parse($endDateParam)->endOfDay();
        } else {
            $queryStart = match($range) {
                'today' => Carbon::today(),
                'week' => Carbon::now()->startOfWeek(),
                'month' => Carbon::now()->startOfMonth(),
                'year' => Carbon::now()->startOfYear(),
                default => Carbon::createFromTimestamp(0),
            };
            $queryEnd = Carbon::now()->endOfDay();
        }

        // Orders Query
        $ordersQuery = Order::where('restaurant_id', $restaurantId)
            ->whereBetween('created_at', [$queryStart, $queryEnd])
            ->where('payment_status', 'paid');

        $grossSales = (clone $ordersQuery)->sum('total');
        $orderCount = (clone $ordersQuery)->count();
        $cashSales = (clone $ordersQuery)->where('notes', 'like', '%Cash%')->sum('total');
        $cardSales = (clone $ordersQuery)->where('notes', 'like', '%Card%')->sum('total');
        $qrSales = (clone $ordersQuery)->where('notes', 'like', '%QR%')->sum('total');

        // COGS Query (Cost of Goods Sold)
        $cogs = OrderItem::whereHas('order', function ($q) use ($restaurantId, $queryStart, $queryEnd) {
            $q->where('restaurant_id', $restaurantId)
              ->whereBetween('created_at', [$queryStart, $queryEnd])
              ->where('payment_status', 'paid');
        })->selectRaw('SUM(quantity * cost_price) as total_cogs')->value('total_cogs') ?? 0;

        // Expenses Query
        $expenses = Expense::where('restaurant_id', $restaurantId)
            ->whereBetween('date', [$queryStart, $queryEnd])
            ->sum('amount');

        // Net Profit Calculation
        $netProfit = $grossSales - $cogs - $expenses;

        // Item Profitability / Product Sales
        $productSales = OrderItem::whereHas('order', function ($q) use ($restaurantId, $queryStart, $queryEnd) {
                $q->where('restaurant_id', $restaurantId)
                  ->whereBetween('created_at', [$queryStart, $queryEnd])
                  ->where('payment_status', 'paid');
            })
            ->join('menu_items', 'order_items.menu_item_id', '=', 'menu_items.id')
            ->leftJoin('menu_categories', 'menu_items.category_id', '=', 'menu_categories.id')
            ->selectRaw('
                menu_items.name as name,
                menu_categories.name as category_name,
                SUM(order_items.quantity) as total_sold,
                SUM(order_items.quantity * order_items.price) as revenue,
                SUM(order_items.quantity * order_items.cost_price) as cost
            ')
            ->groupBy('menu_items.id', 'menu_items.name', 'menu_categories.name')
            ->orderByDesc('revenue')
            ->get()
            ->map(function ($item) {
                $revenue = (float) $item->revenue;
                $cost = (float) $item->cost;
                $profit = $revenue - $cost;
                $margin = $revenue > 0 ? round(($profit / $revenue) * 100, 2) : 0;
                return [
                    'name' => $item->name,
                    'category' => $item->category_name ?? 'Uncategorized',
                    'total_sold' => (int) $item->total_sold,
                    'revenue' => round($revenue, 2),
                    'cost' => round($cost, 2),
                    'profit' => round($profit, 2),
                    'margin' => $margin
                ];
            });

        // Delivery Charges Report Data
        $deliveryOrdersQuery = Order::where('restaurant_id', $restaurantId)
            ->where('order_type', 'delivery')
            ->whereBetween('created_at', [$queryStart, $queryEnd]);

        $totalDeliveredOrders = (clone $deliveryOrdersQuery)->count();
        $collectedDeliveryCharges = (clone $deliveryOrdersQuery)->sum('delivery_fee');

        $deliveryOrders = (clone $deliveryOrdersQuery)
            ->select('id', 'customer_name', 'customer_phone', 'delivery_address', 'delivery_fee', 'total', 'payment_status', 'created_at')
            ->latest()
            ->get()
            ->map(fn($o) => [
                'id' => $o->id,
                'customer_name' => $o->customer_name ?? 'Walk-in / N/A',
                'customer_phone' => $o->customer_phone ?? 'N/A',
                'delivery_address' => $o->delivery_address ?? 'N/A',
                'delivery_fee' => (float) $o->delivery_fee,
                'total' => (float) $o->total,
                'payment_status' => $o->payment_status,
                'date' => $o->created_at->format('M d, Y h:i A'),
            ]);

        return Inertia::render('Reports/Index', [
            'range' => $range,
            'startDate' => $startDateParam,
            'endDate' => $endDateParam,
            'currencySymbol' => $currencySymbol,
            'cashFlowSummary' => [
                'grossSales' => round($grossSales, 2),
                'cogs' => round($cogs, 2),
                'expenses' => round($expenses, 2),
                'netProfit' => round($netProfit, 2),
                'orderCount' => $orderCount,
                'cashSales' => round($cashSales, 2),
                'cardSales' => round($cardSales, 2),
                'qrSales' => round($qrSales, 2),
            ],
            'productSales' => $productSales,
            'deliverySummary' => [
                'totalDeliveredOrders' => $totalDeliveredOrders,
                'collectedDeliveryCharges' => round($collectedDeliveryCharges, 2),
                'orders' => $deliveryOrders
            ]
        ]);
    }
}
