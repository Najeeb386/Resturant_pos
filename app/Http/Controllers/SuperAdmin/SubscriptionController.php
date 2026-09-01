<?php

namespace App\Http\Controllers\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Carbon\Carbon;

class SubscriptionController extends Controller
{
    public function index()
    {
        $subscriptions = Subscription::with(['restaurant', 'plan'])
            ->latest('id')
            ->get();

        $plans = SubscriptionPlan::all();

        return Inertia::render('SuperAdmin/Subscriptions', [
            'subscriptions' => $subscriptions,
            'plans' => $plans,
        ]);
    }

    public function renew(Request $request, Subscription $subscription)
    {
        $months = (int) $request->input('months', 1);

        $baseDate = ($subscription->ends_at && Carbon::parse($subscription->ends_at)->isFuture())
            ? Carbon::parse($subscription->ends_at)
            : now();

        $subscription->update([
            'status' => 'active',
            'starts_at' => $subscription->starts_at ?? now(),
            'ends_at' => $baseDate->addMonths($months),
        ]);

        return back()->with('success', 'Subscription renewed successfully');
    }

    public function extend(Request $request, Subscription $subscription)
    {
        $request->validate([
            'months' => 'required|integer|min:1|max:60',
        ]);

        $months = (int) $request->input('months');

        $baseDate = ($subscription->ends_at && Carbon::parse($subscription->ends_at)->isFuture())
            ? Carbon::parse($subscription->ends_at)
            : now();

        $subscription->update([
            'status' => 'active',
            'ends_at' => $baseDate->addMonths($months),
        ]);

        return back()->with('success', "Subscription extended by {$months} month(s)");
    }

    public function cancel(Subscription $subscription)
    {
        $subscription->update([
            'status' => 'cancelled',
        ]);

        return back()->with('success', 'Subscription cancelled');
    }
}
