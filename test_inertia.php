<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$request = Illuminate\Http\Request::create('/dashboard', 'GET');
$user = \App\Models\User::find(2); // Owner
auth()->login($user);
$response = app()->handle($request);
dump($response->getContent());
