<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Restaurant extends Model
{
    protected $fillable = [
        'name', 'address', 'phone', 'email', 'gst_number', 'currency', 
        'currency_symbol', 'tax_percentage', 'logo', 'receipt_header', 'receipt_footer', 'kitchen_bypass', 'payment_methods'
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

    public function hasFeature(string $feature): bool
    {
        $subscription = $this->subscription()->with('plan')->first();
        if (!$subscription) {
            return true; // Default fallback if no subscription record
        }
        if ($subscription->status !== 'active') {
            return false;
        }
        
        $plan = $subscription->plan;
        return $plan ? $plan->hasFeature($feature) : false;
    }
}
