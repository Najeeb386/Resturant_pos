<?php

namespace App\Http\Controllers\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\Restaurant;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Inertia\Inertia;

class RestaurantController extends Controller
{
    public function index()
    {
        $restaurants = Restaurant::with('subscription.plan')->get();
        $plans = SubscriptionPlan::all();
        
        return Inertia::render('SuperAdmin/Restaurants', [
            'tenants' => $restaurants,
            'plans' => $plans
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'restaurant_name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone' => 'nullable|string',
            'plan_id' => 'required|exists:subscription_plans,id',
            'duration_months' => 'required|integer|min:1',
        ]);

        \DB::transaction(function () use ($validated) {
            // 1. Create Restaurant
            $restaurant = Restaurant::create([
                'name' => $validated['restaurant_name'],
                'email' => $validated['email'],
                'phone' => $validated['phone'] ?? null,
                'address' => 'N/A', // Assuming basic creation, can update later
            ]);

            // 2. Create Owner User
            $user = User::create([
                'name' => 'Owner',
                'email' => $validated['email'],
                'password' => Hash::make('password'),
                'role_id' => 2, // 2 = Restaurant Owner
                'restaurant_id' => $restaurant->id,
            ]);

            // 3. Create Subscription
            $plan = SubscriptionPlan::find($validated['plan_id']);
            Subscription::create([
                'restaurant_id' => $restaurant->id,
                'subscription_plan_id' => $plan->id,
                'status' => 'active',
                'starts_at' => now(),
                'ends_at' => now()->addMonths($validated['duration_months']),
            ]);
        });

        return back()->with('success', 'Tenant registered successfully');
    }

    public function update(Request $request, Restaurant $restaurant)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:restaurants,email,' . $restaurant->id,
            'phone' => 'nullable|string',
            'plan_id' => 'nullable|exists:subscription_plans,id',
            'status' => 'nullable|string|in:active,expired,cancelled,no_sub',
        ]);

        $restaurant->update([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'] ?? null,
        ]);

        if (!empty($validated['plan_id'])) {
            $sub = Subscription::where('restaurant_id', $restaurant->id)->first();
            if ($sub) {
                $sub->update([
                    'subscription_plan_id' => $validated['plan_id'],
                    'status' => $validated['status'] ?? $sub->status,
                ]);
            } else {
                Subscription::create([
                    'restaurant_id' => $restaurant->id,
                    'subscription_plan_id' => $validated['plan_id'],
                    'status' => $validated['status'] ?? 'active',
                    'starts_at' => now(),
                    'ends_at' => now()->addMonth(),
                ]);
            }
        }

        return back()->with('success', 'Restaurant updated successfully');
    }

    public function destroy(Restaurant $restaurant)
    {
        \DB::transaction(function () use ($restaurant) {
            Subscription::where('restaurant_id', $restaurant->id)->delete();
            User::where('restaurant_id', $restaurant->id)->delete();
            $restaurant->delete();
        });

        return back()->with('success', 'Restaurant deleted successfully');
    }
}
