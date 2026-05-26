<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
// Bootstrap the application to load db connection
$kernel->bootstrap();

$request = Illuminate\Http\Request::create('/pos/draft', 'POST', [
    'order_type' => 'takeaway',
    'cart' => [
        ['id' => 7, 'qty' => 1, 'price' => 400]
    ],
    'subtotal' => 400,
    'tax' => 12,
    'total' => 412
]);

$user = App\Models\User::find(7); // User ID 7 from earlier tinker output
$request->setUserResolver(function () use ($user) {
    return $user;
});
auth()->login($user);

// Bypass VerifyCsrfToken by replacing it in container
$app->instance(\Illuminate\Foundation\Http\Middleware\VerifyCsrfToken::class, new class extends \Illuminate\Foundation\Http\Middleware\VerifyCsrfToken {
    public function __construct(){}
    public function handle($request, \Closure $next) { return $next($request); }
});

$response = $kernel->handle($request);
echo "Status: " . $response->getStatusCode() . "\n";
echo "Content: " . $response->getContent() . "\n";
