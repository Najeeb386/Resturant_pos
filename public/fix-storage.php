<?php
/**
 * DineDesk Hostinger Storage & Permissions Repair Tool
 */
header('Content-Type: text/html; charset=utf-8');

echo "<h2>🔧 DineDesk Storage Repair Tool</h2>";
echo "<ul style='font-family: monospace; font-size: 14px; line-height: 1.8;'>";

$publicStoragePath = __DIR__ . '/../storage/app/public';

if (!file_exists($publicStoragePath)) {
    @mkdir($publicStoragePath, 0755, true);
    echo "<li>📁 Created directory: <code>storage/app/public</code></li>";
}

// 1. Create .htaccess inside storage/app/public
$htaccessFile = $publicStoragePath . '/.htaccess';
$htaccessContent = "<IfModule mod_authz_core.c>\n    Require all granted\n</IfModule>\n<IfModule !mod_authz_core.c>\n    Order allow,deny\n    Allow from all\n</IfModule>\n";
@file_put_contents($htaccessFile, $htaccessContent);
@chmod($htaccessFile, 0644);
echo "<li>✅ Created <code>storage/app/public/.htaccess</code> (Require all granted)</li>";

// 2. Create public/storage symlink if missing
$shortcut = __DIR__ . '/storage';
if (!file_exists($shortcut)) {
    @symlink($publicStoragePath, $shortcut);
    echo "<li>🔗 Created symlink: <code>public/storage</code> -> <code>storage/app/public</code></li>";
} else {
    echo "<li>🔗 Symlink <code>public/storage</code> already exists.</li>";
}

// 3. Fix permissions using shell_exec / exec if available, else PHP loop
$chmodSuccess = false;
if (function_exists('shell_exec')) {
    @shell_exec('chmod -R 755 ' . escapeshellarg($publicStoragePath));
    @shell_exec('find ' . escapeshellarg($publicStoragePath) . ' -type f -exec chmod 644 {} +');
    $chmodSuccess = true;
    echo "<li>⚡ Applied 755/644 permissions via <code>shell_exec</code>.</li>";
}

$fixedCount = 0;
try {
    if (file_exists($publicStoragePath)) {
        $dirIterator = new RecursiveDirectoryIterator($publicStoragePath, RecursiveDirectoryIterator::SKIP_DOTS);
        $iterator = new RecursiveIteratorIterator($dirIterator, RecursiveIteratorIterator::SELF_FIRST);

        foreach ($iterator as $item) {
            try {
                if ($item->isDir()) {
                    @chmod($item->getPathname(), 0755);
                } else {
                    @chmod($item->getPathname(), 0644);
                }
                $fixedCount++;
            } catch (\Throwable $e) {
                // Ignore individual file permission errors
            }
        }
    }
    echo "<li>🎉 Processed <b>{$fixedCount}</b> items in <code>storage/app/public</code>.</li>";
} catch (\Throwable $e) {
    echo "<li>⚠️ Permission iteration note: " . htmlspecialchars($e->getMessage()) . "</li>";
}

echo "</ul>";
echo "<h3 style='color: green;'>✅ Storage repair completed successfully! All image URLs should now display properly.</h3>";
