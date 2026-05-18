<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class TableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $restaurantId = 1;

        for ($i = 1; $i <= 10; $i++) {
            \DB::table('tables')->insert([
                'restaurant_id' => $restaurantId,
                'table_number' => 'T' . str_pad($i, 2, '0', STR_PAD_LEFT),
                'status' => 'available',
                'capacity' => rand(2, 6),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
