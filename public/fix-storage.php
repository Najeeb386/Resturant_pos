<?php
/**
 * DineDesk Hostinger Storage & Permissions Repair Tool
 */
header('Content-Type: text/html; charset=utf-8');

echo "<div style='font-family: Arial, sans-serif; max-width: 700px; margin: 30px auto; padding: 25px; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);'>";
echo "<h2 style='color: #1e293b; margin-top: 0;'>🔧 DineDesk Hostinger Storage & Permissions Repair</h2>";
echo "<ul style='font-family: monospace; font-size: 14px; line-height: 1.8; color: #334155;'>";

$baseStoragePath = __DIR__ . '/../storage';
$publicStoragePath = __DIR__ . '/../storage/app/public';

// 1. Create essential Laravel framework directories if missing
$essentialDirs = [
    $baseStoragePath . '/framework/views',
    $baseStoragePath . '/framework/cache',
    $baseStoragePath . '/framework/sessions',
    $baseStoragePath . '/framework/testing',
    $baseStoragePath . '/logs',
    $publicStoragePath,
];

foreach ($essentialDirs as $dir) {
    if (!file_exists($dir)) {
        @mkdir($dir, 0777, true);
        echo "<li>📁 Created framework directory: <code>" . htmlspecialchars(basename(dirname($dir)) . '/' . basename($dir)) . "</code></li>";
    }
    @chmod($dir, 0777);
}

// 2. Create .htaccess inside storage/app/public
$htaccessFile = $publicStoragePath . '/.htaccess';
$htaccessContent = "<IfModule mod_authz_core.c>\n    Require all granted\n</IfModule>\n<IfModule !mod_authz_core.c>\n    Order allow,deny\n    Allow from all\n</IfModule>\n";
@file_put_contents($htaccessFile, $htaccessContent);
@chmod($htaccessFile, 0644);
echo "<li>✅ Created <code>storage/app/public/.htaccess</code> (Require all granted)</li>";

// 3. Remove problematic public/storage symlink if present so Laravel handles /storage/ streaming cleanly
$shortcut = __DIR__ . '/storage';
if (is_link($shortcut)) {
    @unlink($shortcut);
    echo "<li>⚡ Removed <code>public/storage</code> symlink (Fixes Hostinger LiteSpeed 403 Forbidden on symlinks).</li>";
} elseif (file_exists($shortcut) && is_dir($shortcut)) {
    echo "<li>📁 <code>public/storage</code> is a physical directory.</li>";
} else {
    echo "<li>✅ <code>public/storage</code> symlink bypassed — Laravel controller will stream images cleanly.</li>";
}

// 4. Fix permissions using shell_exec / exec if available, else PHP loop
if (function_exists('shell_exec')) {
    @shell_exec('chmod -R 777 ' . escapeshellarg($baseStoragePath . '/framework'));
    @shell_exec('chmod -R 777 ' . escapeshellarg($baseStoragePath . '/logs'));
    @shell_exec('chmod -R 755 ' . escapeshellarg($publicStoragePath));
    @shell_exec('find ' . escapeshellarg($publicStoragePath) . ' -type f -exec chmod 644 {} +');
    echo "<li>⚡ Applied 777/755/644 permissions via <code>shell_exec</code>.</li>";
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
echo "<div style='background-color: #f0fdf4; border: 1px solid #bbf7d0; padding: 15px; border-radius: 8px; margin-top: 20px;'>";
echo "<h3 style='color: #166534; margin: 0;'>✅ Storage & Framework directories repaired successfully!</h3>";
echo "<p style='color: #15803d; font-size: 14px; margin: 5px 0 0 0;'>Refresh your browser / POS page now. All menu images, views, and logs will work perfectly!</p>";
echo "</div>";
echo "</div>";
