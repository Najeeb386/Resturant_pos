<?php

namespace App\Http\Controllers;

use App\Models\MenuCategory;
use App\Models\MenuItem;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\Storage;

class MenuController extends Controller
{
    public function index()
    {
        $restaurantId = auth()->user()->restaurant_id;

        $categories = MenuCategory::where('restaurant_id', $restaurantId)->get();
        $menuItems = MenuItem::with('category')->where('restaurant_id', $restaurantId)->get();

        return Inertia::render('Menu/Index', [
            'categories' => $categories,
            'menuItems' => $menuItems
        ]);
    }

    public function storeCategory(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string'
        ]);

        MenuCategory::create([
            'restaurant_id' => auth()->user()->restaurant_id,
            'name' => $request->name,
            'description' => $request->description
        ]);

        return back()->with('message', 'Category added successfully.');
    }

    public function destroyCategory(MenuCategory $category)
    {
        if ($category->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }
        $category->delete();
        return back()->with('message', 'Category deleted successfully.');
    }

    public function storeItem(Request $request)
    {
        $request->validate([
            'category_id' => 'required|exists:menu_categories,id',
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock_quantity' => 'required|integer|min:0',
            'image' => 'nullable|image|max:2048'
        ]);

        $data = $request->except('image');
        $data['restaurant_id'] = auth()->user()->restaurant_id;

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store("restaurants/{$data['restaurant_id']}/menu", 'public');
        }

        MenuItem::create($data);

        return back()->with('message', 'Menu item added successfully.');
    }

    public function updateItem(Request $request, MenuItem $menuItem)
    {
        if ($menuItem->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $request->validate([
            'category_id' => 'required|exists:menu_categories,id',
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock_quantity' => 'required|integer|min:0',
            'image' => 'nullable|image|max:2048'
        ]);

        $data = $request->except('image');

        if ($request->hasFile('image')) {
            if ($menuItem->image) {
                Storage::disk('public')->delete($menuItem->image);
            }
            $data['image'] = $request->file('image')->store("restaurants/{$menuItem->restaurant_id}/menu", 'public');
        }

        $menuItem->update($data);

        return back()->with('message', 'Menu item updated successfully.');
    }

    public function destroyItem(MenuItem $menuItem)
    {
        if ($menuItem->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        if ($menuItem->image) {
            Storage::disk('public')->delete($menuItem->image);
        }

        $menuItem->delete();

        return back()->with('message', 'Menu item deleted successfully.');
    }
}
