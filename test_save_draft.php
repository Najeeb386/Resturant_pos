<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$kernel->bootstrap();

$user = App\Models\User::find(7);
auth()->login($user);

$restaurantId = $user->restaurant_id;

$order = App\Models\Order::create([
    'restaurant_id' => $restaurantId,
    'table_id' => null,
    'user_id' => $user->id,
    'order_type' => 'takeaway',
    'customer_name' => 'Test Draft',
    'status' => 'draft',
    'subtotal' => 400,
    'tax' => 12,
    'discount' => 0,
    'total' => 412,
]);

App\Models\OrderItem::create([
    'order_id' => $order->id,
    'menu_item_id' => 7,
    'quantity' => 1,
    'price' => 400,
]);

echo "Created Order ID: " . $order->id . " Status: " . $order->status . "\n";
