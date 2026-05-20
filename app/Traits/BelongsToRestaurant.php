<?php

namespace App\Traits;

use Illuminate\Database\Eloquent\Builder;

trait BelongsToRestaurant
{
    protected static function bootBelongsToRestaurant()
    {
        static::addGlobalScope('restaurant', function (Builder $builder) {
            if (auth()->hasUser()) {
                $user = auth()->user();
                // Super admins (role 1) see everything, others are scoped to their restaurant
                if ($user && $user->role_id !== 1 && $user->restaurant_id) {
                    // Specify the table name to avoid ambiguous column errors in joins
                    $table = $builder->getModel()->getTable();
                    $builder->where($table . '.restaurant_id', $user->restaurant_id);
                }
            }
        });
    }
}
