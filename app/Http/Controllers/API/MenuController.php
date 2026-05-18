<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class MenuController extends Controller
{
    public function index(Request $request)
    {
        $categories = \App\Models\MenuCategory::where('restaurant_id', $request->restaurant_id)
            ->with('menuItems')
            ->orderBy('sort_order')
            ->get();

        return response()->json($categories);
    }

    public function storeCategory(Request $request)
    {
        $request->validate([
            'restaurant_id' => 'required|exists:restaurants,id',
            'name' => 'required|string',
            'description' => 'nullable|string',
        ]);

        $category = \App\Models\MenuCategory::create($request->all());

        return response()->json($category, 201);
    }

    public function storeItem(Request $request)
    {
        $request->validate([
            'restaurant_id' => 'required|exists:restaurants,id',
            'category_id' => 'required|exists:menu_categories,id',
            'name' => 'required|string',
            'price' => 'required|numeric|min:0',
            'description' => 'nullable|string',
            'available' => 'boolean',
        ]);

        $item = \App\Models\MenuItem::create($request->all());

        return response()->json($item, 201);
    }
}
