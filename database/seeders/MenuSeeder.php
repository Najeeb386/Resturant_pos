<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class MenuSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $restaurantId = 1;

        // Categories
        \DB::table('menu_categories')->insert([
            [
                'restaurant_id' => $restaurantId,
                'name' => 'Appetizers',
                'description' => 'Starters and small plates',
                'sort_order' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'restaurant_id' => $restaurantId,
                'name' => 'Main Courses',
                'description' => 'Hearty main dishes',
                'sort_order' => 2,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'restaurant_id' => $restaurantId,
                'name' => 'Beverages',
                'description' => 'Drinks and refreshments',
                'sort_order' => 3,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        // Items
        \DB::table('menu_items')->insert([
            [
                'restaurant_id' => $restaurantId,
                'category_id' => 1, // Appetizers
                'name' => 'Chicken Wings',
                'description' => 'Spicy chicken wings with fries',
                'price' => 250.00,
                'available' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'restaurant_id' => $restaurantId,
                'category_id' => 1,
                'name' => 'Mozzarella Sticks',
                'description' => 'Crispy cheese sticks',
                'price' => 180.00,
                'available' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'restaurant_id' => $restaurantId,
                'category_id' => 2, // Main Courses
                'name' => 'Grilled Chicken Burger',
                'description' => 'Juicy chicken burger with lettuce and tomato',
                'price' => 320.00,
                'available' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'restaurant_id' => $restaurantId,
                'category_id' => 2,
                'name' => 'Vegetable Pizza',
                'description' => 'Fresh vegetables on thin crust',
                'price' => 280.00,
                'available' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'restaurant_id' => $restaurantId,
                'category_id' => 3, // Beverages
                'name' => 'Coca Cola',
                'description' => 'Classic cola drink',
                'price' => 50.00,
                'available' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'restaurant_id' => $restaurantId,
                'category_id' => 3,
                'name' => 'Fresh Orange Juice',
                'description' => 'Freshly squeezed orange juice',
                'price' => 120.00,
                'available' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
