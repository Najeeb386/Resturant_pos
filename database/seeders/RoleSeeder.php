<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \DB::table('roles')->insert([
            ['name' => 'Super Admin'],
            ['name' => 'Restaurant Owner'],
            ['name' => 'Cashier'],
            ['name' => 'Waiter'],
            ['name' => 'Kitchen Staff'],
            ['name' => 'Delivery Rider'],
        ]);
    }
}
