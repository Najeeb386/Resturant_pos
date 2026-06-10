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
        $menuItems = MenuItem::with(['category', 'ingredients'])
            ->where('restaurant_id', $restaurantId)
            ->get();

        $inventory = \App\Models\Inventory::where('restaurant_id', $restaurantId)
            ->orderBy('name')
            ->get();

        return Inertia::render('Menu/Index', [
            'categories' => $categories,
            'menuItems' => $menuItems,
            'inventory' => $inventory
        ]);
    }

    public function storeCategory(Request $request)
    {
        if (auth()->user()->role_id !== 2) abort(403, 'Unauthorized action.');

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
        if (auth()->user()->role_id !== 2) abort(403, 'Unauthorized action.');
        if ($category->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }
        $category->delete();
        return back()->with('message', 'Category deleted successfully.');
    }

    public function storeItem(Request $request)
    {
        if (auth()->user()->role_id !== 2) abort(403, 'Unauthorized action.');

        $request->validate([
            'category_id' => 'required|exists:menu_categories,id',
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'cost_price' => 'nullable|numeric|min:0',
            'stock_quantity' => 'required|integer|min:0',
            'image' => 'nullable|image|max:2048',
            'is_deal' => 'boolean',
            'ingredients' => 'nullable|array',
            'ingredients.*.id' => 'required|exists:inventory,id',
            'ingredients.*.quantity' => 'required|numeric|min:0.0001',
            'dealItems' => 'nullable|array',
            'dealItems.*.id' => 'required|exists:menu_items,id',
            'dealItems.*.quantity' => 'required|integer|min:1',
        ]);

        $data = $request->except('image');
        $data['restaurant_id'] = auth()->user()->restaurant_id;

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store("restaurants/{$data['restaurant_id']}/menu", 'public');
        }

        if ($request->is_deal && $request->has('dealItems')) {
            $data['cost_price'] = 0;
            foreach ($request->dealItems as $dealItem) {
                $childItem = MenuItem::find($dealItem['id']);
                if ($childItem) {
                    $data['cost_price'] += $childItem->cost_price * $dealItem['quantity'];
                }
            }
        }

        $menuItem = MenuItem::create($data);

        if ($request->is_deal && $request->has('dealItems')) {
            $syncData = [];
            foreach ($request->dealItems as $di) {
                $syncData[$di['id']] = ['quantity' => $di['quantity']];
            }
            $menuItem->dealItems()->sync($syncData);
        } else if (!$request->is_deal && $request->has('ingredients')) {
            $syncData = [];
            foreach ($request->ingredients as $ing) {
                $syncData[$ing['id']] = ['quantity' => $ing['quantity']];
            }
            $menuItem->ingredients()->sync($syncData);
        }

        return back()->with('message', 'Menu item added successfully.');
    }

    public function updateItem(Request $request, MenuItem $menuItem)
    {
        if (auth()->user()->role_id !== 2) abort(403, 'Unauthorized action.');

        if ($menuItem->restaurant_id !== auth()->user()->restaurant_id) {
            abort(403);
        }

        $request->validate([
            'category_id' => 'required|exists:menu_categories,id',
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'cost_price' => 'nullable|numeric|min:0',
            'stock_quantity' => 'required|integer|min:0',
            'image' => 'nullable|image|max:2048',
            'is_deal' => 'boolean',
            'ingredients' => 'nullable|array',
            'ingredients.*.id' => 'required|exists:inventory,id',
            'ingredients.*.quantity' => 'required|numeric|min:0.0001',
            'dealItems' => 'nullable|array',
            'dealItems.*.id' => 'required|exists:menu_items,id',
            'dealItems.*.quantity' => 'required|integer|min:1',
        ]);

        $data = $request->except('image');

        if ($request->hasFile('image')) {
            if ($menuItem->image) {
                Storage::disk('public')->delete($menuItem->image);
            }
            $data['image'] = $request->file('image')->store("restaurants/{$menuItem->restaurant_id}/menu", 'public');
        }

        if ($request->is_deal && $request->has('dealItems')) {
            $data['cost_price'] = 0;
            foreach ($request->dealItems as $dealItem) {
                $childItem = MenuItem::find($dealItem['id']);
                if ($childItem) {
                    $data['cost_price'] += $childItem->cost_price * $dealItem['quantity'];
                }
            }
        }

        $menuItem->update($data);

        if ($request->is_deal && $request->has('dealItems')) {
            $syncData = [];
            foreach ($request->dealItems as $di) {
                $syncData[$di['id']] = ['quantity' => $di['quantity']];
            }
            $menuItem->dealItems()->sync($syncData);
            $menuItem->ingredients()->detach(); // Clear ingredients if converted to deal
        } else if (!$request->is_deal && $request->has('ingredients')) {
            $syncData = [];
            foreach ($request->ingredients as $ing) {
                $syncData[$ing['id']] = ['quantity' => $ing['quantity']];
            }
            $menuItem->ingredients()->sync($syncData);
            $menuItem->dealItems()->detach(); // Clear deal items if converted to regular item
        }

        return back()->with('message', 'Menu item updated successfully.');
    }

    public function destroyItem(MenuItem $menuItem)
    {
        if (auth()->user()->role_id !== 2) abort(403, 'Unauthorized action.');

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
