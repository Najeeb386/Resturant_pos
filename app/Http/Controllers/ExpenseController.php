<?php

namespace App\Http\Controllers;

use App\Models\Expense;
use Illuminate\Http\Request;
use Inertia\Inertia;

class ExpenseController extends Controller
{
    public function index()
    {
        $expenses = Expense::where('restaurant_id', auth()->user()->restaurant_id)
            ->orderBy('date', 'desc')
            ->latest()
            ->paginate(20);

        $settings = \DB::table('platform_settings')->first() ?? (object) ['currency_symbol' => '$'];

        return Inertia::render('Expenses/Index', [
            'expenses' => $expenses,
            'currencySymbol' => $settings->currency_symbol,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:0',
            'category' => 'required|string|max:255',
            'date' => 'required|date',
            'notes' => 'nullable|string',
        ]);

        Expense::create([
            'restaurant_id' => auth()->user()->restaurant_id,
            'amount' => $request->amount,
            'category' => $request->category,
            'date' => $request->date,
            'notes' => $request->notes,
        ]);

        return back()->with('success', 'Expense logged successfully.');
    }

    public function update(Request $request, Expense $expense)
    {
        if ($expense->restaurant_id !== auth()->user()->restaurant_id) abort(403);

        $request->validate([
            'amount' => 'required|numeric|min:0',
            'category' => 'required|string|max:255',
            'date' => 'required|date',
            'notes' => 'nullable|string',
        ]);

        $expense->update($request->only('amount', 'category', 'date', 'notes'));

        return back()->with('success', 'Expense updated successfully.');
    }

    public function destroy(Expense $expense)
    {
        if ($expense->restaurant_id !== auth()->user()->restaurant_id) abort(403);
        $expense->delete();
        return back()->with('success', 'Expense deleted.');
    }
}
