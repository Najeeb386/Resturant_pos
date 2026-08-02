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
                $user = auth()->user();
                if (!$user) {
                    return ['user' => null];
                }
                return [
                    'user' => $user->only('id', 'name', 'email', 'role_id', 'restaurant_id'),
                ];
            },
            'tenantSubscription' => function () {
                $user = auth()->user();
                if (!$user) {
                    return null;
                }

                // Super Admin has unrestricted full access
                if ((int)$user->role_id === 1) {
                    return [
                        'status' => 'active',
                        'isSuperAdmin' => true,
                        'features' => ['pos_billing', 'tables', 'kitchen', 'orders', 'menu', 'inventory', 'expenses', 'reports', 'staff'],
                    ];
                }

                if (!$user->restaurant_id) {
                    return [
                        'status' => 'no_sub',
                        'isSuperAdmin' => false,
                        'features' => [],
                    ];
                }

                $sub = \App\Models\Subscription::where('restaurant_id', $user->restaurant_id)
                    ->with('plan')
                    ->first();

                if (!$sub) {
                    return [
                        'status' => 'no_sub',
                        'isSuperAdmin' => false,
                        'features' => [],
                    ];
                }

                $isExpired = $sub->ends_at && \Carbon\Carbon::parse($sub->ends_at)->isPast();
                $status = $sub->status;
                if ($status === 'active' && $isExpired) {
                    $status = 'expired';
                }

                $features = is_array($sub->plan?->features) ? $sub->plan->features : [];

                return [
                    'status' => $status,
                    'isSuperAdmin' => false,
                    'plan_name' => $sub->plan?->name ?? 'Standard',
                    'ends_at' => $sub->ends_at ? \Carbon\Carbon::parse($sub->ends_at)->toFormattedDateString() : null,
                    'features' => $status === 'active' ? $features : [],
                ];
            },
            'currencySymbol' => function () {
                $settings = \DB::table('platform_settings')->first();
                return $settings?->currency_symbol ?? '$';
            },
        ]);
    }
}
