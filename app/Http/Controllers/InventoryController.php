<?php

namespace App\Http\Controllers;

use App\Models\Inventory;
use App\Models\Expense;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\DB;

class InventoryController extends Controller
{
    public function index()
    {
        $restaurantId = auth()->user()->restaurant_id;
        
        $inventory = Inventory::where('restaurant_id', $restaurantId)
            ->orderBy('name')
            ->get();

        $settings = DB::table('platform_settings')->first() ?? (object) ['currency_symbol' => '$'];

        return Inertia::render('Inventory/Index', [
            'inventory' => $inventory,
            'currencySymbol' => $settings->currency_symbol,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'unit' => 'required|string|max:20',
            'quantity' => 'required|numeric|min:0',
            'min_quantity' => 'required|numeric|min:0',
            'expiry_date' => 'nullable|date',
        ]);

        Inventory::create([
            'restaurant_id' => auth()->user()->restaurant_id,
            'name' => $request->name,
            'unit' => $request->unit,
            'quantity' => $request->quantity,
            'min_quantity' => $request->min_quantity,
            'expiry_date' => $request->expiry_date,
        ]);

        return back()->with('success', 'Ingredient added successfully.');
    }

    public function update(Request $request, Inventory $inventory)
    {
        if ($inventory->restaurant_id !== auth()->user()->restaurant_id) abort(403);

        $request->validate([
            'name' => 'required|string|max:255',
            'unit' => 'required|string|max:20',
            'quantity' => 'required|numeric|min:0',
            'min_quantity' => 'required|numeric|min:0',
            'expiry_date' => 'nullable|date',
        ]);

        $inventory->update($request->only('name', 'unit', 'quantity', 'min_quantity', 'expiry_date'));

        return back()->with('success', 'Ingredient updated successfully.');
    }

    public function destroy(Inventory $inventory)
    {
        if ($inventory->restaurant_id !== auth()->user()->restaurant_id) abort(403);
        $inventory->delete();
        return back()->with('success', 'Ingredient deleted.');
    }

    public function restock(Request $request, Inventory $inventory)
    {
        if ($inventory->restaurant_id !== auth()->user()->restaurant_id) abort(403);

        $request->validate([
            'added_quantity' => 'required|numeric|min:0.01',
            'total_cost' => 'required|numeric|min:0',
        ]);

        DB::beginTransaction();
        try {
            // Increase inventory
            $inventory->increment('quantity', $request->added_quantity);

            // Log expense
            if ($request->total_cost > 0) {
                Expense::create([
                    'restaurant_id' => auth()->user()->restaurant_id,
                    'amount' => $request->total_cost,
                    'category' => 'Ingredients',
                    'date' => now()->toDateString(),
                    'notes' => "Restocked {$request->added_quantity} {$inventory->unit} of {$inventory->name}",
                ]);
            }

            DB::commit();
            return back()->with('success', 'Inventory restocked and expense logged automatically.');
        } catch (\Exception $e) {
            DB::rollBack();
            return back()->withErrors(['error' => 'Failed to process restock.']);
        }
    }
}
