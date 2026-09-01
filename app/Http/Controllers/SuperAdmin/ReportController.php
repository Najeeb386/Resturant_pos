<?php

namespace App\Http\Controllers\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\PlatformExpense;
use App\Models\Restaurant;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Carbon\Carbon;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $period = $request->input('period', 'all_time');

        $queryStartDate = null;
        $queryEndDate = now();

        switch ($period) {
            case 'this_month':
                $queryStartDate = now()->startOfMonth();
                break;
            case 'last_month':
                $queryStartDate = now()->subMonth()->startOfMonth();
                $queryEndDate = now()->subMonth()->endOfMonth();
                break;
            case 'this_quarter':
                $queryStartDate = now()->startOfQuarter();
                break;
            case 'this_year':
                $queryStartDate = now()->startOfYear();
                break;
            default:
                $queryStartDate = null;
                break;
        }

        // Active subscriptions
        $subQuery = Subscription::with(['restaurant', 'plan'])
            ->where('status', 'active');

        if ($queryStartDate) {
            $subQuery->whereBetween('starts_at', [$queryStartDate, $queryEndDate]);
        }

        $activeSubs = $subQuery->get();

        // Calculate Gross Revenue
        $grossRevenue = $activeSubs->sum(function ($sub) {
            return $sub->plan?->price ?? 0;
        });

        // Calculate Platform Expenses
        $expenseQuery = PlatformExpense::query();
        if ($queryStartDate) {
            $expenseQuery->whereBetween('date', [$queryStartDate, $queryEndDate]);
        }
        $totalExpenses = $expenseQuery->sum('amount');

        // Net Profit
        $netProfit = $grossRevenue - $totalExpenses;

        // Tenant metrics
        $totalTenants = Restaurant::count();
        $activeTenantsCount = $activeSubs->pluck('restaurant_id')->unique()->count();
        $arpu = $activeTenantsCount > 0 ? ($grossRevenue / $activeTenantsCount) : 0;

        // Monthly Breakdown
        $monthlyRevenue = Subscription::where('status', 'active')
            ->join('subscription_plans', 'subscriptions.subscription_plan_id', '=', 'subscription_plans.id')
            ->selectRaw('DATE_FORMAT(starts_at, "%Y-%m") as month_key, DATE_FORMAT(starts_at, "%b %Y") as month_label, SUM(subscription_plans.price) as revenue')
            ->groupBy('month_key', 'month_label')
            ->orderBy('month_key', 'desc')
            ->limit(12)
            ->get();

        $monthlyExpenses = PlatformExpense::selectRaw('DATE_FORMAT(date, "%Y-%m") as month_key, SUM(amount) as expenses')
            ->groupBy('month_key')
            ->pluck('expenses', 'month_key');

        $financialBreakdown = $monthlyRevenue->map(function ($row) use ($monthlyExpenses) {
            $exp = $monthlyExpenses[$row->month_key] ?? 0;
            return [
                'month' => $row->month_label,
                'revenue' => (float) $row->revenue,
                'expenses' => (float) $exp,
                'net' => (float) ($row->revenue - $exp),
            ];
        });

        // Tenant Revenue Table
        $tenantRevenues = Restaurant::with(['subscription.plan'])
            ->get()
            ->map(function ($r) {
                return [
                    'id' => $r->id,
                    'name' => $r->name,
                    'email' => $r->email,
                    'plan_name' => $r->subscription?->plan?->name ?? 'No Plan',
                    'plan_price' => $r->subscription?->plan?->price ?? 0,
                    'status' => $r->subscription?->status ?? 'no_sub',
                    'joined_at' => $r->created_at->toFormattedDateString(),
                ];
            });

        return Inertia::render('SuperAdmin/Reports', [
            'period' => $period,
            'stats' => [
                'grossRevenue' => number_format($grossRevenue, 2, '.', ''),
                'totalExpenses' => number_format($totalExpenses, 2, '.', ''),
                'netProfit' => number_format($netProfit, 2, '.', ''),
                'activeTenants' => $activeTenantsCount,
                'totalTenants' => $totalTenants,
                'arpu' => number_format($arpu, 2, '.', ''),
            ],
            'financialBreakdown' => $financialBreakdown,
            'tenantRevenues' => $tenantRevenues,
        ]);
    }
}
