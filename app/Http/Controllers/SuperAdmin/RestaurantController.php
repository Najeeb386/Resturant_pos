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
}
