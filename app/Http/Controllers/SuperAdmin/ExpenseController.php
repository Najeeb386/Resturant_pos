<?php

namespace App\Http\Controllers\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\PlatformExpense;
use Illuminate\Http\Request;
use Inertia\Inertia;

class ExpenseController extends Controller
{
    public function index()
    {
        $expenses = PlatformExpense::latest('date')->get();

        return Inertia::render('SuperAdmin/Expenses', [
            'expenses' => $expenses,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0.01',
            'category' => 'required|string|max:100',
            'date' => 'required|date',
            'notes' => 'nullable|string',
        ]);

        PlatformExpense::create($validated);

        return back()->with('success', 'Platform expense recorded successfully');
    }

    public function update(Request $request, PlatformExpense $expense)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0.01',
            'category' => 'required|string|max:100',
            'date' => 'required|date',
            'notes' => 'nullable|string',
        ]);

        $expense->update($validated);

        return back()->with('success', 'Platform expense updated successfully');
    }

    public function destroy(PlatformExpense $expense)
    {
        $expense->delete();

        return back()->with('success', 'Platform expense deleted successfully');
    }
}
