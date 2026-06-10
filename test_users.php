<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$users = \App\Models\User::all();
foreach($users as $user) {
    dump(['id' => $user->id, 'name' => $user->name, 'role_id' => $user->role_id, 'email' => $user->email]);
}
