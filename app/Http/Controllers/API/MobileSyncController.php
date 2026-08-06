<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\MenuCategory;
use App\Models\MenuItem;
use App\Models\Table;
use App\Models\Inventory;
use App\Models\Expense;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class MobileSyncController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        if ($user->role_id === 1) {
            return response()->json(['message' => 'Super Admins must use the Admin Portal.'], 403);
        }

        $token = $user->createToken('DineDeskMobileToken')->plainTextToken;

        return response()->json([
            'success' => true,
            'token' => $token,
            'user' => $user->load('restaurant'),
        ]);
    }

    public function bootstrap(Request $request)
    {
        $user = $request->user();
        $restaurantId = $user->restaurant_id;

        $categories = MenuCategory::where('restaurant_id', $restaurantId)->get();
        $menuItems = MenuItem::with(['category', 'ingredients', 'variants'])
            ->where('restaurant_id', $restaurantId)
            ->get();
        $tables = Table::where('restaurant_id', $restaurantId)->get();
        $inventory = Inventory::where('restaurant_id', $restaurantId)->get();
        $expenses = Expense::where('restaurant_id', $restaurantId)->latest()->limit(50)->get();
        $orders = Order::with(['orderItems.menuItem', 'table'])
            ->where('restaurant_id', $restaurantId)
            ->latest()
            ->limit(50)
            ->get();

        return response()->json([
            'success' => true,
            'restaurant' => $user->restaurant,
            'categories' => $categories,
            'menu_items' => $menuItems,
            'tables' => $tables,
            'inventory' => $inventory,
            'expenses' => $expenses,
            'orders' => $orders,
        ]);
    }

    public function syncOrders(Request $request)
    {
        $user = $request->user();
        $restaurantId = $user->restaurant_id;
        $offlineOrders = $request->input('orders', []);

        $syncedResults = [];

        DB::beginTransaction();
        try {
            foreach ($offlineOrders as $offlineOrder) {
                $localId = $offlineOrder['local_id'] ?? null;
                $serverId = $offlineOrder['server_id'] ?? $offlineOrder['id'] ?? null;

                // 1. If server_id exists, order is already created on server - just update status
                if ($serverId) {
                    $existingOrder = Order::where('restaurant_id', $restaurantId)->find($serverId);
                    if ($existingOrder) {
                        $existingOrder->update([
                            'status' => $offlineOrder['status'] ?? $existingOrder->status,
                            'payment_status' => $offlineOrder['payment_status'] ?? $existingOrder->payment_status,
                        ]);
                        $syncedResults[] = [
                            'local_id' => $localId,
                            'server_id' => $existingOrder->id,
                            'created_at' => $existingOrder->created_at,
                        ];
                        continue;
                    }
                }

                // 2. Check if local_id already synced previously
                if ($localId) {
                    $existingByLocalId = Order::where('restaurant_id', $restaurantId)
                        ->where('notes', 'LIKE', "%[LOCAL_ID:{$localId}]%")
                        ->first();
                    if ($existingByLocalId) {
                        $existingByLocalId->update([
                            'status' => $offlineOrder['status'] ?? $existingByLocalId->status,
                            'payment_status' => $offlineOrder['payment_status'] ?? $existingByLocalId->payment_status,
                        ]);
                        $syncedResults[] = [
                            'local_id' => $localId,
                            'server_id' => $existingByLocalId->id,
                            'created_at' => $existingByLocalId->created_at,
                        ];
                        continue;
                    }
                }

                $notes = trim(($offlineOrder['notes'] ?? '') . ($localId ? " [LOCAL_ID:{$localId}]" : ''));

                $order = Order::create([
                    'restaurant_id' => $restaurantId,
                    'user_id' => $user->id,
                    'table_id' => $offlineOrder['table_id'] ?? null,
                    'order_type' => $offlineOrder['order_type'] ?? 'takeaway',
                    'customer_name' => $offlineOrder['customer_name'] ?? 'Walk-in',
                    'customer_phone' => $offlineOrder['customer_phone'] ?? null,
                    'delivery_address' => $offlineOrder['delivery_address'] ?? null,
                    'subtotal' => $offlineOrder['subtotal'] ?? 0,
                    'tax' => $offlineOrder['tax'] ?? 0,
                    'delivery_fee' => $offlineOrder['delivery_fee'] ?? 0,
                    'total' => $offlineOrder['total'] ?? 0,
                    'payment_method' => $offlineOrder['payment_method'] ?? 'Cash',
                    'payment_status' => $offlineOrder['payment_status'] ?? 'paid',
                    'status' => $offlineOrder['status'] ?? 'completed',
                    'notes' => $notes,
                ]);

                if (isset($offlineOrder['items']) && is_array($offlineOrder['items'])) {
                    foreach ($offlineOrder['items'] as $item) {
                        $menuItemId = $item['menu_item_id'] ?? $item['id'];
                        $qty = $item['quantity'] ?? $item['qty'] ?? 1;
                        $price = $item['price'] ?? 0;

                        OrderItem::create([
                            'order_id' => $order->id,
                            'menu_item_id' => $menuItemId,
                            'quantity' => $qty,
                            'price' => $price,
                            'notes' => $item['name'] ?? null,
                        ]);

                        // Deduct stock if tracked
                        $menuItem = MenuItem::find($menuItemId);
                        if ($menuItem && $menuItem->stock_quantity !== null) {
                            $menuItem->decrement('stock_quantity', $qty);
                        }
                    }
                }

                $syncedResults[] = [
                    'local_id' => $offlineOrder['local_id'] ?? null,
                    'server_id' => $order->id,
                    'created_at' => $order->created_at,
                ];
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Offline orders synced successfully.',
                'synced' => $syncedResults,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Sync failed: ' . $e->getMessage(),
            ], 500);
        }
    }
}
