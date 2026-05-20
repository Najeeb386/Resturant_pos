<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Inventory extends Model
{
    use \App\Traits\BelongsToRestaurant;

    protected $fillable = ['restaurant_id', 'name', 'unit', 'quantity', 'min_quantity', 'expiry_date'];

    protected $casts = [
        'quantity' => 'decimal:2',
        'min_quantity' => 'decimal:2',
        'expiry_date' => 'date',
    ];

    public function restaurant()
    {
        return $this->belongsTo(Restaurant::class);
    }
}
