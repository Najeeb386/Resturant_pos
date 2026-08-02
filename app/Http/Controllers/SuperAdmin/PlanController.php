<?php

namespace App\Http\Controllers\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;
use Inertia\Inertia;

class PlanController extends Controller
{
    public function index()
    {
        $plans = SubscriptionPlan::all();
        return Inertia::render('SuperAdmin/Plans', [
            'plans' => $plans
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'billing_cycle' => 'required|in:monthly,yearly',
            'features' => 'nullable|array',
            'max_users' => 'nullable|integer',
            'max_branches' => 'nullable|integer',
        ]);

        SubscriptionPlan::create($validated);

        return back()->with('success', 'Plan created successfully');
    }

    public function update(Request $request, SubscriptionPlan $plan)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'billing_cycle' => 'required|in:monthly,yearly',
            'features' => 'nullable|array',
            'max_users' => 'nullable|integer',
            'max_branches' => 'nullable|integer',
        ]);

        $plan->update($validated);

        return back()->with('success', 'Plan updated successfully');
    }

    public function destroy(SubscriptionPlan $plan)
    {
        $hasSubscriptions = \App\Models\Subscription::where('subscription_plan_id', $plan->id)->exists();
        if ($hasSubscriptions) {
            return back()->withErrors(['error' => 'Cannot delete plan as active subscriptions are using it.']);
        }

        $plan->delete();

        return back()->with('success', 'Plan deleted successfully');
    }
}
