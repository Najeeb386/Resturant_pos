<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\POSController;
use App\Http\Controllers\API\TablesController;
use App\Http\Controllers\API\MenuController;
use App\Http\Controllers\API\KitchenController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);

    // POS routes
    Route::post('/pos/orders', [POSController::class, 'createOrder']);
    Route::get('/pos/orders', [POSController::class, 'getOrders']);
    Route::patch('/pos/orders/{id}/status', [POSController::class, 'updateOrderStatus']);

    // Tables routes
    Route::get('/tables', [TablesController::class, 'index']);
    Route::post('/tables', [TablesController::class, 'store']);
    Route::patch('/tables/{id}', [TablesController::class, 'update']);

    // Menu routes
    Route::get('/menu', [MenuController::class, 'index']);
    Route::post('/menu/categories', [MenuController::class, 'storeCategory']);
    Route::post('/menu/items', [MenuController::class, 'storeItem']);

    // Kitchen routes
    Route::get('/kitchen/orders', [KitchenController::class, 'getOrders']);
    Route::patch('/kitchen/orders/{orderId}/items/{itemId}', [KitchenController::class, 'updateOrderItemStatus']);
});