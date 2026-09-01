<?php

namespace App\Http\Controllers;

use App\Models\MenuCategory;
use App\Models\MenuItem;
use App\Models\MenuItemVariant;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

class MenuController extends Controller
{
    public function index()
    {
        $restaurantId = auth()->user()->restaurant_id;

        $categories = MenuCategory::where('restaurant_id', $restaurantId)->get();
        $menuItems = MenuItem::with(['category', 'ingredients', 'variants'])
            ->where('restaurant_id', $restaurantId)
            ->get();

        $inventory = \App\Models\Inventory::where('restaurant_id', $restaurantId)
            ->orderBy('name')
            ->get();

        $restaurant = auth()->user()->restaurant;

        return Inertia::render('Menu/Index', [
            'categories' => $categories,
            'menuItems' => $menuItems,
            'inventory' => $inventory,
            'currencySymbol' => $restaurant->currency_symbol ?? 'RS'
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
            'price' => 'nullable|numeric|min:0',
            'cost_price' => 'nullable|numeric|min:0',
            'stock_quantity' => 'required|integer|min:0',
            'image' => 'nullable|image|max:2048',
            'is_deal' => 'boolean',
            'has_variants' => 'boolean',
            'variants' => 'nullable|array',
            'variants.*.name' => 'required_with:variants|string|max:255',
            'variants.*.price' => 'required_with:variants|numeric|min:0',
            'variants.*.cost_price' => 'nullable|numeric|min:0',
            'ingredients' => 'nullable|array',
            'ingredients.*.id' => 'required|exists:inventory,id',
            'ingredients.*.quantity' => 'required|numeric|min:0.0001',
            'dealItems' => 'nullable|array',
            'dealItems.*.id' => 'required|exists:menu_items,id',
            'dealItems.*.variant_id' => 'nullable|exists:menu_item_variants,id',
            'dealItems.*.quantity' => 'required|integer|min:1',
        ]);

        DB::beginTransaction();
        try {
            $data = $request->except(['image', 'variants', 'has_variants']);
            $data['restaurant_id'] = auth()->user()->restaurant_id;

            // If variants are provided, set default price to first variant's price
            if ($request->has_variants && $request->has('variants') && count($request->variants) > 0) {
                $data['price'] = (float) $request->variants[0]['price'];
                $data['cost_price'] = (float) ($request->variants[0]['cost_price'] ?? 0);
            } else {
                $data['price'] = (float) ($request->price ?? 0);
                $data['cost_price'] = (float) ($request->cost_price ?? 0);
            }

            if ($request->hasFile('image')) {
                $data['image'] = $request->file('image')->store("restaurants/{$data['restaurant_id']}/menu", 'public');
                $fullPath = storage_path('app/public/' . $data['image']);
                @chmod($fullPath, 0644);
                @chmod(dirname($fullPath), 0755);
            }

            if ($request->is_deal && $request->has('dealItems')) {
                $data['cost_price'] = 0;
                foreach ($request->dealItems as $dealItem) {
                    if (!empty($dealItem['variant_id'])) {
                        $variant = MenuItemVariant::find($dealItem['variant_id']);
                        if ($variant) {
                            $data['cost_price'] += $variant->cost_price * $dealItem['quantity'];
                        }
                    } else {
                        $childItem = MenuItem::find($dealItem['id']);
                        if ($childItem) {
                            $data['cost_price'] += $childItem->cost_price * $dealItem['quantity'];
                        }
                    }
                }
            }

            $menuItem = MenuItem::create($data);

            // Handle variants creation
            if ($request->has_variants && $request->has('variants')) {
                foreach ($request->variants as $v) {
                    if (!empty($v['name']) && isset($v['price'])) {
                        MenuItemVariant::create([
                            'menu_item_id' => $menuItem->id,
                            'name' => trim($v['name']),
                            'price' => (float) $v['price'],
                            'cost_price' => (float) ($v['cost_price'] ?? 0),
                        ]);
                    }
                }
            }

            if ($request->is_deal && $request->has('dealItems')) {
                $syncData = [];
                foreach ($request->dealItems as $di) {
                    $syncData[$di['id']] = [
                        'quantity' => $di['quantity'],
                        'variant_id' => !empty($di['variant_id']) ? $di['variant_id'] : null,
                    ];
                }
                $menuItem->dealItems()->sync($syncData);
            } else if (!$request->is_deal && $request->has('ingredients')) {
                $syncData = [];
                foreach ($request->ingredients as $ing) {
                    $syncData[$ing['id']] = ['quantity' => $ing['quantity']];
                }
                $menuItem->ingredients()->sync($syncData);
            }

            DB::commit();
            return back()->with('message', 'Menu item added successfully.');
        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Store Item Error: ' . $e->getMessage());
            return back()->withErrors(['error' => 'Failed to store menu item.']);
        }
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
            'price' => 'nullable|numeric|min:0',
            'cost_price' => 'nullable|numeric|min:0',
            'stock_quantity' => 'required|integer|min:0',
            'image' => 'nullable|image|max:2048',
            'is_deal' => 'boolean',
            'has_variants' => 'boolean',
            'variants' => 'nullable|array',
            'variants.*.name' => 'required_with:variants|string|max:255',
            'variants.*.price' => 'required_with:variants|numeric|min:0',
            'variants.*.cost_price' => 'nullable|numeric|min:0',
            'ingredients' => 'nullable|array',
            'ingredients.*.id' => 'required|exists:inventory,id',
            'ingredients.*.quantity' => 'required|numeric|min:0.0001',
            'dealItems' => 'nullable|array',
            'dealItems.*.id' => 'required|exists:menu_items,id',
            'dealItems.*.variant_id' => 'nullable|exists:menu_item_variants,id',
            'dealItems.*.quantity' => 'required|integer|min:1',
        ]);

        DB::beginTransaction();
        try {
            $data = $request->except(['image', 'variants', 'has_variants']);

            if ($request->has_variants && $request->has('variants') && count($request->variants) > 0) {
                $data['price'] = (float) $request->variants[0]['price'];
                $data['cost_price'] = (float) ($request->variants[0]['cost_price'] ?? 0);
            } else {
                $data['price'] = (float) ($request->price ?? 0);
                $data['cost_price'] = (float) ($request->cost_price ?? 0);
            }

            if ($request->hasFile('image')) {
                if ($menuItem->image) {
                    Storage::disk('public')->delete($menuItem->image);
                }
                $data['image'] = $request->file('image')->store("restaurants/{$menuItem->restaurant_id}/menu", 'public');
                $fullPath = storage_path('app/public/' . $data['image']);
                @chmod($fullPath, 0644);
                @chmod(dirname($fullPath), 0755);
            }

            if ($request->is_deal && $request->has('dealItems')) {
                $data['cost_price'] = 0;
                foreach ($request->dealItems as $dealItem) {
                    if (!empty($dealItem['variant_id'])) {
                        $variant = MenuItemVariant::find($dealItem['variant_id']);
                        if ($variant) {
                            $data['cost_price'] += $variant->cost_price * $dealItem['quantity'];
                        }
                    } else {
                        $childItem = MenuItem::find($dealItem['id']);
                        if ($childItem) {
                            $data['cost_price'] += $childItem->cost_price * $dealItem['quantity'];
                        }
                    }
                }
            }

            $menuItem->update($data);

            // Handle variants sync
            $menuItem->variants()->delete();
            if ($request->has_variants && $request->has('variants')) {
                foreach ($request->variants as $v) {
                    if (!empty($v['name']) && isset($v['price'])) {
                        MenuItemVariant::create([
                            'menu_item_id' => $menuItem->id,
                            'name' => trim($v['name']),
                            'price' => (float) $v['price'],
                            'cost_price' => (float) ($v['cost_price'] ?? 0),
                        ]);
                    }
                }
            }

            if ($request->is_deal && $request->has('dealItems')) {
                $syncData = [];
                foreach ($request->dealItems as $di) {
                    $syncData[$di['id']] = [
                        'quantity' => $di['quantity'],
                        'variant_id' => !empty($di['variant_id']) ? $di['variant_id'] : null,
                    ];
                }
                $menuItem->dealItems()->sync($syncData);
                $menuItem->ingredients()->detach();
            } else if (!$request->is_deal && $request->has('ingredients')) {
                $syncData = [];
                foreach ($request->ingredients as $ing) {
                    $syncData[$ing['id']] = ['quantity' => $ing['quantity']];
                }
                $menuItem->ingredients()->sync($syncData);
                $menuItem->dealItems()->detach();
            }

            DB::commit();
            return back()->with('message', 'Menu item updated successfully.');
        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Update Item Error: ' . $e->getMessage());
            return back()->withErrors(['error' => 'Failed to update menu item.']);
        }
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
