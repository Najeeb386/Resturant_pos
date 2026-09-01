<?php

namespace App\Http\Controllers;

use App\Models\Table;
use Illuminate\Http\Request;
use Inertia\Inertia;

class TableController extends Controller
{
    public function index()
    {
        $user = auth()->user();
        $restaurant = $user->restaurant;
        $tables = Table::where('restaurant_id', $user->restaurant_id)->get();
        $hasQrOrdering = $restaurant ? $restaurant->hasFeature('qr_ordering') : true;

        return Inertia::render('Tables', [
            'tables' => $tables,
            'hasQrOrdering' => $hasQrOrdering,
            'restaurant' => $restaurant ? [
                'id' => $restaurant->id,
                'name' => $restaurant->name,
                'logo' => $restaurant->logo,
                'currency_symbol' => $restaurant->currency_symbol ?? '$',
            ] : null,
        ]);
    }

    public function store(Request $request)
    {
        if (auth()->user()->role_id !== 2) abort(403, 'Unauthorized action.');

        $request->validate([
            'table_number' => 'required|string|max:255',
            'capacity' => 'required|integer|min:1',
            'status' => 'required|in:available,occupied,reserved,cleaning',
        ]);

        Table::create([
            'restaurant_id' => auth()->user()->restaurant_id,
            'table_number' => $request->table_number,
            'capacity' => $request->capacity,
            'status' => $request->status,
        ]);

        return redirect()->back()->with('message', 'Table created successfully.');
    }

    public function update(Request $request, Table $table)
    {
        if (auth()->user()->role_id !== 2) abort(403, 'Unauthorized action.');

        if ($table->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $request->validate([
            'table_number' => 'required|string|max:255',
            'capacity' => 'required|integer|min:1',
            'status' => 'required|in:available,occupied,reserved,cleaning',
        ]);

        $table->update($request->only('table_number', 'capacity', 'status'));

        return redirect()->back()->with('message', 'Table updated successfully.');
    }

    public function destroy(Table $table)
    {
        if (auth()->user()->role_id !== 2) abort(403, 'Unauthorized action.');

        if ($table->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $table->delete();

        return redirect()->back()->with('message', 'Table deleted successfully.');
    }
}
