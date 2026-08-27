<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (Schema::hasTable('orders') && !Schema::hasColumn('orders', 'is_updated')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->boolean('is_updated')->default(false)->after('status');
            });
        }

        if (Schema::hasTable('order_items') && !Schema::hasColumn('order_items', 'is_new')) {
            Schema::table('order_items', function (Blueprint $table) {
                $table->boolean('is_new')->default(false)->after('quantity');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('orders') && Schema::hasColumn('orders', 'is_updated')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->dropColumn('is_updated');
            });
        }

        if (Schema::hasTable('order_items') && Schema::hasColumn('order_items', 'is_new')) {
            Schema::table('order_items', function (Blueprint $table) {
                $table->dropColumn('is_new');
            });
        }
    }
};
