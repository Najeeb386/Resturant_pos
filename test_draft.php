<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$request = Illuminate\Http\Request::create('/pos/draft', 'POST', [
    'order_type' => 'takeaway',
    'cart' => [
        ['id' => 7, 'qty' => 1, 'price' => 400]
    ],
    'subtotal' => 400,
    'tax' => 12,
    'total' => 412
]);

// Since /pos is under auth middleware, we need to bypass auth or login
$user = App\Models\User::find(7); // User ID 7 from earlier tinker output
$request->setUserResolver(function () use ($user) {
    return $user;
});

// We need to bypass CSRF, so we use withoutMiddleware on Kernel or just skip it
// For a test, we can just login the user
auth()->login($user);

$response = $kernel->handle($request);
echo "Status: " . $response->getStatusCode() . "\n";
echo "Content: " . $response->getContent() . "\n";
