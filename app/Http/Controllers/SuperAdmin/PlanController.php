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
}
