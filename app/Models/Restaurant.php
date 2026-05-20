<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Restaurant extends Model
{
    protected $fillable = [
        'name', 'address', 'phone', 'email', 'gst_number', 'currency', 
        'currency_symbol', 'tax_percentage', 'logo', 'receipt_header', 'receipt_footer'
    ];

    public function users()
    {
        return $this->hasMany(User::class);
    }

    public function tables()
    {
        return $this->hasMany(Table::class);
    }

    public function menuCategories()
    {
        return $this->hasMany(MenuCategory::class);
    }

    public function menuItems()
    {
        return $this->hasMany(MenuItem::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function inventory()
    {
        return $this->hasMany(Inventory::class);
    }

    public function subscription()
    {
        return $this->hasOne(Subscription::class);
    }
}
