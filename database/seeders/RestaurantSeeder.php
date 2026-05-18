<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class RestaurantSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \DB::table('restaurants')->insert([
            [
                'name' => 'Tasty Station',
                'address' => '123 Main Street, City, State 12345',
                'phone' => '+1-234-567-8900',
                'email' => 'contact@tastystation.com',
                'gst_number' => 'GST123456789',
                'currency' => 'INR',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
