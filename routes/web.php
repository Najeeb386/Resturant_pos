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
    Route::get('/dashboard', function () {
        if (auth()->user()->role_id === 1) {
            return redirect('/admin/dashboard');
        }
        return Inertia::render('Dashboard', [
            'user' => auth()->user()->load('role', 'restaurant'),
        ]);
    });

    Route::get('/pos', [\App\Http\Controllers\PosController::class, 'index']);
    Route::post('/pos/checkout', [\App\Http\Controllers\PosController::class, 'checkout']);

    Route::resource('tables', \App\Http\Controllers\TableController::class)->except(['create', 'show', 'edit']);
    
    Route::get('/settings/profile', [\App\Http\Controllers\RestaurantProfileController::class, 'edit'])->name('profile.edit');
    Route::post('/settings/profile', [\App\Http\Controllers\RestaurantProfileController::class, 'update'])->name('profile.update');

    Route::get('/kitchen', function () {
        return Inertia::render('Kitchen');
    });

    Route::get('/menu', function () {
        return Inertia::render('Menu/Index');
    });

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
