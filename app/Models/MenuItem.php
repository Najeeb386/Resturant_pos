<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MenuItem extends Model
{
    use \App\Traits\BelongsToRestaurant;

    protected $fillable = ['restaurant_id', 'category_id', 'name', 'description', 'price', 'cost_price', 'stock_quantity', 'image', 'available', 'is_deal'];

    protected $casts = [
        'available' => 'boolean',
        'is_deal' => 'boolean',
    ];

    public function restaurant()
    {
        return $this->belongsTo(Restaurant::class);
    }

    public function category()
    {
        return $this->belongsTo(MenuCategory::class, 'category_id');
    }

    public function ingredients()
    {
        return $this->belongsToMany(Inventory::class, 'menu_item_ingredients', 'menu_item_id', 'inventory_id')
                    ->withPivot('quantity')
                    ->withTimestamps();
    }

    public function dealItems()
    {
        return $this->belongsToMany(MenuItem::class, 'deal_items', 'deal_id', 'menu_item_id')
                    ->withPivot('quantity')
                    ->withTimestamps();
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }
}
