<?php

use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

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
            return Inertia::render('SuperAdmin/Dashboard');
        });
        
        Route::get('/restaurants', [\App\Http\Controllers\SuperAdmin\RestaurantController::class, 'index']);
        Route::post('/restaurants', [\App\Http\Controllers\SuperAdmin\RestaurantController::class, 'store']);
        
        Route::get('/plans', [\App\Http\Controllers\SuperAdmin\PlanController::class, 'index']);
        Route::post('/plans', [\App\Http\Controllers\SuperAdmin\PlanController::class, 'store']);
    });

    Route::post('/logout', function () {
        auth()->logout();
        return redirect('/login');
    });
});
