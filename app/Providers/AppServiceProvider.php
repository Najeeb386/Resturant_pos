<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        \Inertia\Inertia::share([
            'auth' => function () {
                return [
                    'user' => auth()->user() ? auth()->user()->only('id', 'name', 'email', 'role_id', 'restaurant_id') : null,
                ];
            },
        ]);
    }
}
