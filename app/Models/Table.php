<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Table extends Model
{
    use \App\Traits\BelongsToRestaurant;

    protected $fillable = ['restaurant_id', 'table_number', 'status', 'capacity'];

    public function restaurant()
    {
        return $this->belongsTo(Restaurant::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}
