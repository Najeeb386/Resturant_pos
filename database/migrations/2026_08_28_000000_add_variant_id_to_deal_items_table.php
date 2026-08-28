<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('deal_items') && !Schema::hasColumn('deal_items', 'variant_id')) {
            Schema::table('deal_items', function (Blueprint $table) {
                $table->foreignId('variant_id')->nullable()->after('menu_item_id')->constrained('menu_item_variants')->onDelete('cascade');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('deal_items') && Schema::hasColumn('deal_items', 'variant_id')) {
            Schema::table('deal_items', function (Blueprint $table) {
                $table->dropForeign(['variant_id']);
                $table->dropColumn('variant_id');
            });
        }
    }
};
