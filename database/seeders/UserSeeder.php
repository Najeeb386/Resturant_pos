<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $restaurantId = 1; // Assuming the restaurant ID is 1

        \DB::table('users')->insert([
            [
                'name' => 'Super Admin',
                'email' => 'admin@tastystation.com',
                'password' => \Hash::make('password'),
                'role_id' => 1, // Super Admin
                'restaurant_id' => null, // Super admin can access all
                'email_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Restaurant Owner',
                'email' => 'owner@tastystation.com',
                'password' => \Hash::make('password'),
                'role_id' => 2, // Restaurant Owner
                'restaurant_id' => $restaurantId,
                'email_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Cashier User',
                'email' => 'cashier@tastystation.com',
                'password' => \Hash::make('password'),
                'role_id' => 3, // Cashier
                'restaurant_id' => $restaurantId,
                'email_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Waiter User',
                'email' => 'waiter@tastystation.com',
                'password' => \Hash::make('password'),
                'role_id' => 4, // Waiter
                'restaurant_id' => $restaurantId,
                'email_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Kitchen Staff',
                'email' => 'kitchen@tastystation.com',
                'password' => \Hash::make('password'),
                'role_id' => 5, // Kitchen Staff
                'restaurant_id' => $restaurantId,
                'email_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Delivery Rider',
                'email' => 'rider@tastystation.com',
                'password' => \Hash::make('password'),
                'role_id' => 6, // Delivery Rider
                'restaurant_id' => $restaurantId,
                'email_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
