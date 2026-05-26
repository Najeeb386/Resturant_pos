<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Order;
use App\Models\Restaurant;

class PosTest extends TestCase
{
    public function test_save_draft()
    {
        $user = User::find(7);
        $this->actingAs($user);

        $response = $this->postJson('/pos/draft', [
            'order_type' => 'takeaway',
            'cart' => [
                ['id' => 7, 'qty' => 1, 'price' => 400]
            ],
            'subtotal' => 400,
            'tax' => 12,
            'total' => 412,
            'table_id' => null,
            'customer_name' => 'Test User',
            'order_id' => null
        ]);

        echo "STATUS: " . $response->getStatusCode() . "\n";
        echo "RESPONSE: " . $response->getContent() . "\n";
        
        $order = Order::latest()->first();
        if ($order) {
            echo "NEW ORDER ID: " . $order->id . " STATUS: " . $order->status . "\n";
        } else {
            echo "NO ORDER CREATED!\n";
        }
    }
}
