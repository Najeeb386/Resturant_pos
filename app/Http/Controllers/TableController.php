<?php

namespace App\Http\Controllers;

use App\Models\Table;
use Illuminate\Http\Request;
use Inertia\Inertia;

class TableController extends Controller
{
    public function index()
    {
        $restaurantId = auth()->user()->restaurant_id;
        $tables = Table::where('restaurant_id', $restaurantId)->get();
        return Inertia::render('Tables', [
            'tables' => $tables
        ]);
    }

    public function store(Request $request)
    {
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
        if ($table->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $table->delete();

        return redirect()->back()->with('message', 'Table deleted successfully.');
    }
}
