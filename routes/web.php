<?php

use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use App\Models\Restaurant;
use App\Models\Subscription;

Route::get('/', function () {
    if (auth()->check() && auth()->user()->role_id === 1) {
        return redirect('/admin/dashboard');
    }
    return redirect('/dashboard');
});

Route::get('/login', function () {
    return Inertia::render('Login');
})->middleware('guest')->name('login');

Route::post('/login', [App\Http\Controllers\API\AuthController::class, 'login'])->middleware('guest');

Route::middleware('auth')->group(function () {
    Route::get('/dashboard', [\App\Http\Controllers\DashboardController::class, 'index'])->name('dashboard');

    Route::get('/pos', [\App\Http\Controllers\PosController::class, 'index']);
    Route::post('/pos/checkout', [\App\Http\Controllers\PosController::class, 'checkout']);

    Route::resource('tables', \App\Http\Controllers\TableController::class)->except(['create', 'show', 'edit']);
    
    Route::get('/settings/profile', [\App\Http\Controllers\RestaurantProfileController::class, 'edit'])->name('profile.edit');
    Route::post('/settings/profile', [\App\Http\Controllers\RestaurantProfileController::class, 'update'])->name('profile.update');

    Route::resource('staff', \App\Http\Controllers\StaffController::class)->except(['create', 'show', 'edit']);

    Route::get('/kitchen', [\App\Http\Controllers\KitchenController::class, 'index'])->name('kitchen.index');
    Route::post('/kitchen/{order}/status', [\App\Http\Controllers\KitchenController::class, 'updateStatus'])->name('kitchen.updateStatus');

    // Menu Management
    Route::get('/menu', [\App\Http\Controllers\MenuController::class, 'index'])->name('menu.index');
    Route::post('/menu/category', [\App\Http\Controllers\MenuController::class, 'storeCategory'])->name('menu.category.store');
    Route::delete('/menu/category/{category}', [\App\Http\Controllers\MenuController::class, 'destroyCategory'])->name('menu.category.destroy');
    Route::post('/menu/item', [\App\Http\Controllers\MenuController::class, 'storeItem'])->name('menu.item.store');
    Route::post('/menu/item/{menuItem}', [\App\Http\Controllers\MenuController::class, 'updateItem'])->name('menu.item.update');
    Route::delete('/menu/item/{menuItem}', [\App\Http\Controllers\MenuController::class, 'destroyItem'])->name('menu.item.destroy');

    // Super Admin Routes (SaaS Portal)
    Route::prefix('admin')->group(function () {
        Route::get('/dashboard', function () {
            $totalTenants = Restaurant::count();
            $activeRestaurants = Subscription::where('status', 'active')
                ->distinct('restaurant_id')
                ->count('restaurant_id');
            $totalMRR = Subscription::where('status', 'active')
                ->join('subscription_plans', 'subscriptions.subscription_plan_id', '=', 'subscription_plans.id')
                ->sum('subscription_plans.price');

            $settings = \DB::table('platform_settings')->first() ?? (object) [
                'currency' => 'USD',
                'currency_symbol' => '$',
            ];

            $expiringSubscriptions = Subscription::where('status', 'active')
                ->whereBetween('ends_at', [now(), now()->addDays(30)])
                ->count();

            // Monthly revenue for last 6 months (chart)
            $monthlyRevenue = Subscription::where('status', 'active')
                ->join('subscription_plans', 'subscriptions.subscription_plan_id', '=', 'subscription_plans.id')
                ->selectRaw('DATE_FORMAT(starts_at, "%b") as month, SUM(subscription_plans.price) as revenue')
                ->groupBy('month')
                ->orderByRaw('MIN(starts_at)')
                ->limit(6)
                ->pluck('revenue', 'month')
                ->toArray();

            $chartData = collect(['Jan','Feb','Mar','Apr','May','Jun'])
                ->map(fn($m) => ['name' => $m, 'revenue' => $monthlyRevenue[$m] ?? 0])
                ->toArray();

            $recentSignups = Restaurant::with('subscription.plan')
                ->latest()
                ->take(5)
                ->get()
                ->map(function ($r) {
                    return [
                        'name' => $r->name,
                        'plan' => $r->subscription?->plan?->name ?? 'N/A',
                        'status' => $r->subscription?->status ? ucfirst($r->subscription->status) : 'No Subscription',
                        'time' => $r->created_at->diffForHumans(),
                    ];
                });

            return Inertia::render('SuperAdmin/Dashboard', [
                'stats' => [
                    'mrr' => number_format($totalMRR, 2),
                    'activeRestaurants' => $activeRestaurants,
                    'totalTenants' => $totalTenants,
                    'expiringSubscriptions' => $expiringSubscriptions,
                ],
                'currencySymbol' => $settings->currency_symbol,
                'chartData' => $chartData,
                'recentSignups' => $recentSignups,
            ]);
        });
        
        Route::get('/restaurants', [\App\Http\Controllers\SuperAdmin\RestaurantController::class, 'index']);
        Route::post('/restaurants', [\App\Http\Controllers\SuperAdmin\RestaurantController::class, 'store']);
        
        Route::get('/plans', [\App\Http\Controllers\SuperAdmin\PlanController::class, 'index']);
        Route::post('/plans', [\App\Http\Controllers\SuperAdmin\PlanController::class, 'store']);

        // Super Admin Settings
        Route::get('/settings', function () {
            $settings = \DB::table('platform_settings')->first() ?? (object)[
                'currency' => 'USD',
                'currency_symbol' => '$',
            ];

            return Inertia::render('SuperAdmin/Settings', [
                'auth' => ['user' => auth()->user()],
                'settings' => $settings,
            ]);
        });

        Route::post('/settings/profile', function (\Illuminate\Http\Request $request) {
            $request->validate(['name' => 'required|string|max:255']);
            auth()->user()->update(['name' => $request->name]);
            return back()->with('success', 'Profile updated');
        });

        Route::post('/settings/password', function (\Illuminate\Http\Request $request) {
            $request->validate([
                'current_password' => 'required',
                'password' => 'required|confirmed|min:8',
            ]);

            if (!\Hash::check($request->current_password, auth()->user()->password)) {
                return back()->withErrors(['current_password' => 'Current password is incorrect']);
            }

            auth()->user()->update(['password' => \Hash::make($request->password)]);
            return back()->with('success', 'Password updated successfully');
        });

        Route::post('/settings/currency', function (\Illuminate\Http\Request $request) {
            $request->validate([
                'currency' => 'required|string|max:10',
                'currency_symbol' => 'required|string|max:5',
            ]);

            \DB::table('platform_settings')->updateOrInsert(
                ['id' => 1],
                [
                    'currency' => $request->currency,
                    'currency_symbol' => $request->currency_symbol,
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );

            return back()->with('success', 'Currency settings saved');
        });
    });

    Route::post('/logout', function () {
        auth()->logout();
        return redirect('/login');
    });
});
