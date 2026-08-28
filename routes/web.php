<?php

use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use App\Models\Restaurant;
use App\Models\Subscription;

use App\Models\SubscriptionPlan;

Route::get('/', function () {
    if (auth()->check()) {
        return auth()->user()->role_id === 1 ? redirect('/admin/dashboard') : redirect('/dashboard');
    }
    
    $plans = SubscriptionPlan::all();
    $settings = \DB::table('platform_settings')->first() ?? (object) [
        'currency_symbol' => '$',
    ];

    return Inertia::render('Landing', [
        'plans' => $plans,
        'currencySymbol' => $settings->currency_symbol,
    ]);
});

Route::get('/login', function () {
    return Inertia::render('Login');
})->middleware('guest')->name('login');

// Public Customer QR Table Digital Self-Ordering Routes
Route::get('/table-order/{restaurant}/{table}', [\App\Http\Controllers\CustomerOrderController::class, 'showMenu'])->name('customer.qr.menu');
Route::post('/table-order/checkout', [\App\Http\Controllers\CustomerOrderController::class, 'storeOrder'])->name('customer.qr.checkout');

// Storage Fallback Route (fixes Hostinger 403 Forbidden symlink restriction)
Route::get('/storage/{path}', function ($path) {
    $filePath = storage_path('app/public/' . $path);
    if (!file_exists($filePath)) {
        abort(404);
    }
    return response()->file($filePath);
})->where('path', '.*');

Route::post('/login', [App\Http\Controllers\API\AuthController::class, 'login'])->middleware('guest');

Route::get('/register', function () {
    return Inertia::render('Register', [
        'plans' => SubscriptionPlan::all(),
        'currencySymbol' => \DB::table('platform_settings')->first()?->currency_symbol ?? '$',
    ]);
})->middleware('guest')->name('register');

Route::post('/register', function (\Illuminate\Http\Request $request) {
    $request->validate([
        'restaurant_name' => 'required|string|max:255',
        'name' => 'required|string|max:255',
        'email' => 'required|email|unique:users',
        'password' => 'required|min:8',
        'plan_id' => 'required|exists:subscription_plans,id',
    ]);

    // Create Restaurant
    $restaurant = \App\Models\Restaurant::create([
        'name' => $request->restaurant_name,
        'currency' => 'USD',
        'currency_symbol' => '$',
        'tax_percentage' => 0,
    ]);

    // Create User (Role 2 = Restaurant Admin)
    $user = \App\Models\User::create([
        'name' => $request->name,
        'email' => $request->email,
        'password' => \Hash::make($request->password),
        'role_id' => 2,
        'restaurant_id' => $restaurant->id,
    ]);

    // Create Trial Subscription
    \App\Models\Subscription::create([
        'restaurant_id' => $restaurant->id,
        'subscription_plan_id' => $request->plan_id,
        'starts_at' => now(),
        'ends_at' => now()->addDays(14), // 14-day free trial
        'status' => 'active',
    ]);

    auth()->login($user);

    return redirect('/dashboard');
})->middleware('guest');

Route::get('/admin/login', function () {
    return Inertia::render('SuperAdmin/Login');
})->middleware('guest')->name('admin.login');

Route::post('/admin/login', [App\Http\Controllers\API\AuthController::class, 'adminLogin'])->middleware('guest');

Route::middleware('auth')->group(function () {
    Route::get('/dashboard', [\App\Http\Controllers\DashboardController::class, 'index'])->name('dashboard');

    Route::get('/pos', [\App\Http\Controllers\PosController::class, 'index']);
    Route::post('/pos/checkout', [\App\Http\Controllers\PosController::class, 'checkout']);
    Route::post('/pos/draft', [\App\Http\Controllers\PosController::class, 'saveDraft']);

    Route::resource('tables', \App\Http\Controllers\TableController::class)->except(['create', 'show', 'edit']);
    
    Route::get('/settings/profile', [\App\Http\Controllers\RestaurantProfileController::class, 'edit'])->name('profile.edit');
    Route::post('/settings/profile', [\App\Http\Controllers\RestaurantProfileController::class, 'update'])->name('profile.update');

    Route::resource('staff', \App\Http\Controllers\StaffController::class)->except(['create', 'show', 'edit']);

    Route::get('/kitchen', [\App\Http\Controllers\KitchenController::class, 'index'])->name('kitchen.index');
    Route::get('/kitchen/live-orders', [\App\Http\Controllers\KitchenController::class, 'liveOrders'])->name('kitchen.liveOrders');
    Route::post('/kitchen/{order}/status', [\App\Http\Controllers\KitchenController::class, 'updateStatus'])->name('kitchen.updateStatus');
    Route::post('/kitchen/{order}/confirm-update', [\App\Http\Controllers\KitchenController::class, 'confirmUpdate'])->name('kitchen.confirmUpdate');

    Route::get('/orders', [\App\Http\Controllers\OrderController::class, 'index'])->name('orders.index');
    Route::put('/orders/{order}', [\App\Http\Controllers\OrderController::class, 'update'])->name('orders.update');
    Route::post('/orders/{order}/payment-status', [\App\Http\Controllers\OrderController::class, 'updatePaymentStatus'])->name('orders.updatePaymentStatus');
    Route::post('/orders/{order}/status', [\App\Http\Controllers\OrderController::class, 'updateStatus'])->name('orders.updateStatus');
    Route::get('/orders/{order}/receipt', [\App\Http\Controllers\OrderController::class, 'printReceipt'])->name('orders.printReceipt');
    Route::get('/orders/{order}/kot', [\App\Http\Controllers\OrderController::class, 'printKOT'])->name('orders.printKOT');
    Route::get('/orders/{order}/both', [\App\Http\Controllers\OrderController::class, 'printBoth'])->name('orders.printBoth');

    // Menu Management
    Route::get('/menu', [\App\Http\Controllers\MenuController::class, 'index'])->name('menu.index');
    Route::post('/menu/category', [\App\Http\Controllers\MenuController::class, 'storeCategory'])->name('menu.category.store');
    Route::delete('/menu/category/{category}', [\App\Http\Controllers\MenuController::class, 'destroyCategory'])->name('menu.category.destroy');
    Route::post('/menu/item', [\App\Http\Controllers\MenuController::class, 'storeItem'])->name('menu.item.store');
    Route::post('/menu/item/{menuItem}', [\App\Http\Controllers\MenuController::class, 'updateItem'])->name('menu.item.update');
    Route::delete('/menu/item/{menuItem}', [\App\Http\Controllers\MenuController::class, 'destroyItem'])->name('menu.item.destroy');

    // AI 3D Menu Studio
    Route::get('/menu/3d-studio', [\App\Http\Controllers\ThreedStudioController::class, 'index'])->name('menu.3d-studio');
    Route::post('/menu/3d-studio/generate', [\App\Http\Controllers\ThreedStudioController::class, 'generate3dModel'])->name('menu.3d-studio.generate');
    Route::delete('/menu/3d-studio/{menuItem}', [\App\Http\Controllers\ThreedStudioController::class, 'destroy3dModel'])->name('menu.3d-studio.destroy');

    // Expenses
    Route::get('/expenses', [\App\Http\Controllers\ExpenseController::class, 'index']);
    Route::post('/expenses', [\App\Http\Controllers\ExpenseController::class, 'store']);
    Route::put('/expenses/{expense}', [\App\Http\Controllers\ExpenseController::class, 'update']);
    Route::delete('/expenses/{expense}', [\App\Http\Controllers\ExpenseController::class, 'destroy']);

    // Reports
    Route::get('/reports', [\App\Http\Controllers\ReportController::class, 'index']);

    // Inventory & Procurement
    Route::get('/inventory', [\App\Http\Controllers\InventoryController::class, 'index']);
    Route::post('/inventory', [\App\Http\Controllers\InventoryController::class, 'store']);
    Route::put('/inventory/{inventory}', [\App\Http\Controllers\InventoryController::class, 'update']);
    Route::delete('/inventory/{inventory}', [\App\Http\Controllers\InventoryController::class, 'destroy']);
    Route::post('/inventory/{inventory}/restock', [\App\Http\Controllers\InventoryController::class, 'restock']);

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
        Route::put('/restaurants/{restaurant}', [\App\Http\Controllers\SuperAdmin\RestaurantController::class, 'update']);
        Route::delete('/restaurants/{restaurant}', [\App\Http\Controllers\SuperAdmin\RestaurantController::class, 'destroy']);

        Route::get('/subscriptions', [\App\Http\Controllers\SuperAdmin\SubscriptionController::class, 'index'])->name('admin.subscriptions.index');
        Route::post('/subscriptions/{subscription}/renew', [\App\Http\Controllers\SuperAdmin\SubscriptionController::class, 'renew'])->name('admin.subscriptions.renew');
        Route::post('/subscriptions/{subscription}/extend', [\App\Http\Controllers\SuperAdmin\SubscriptionController::class, 'extend'])->name('admin.subscriptions.extend');
        Route::post('/subscriptions/{subscription}/cancel', [\App\Http\Controllers\SuperAdmin\SubscriptionController::class, 'cancel'])->name('admin.subscriptions.cancel');
        
        Route::get('/plans', [\App\Http\Controllers\SuperAdmin\PlanController::class, 'index']);
        Route::post('/plans', [\App\Http\Controllers\SuperAdmin\PlanController::class, 'store']);
        Route::put('/plans/{plan}', [\App\Http\Controllers\SuperAdmin\PlanController::class, 'update']);
        Route::delete('/plans/{plan}', [\App\Http\Controllers\SuperAdmin\PlanController::class, 'destroy']);

        Route::get('/expenses', [\App\Http\Controllers\SuperAdmin\ExpenseController::class, 'index'])->name('admin.expenses.index');
        Route::post('/expenses', [\App\Http\Controllers\SuperAdmin\ExpenseController::class, 'store']);
        Route::put('/expenses/{expense}', [\App\Http\Controllers\SuperAdmin\ExpenseController::class, 'update']);
        Route::delete('/expenses/{expense}', [\App\Http\Controllers\SuperAdmin\ExpenseController::class, 'destroy']);

        Route::get('/reports', [\App\Http\Controllers\SuperAdmin\ReportController::class, 'index'])->name('admin.reports.index');

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

    Route::post('/logout', function (\Illuminate\Http\Request $request) {
        auth()->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/login');
    });
});
