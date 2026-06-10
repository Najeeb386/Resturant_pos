<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$r = \App\Models\Restaurant::find(1);
dump($r->toArray());
$r->update(['tax_percentage' => 12]);
dump($r->fresh()->toArray());
