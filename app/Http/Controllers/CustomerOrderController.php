<?php

namespace App\Http\Controllers;

use App\Models\MenuCategory;
use App\Models\MenuItem;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Restaurant;
use App\Models\Table;
use App\Models\User;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Str;

class CustomerOrderController extends Controller
{
    /**
     * Display the digital menu for a specific restaurant and table.
     */
    public function showMenu($restaurantId, $tableId)
    {
        $restaurant = Restaurant::findOrFail($restaurantId);
        $table = Table::where('restaurant_id', $restaurantId)->where('id', $tableId)->firstOrFail();

        $hasQrOrdering = $restaurant->hasFeature('qr_ordering');
        $has3dFeature = $restaurant->hasFeature('ai_3d_scanner');

        $categories = MenuCategory::where('restaurant_id', $restaurantId)
            ->with(['menuItems' => function ($q) {
                $q->where('available', true)
                  ->where(function ($sub) {
                      $sub->whereNull('stock_quantity')
                          ->orWhere('stock_quantity', '>', 0);
                  });
            }])
            ->get();

        return Inertia::render('CustomerQR/Menu', [
            'restaurant' => [
                'id' => $restaurant->id,
                'name' => $restaurant->name,
                'logo' => $restaurant->logo,
                'phone' => $restaurant->phone,
                'address' => $restaurant->address,
                'currency_symbol' => $restaurant->currency_symbol ?? '$',
                'tax_percentage' => (float)($restaurant->tax_percentage ?? 0),
                'primary_color' => $restaurant->primary_color ?? '#f97316',
            ],
            'table' => [
                'id' => $table->id,
                'table_number' => $table->table_number,
                'capacity' => $table->capacity,
                'status' => $table->status,
            ],
            'categories' => $categories,
            'hasQrOrdering' => $hasQrOrdering,
            'has3dFeature' => $has3dFeature,
        ]);
    }

    /**
     * Submit a customer order from the QR menu.
     */
    public function storeOrder(Request $request)
    {
        $request->validate([
            'restaurant_id' => 'required|exists:restaurants,id',
            'table_id' => 'required|exists:tables,id',
            'customer_name' => 'nullable|string|max:255',
            'customer_phone' => 'nullable|string|max:50',
            'notes' => 'nullable|string|max:500',
            'items' => 'required|array|min:1',
            'items.*.menu_item_id' => 'required|exists:menu_items,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.variant_name' => 'nullable|string',
            'items.*.unit_price' => 'required|numeric|min:0',
            'items.*.notes' => 'nullable|string',
        ]);

        $restaurant = Restaurant::findOrFail($request->restaurant_id);
        $table = Table::where('restaurant_id', $restaurant->id)->where('id', $request->table_id)->firstOrFail();

        if (!$restaurant->hasFeature('qr_ordering')) {
            return back()->withErrors(['message' => 'QR Ordering is not enabled for this restaurant.']);
        }

        // Check if an open bill already exists for this table
        $existingOrder = Order::where('restaurant_id', $restaurant->id)
            ->where('table_id', $table->id)
            ->where('payment_status', 'unpaid')
            ->whereIn('status', ['draft', 'pending', 'preparing'])
            ->latest()
            ->first();

        $addedSubtotal = 0;
        foreach ($request->items as $item) {
            $addedSubtotal += ($item['unit_price'] * $item['quantity']);
        }

        $taxPercentage = (float)($restaurant->tax_percentage ?? 0);

        if ($existingOrder) {
            $order = $existingOrder;
            $newSubtotal = (float)$order->subtotal + $addedSubtotal;
            $newTax = round(($newSubtotal * $taxPercentage) / 100, 2);
            $newTotal = $newSubtotal + $newTax;

            $order->update([
                'order_type' => 'dine_in',
                'customer_name' => $request->customer_name ?: ($order->customer_name ?: 'Table ' . $table->table_number . ' Guest'),
                'customer_phone' => $request->customer_phone ?: $order->customer_phone,
                'subtotal' => $newSubtotal,
                'tax' => $newTax,
                'total' => $newTotal,
                'status' => 'pending',
                'is_updated' => true,
                'updated_at' => now(),
            ]);
        } else {
            $taxAmount = round(($addedSubtotal * $taxPercentage) / 100, 2);
            $totalAmount = $addedSubtotal + $taxAmount;
            $orderNumber = 'QR-' . strtoupper(Str::random(6));

            $staffUserId = auth()->id() ?? User::where('restaurant_id', $restaurant->id)->value('id');

            $order = Order::create([
                'restaurant_id' => $restaurant->id,
                'table_id' => $table->id,
                'user_id' => $staffUserId,
                'order_type' => 'dine_in',
                'order_number' => $orderNumber,
                'customer_name' => $request->customer_name ?: ('Table ' . $table->table_number . ' Guest'),
                'customer_phone' => $request->customer_phone,
                'subtotal' => $addedSubtotal,
                'tax' => $taxAmount,
                'total' => $totalAmount,
                'status' => 'pending',
                'payment_status' => 'unpaid',
                'payment_method' => 'cash',
                'notes' => $request->notes,
                'is_updated' => true,
            ]);
        }

        foreach ($request->items as $item) {
            $itemTotal = $item['unit_price'] * $item['quantity'];
            $menuItem = MenuItem::find($item['menu_item_id']);

            OrderItem::create([
                'order_id' => $order->id,
                'menu_item_id' => $item['menu_item_id'],
                'quantity' => $item['quantity'],
                'is_new' => true,
                'price' => $item['unit_price'],
                'cost_price' => $menuItem ? $menuItem->cost_price : 0,
                'notes' => $item['notes'] ?? ($item['variant_name'] ?? null),
            ]);

            if ($menuItem && $menuItem->stock_quantity > 0) {
                $decrementAmount = min($item['quantity'], $menuItem->stock_quantity);
                $menuItem->decrement('stock_quantity', $decrementAmount);
            }
        }

        // Mark table as occupied
        $table->update(['status' => 'occupied']);

        return back()->with([
            'success' => 'Order placed successfully!',
            'order' => [
                'id' => $order->id,
                'order_number' => $order->order_number,
                'total' => $order->total,
                'created_at' => $order->created_at->format('h:i A'),
            ]
        ]);
    }
}
