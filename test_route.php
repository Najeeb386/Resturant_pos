<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$request = Illuminate\Http\Request::create('/dashboard', 'GET');
$user = \App\Models\User::find(5); // Kitchen staff
auth()->login($user);
$response = app()->handle($request);
dump($response->getStatusCode());
if ($response->getStatusCode() === 500) {
    dump($response->getContent());
}
