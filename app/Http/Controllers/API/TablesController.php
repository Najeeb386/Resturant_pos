<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class TablesController extends Controller
{
    public function index(Request $request)
    {
        $tables = \App\Models\Table::where('restaurant_id', $request->restaurant_id)
            ->orderBy('table_number')
            ->get();

        return response()->json($tables);
    }

    public function store(Request $request)
    {
        $request->validate([
            'restaurant_id' => 'required|exists:restaurants,id',
            'table_number' => 'required|string|unique:tables,table_number,NULL,id,restaurant_id,' . $request->restaurant_id,
            'capacity' => 'required|integer|min:1',
        ]);

        $table = \App\Models\Table::create($request->all());

        return response()->json($table, 201);
    }

    public function update(Request $request, $id)
    {
        $table = \App\Models\Table::findOrFail($id);

        $request->validate([
            'status' => 'required|in:available,occupied,reserved,cleaning',
        ]);

        $table->update($request->only('status'));

        return response()->json($table);
    }
}
