# 🚀 DineDesk Production Deployment Guide

This guide details how to upload and deploy the **DineDesk Restaurant POS Web Application** to a live production web server (cPanel, Shared Hosting, VPS, or Laravel Forge).

---

## 📁 1. Project Build Summary
The frontend React / Inertia assets have already been compiled for production using Vite:
- Production CSS & JS assets generated inside: `public/build/`
- Build manifest generated inside: `public/build/manifest.json`

---

## 🛠️ 2. Server Requirements
Ensure your live server meets the following requirements:
- **PHP**: `^8.2` or higher
- **PHP Extensions**: `bcmath`, `ctype`, `fileinfo`, `json`, `mbstring`, `openssl`, `pdo`, `pdo_mysql`, `tokenizer`, `xml`, `curl`
- **Database**: MySQL `8.0+` or MariaDB `10.4+`
- **Web Server**: Apache or NGINX
- **URL Rewriting**: Enabled (`mod_rewrite` on Apache)

---

## 📤 3. Step-by-Step Deployment Options

### Option A: Uploading via cPanel / File Manager / FTP

1. **Upload Files**:
   Upload all project files to your server directory (e.g. `/public_html/dinedesk` or `/home/user/dinedesk`).
   > ⚠️ **Important**: Do NOT upload `.env` or `node_modules`.

2. **Configure Domain / Subdomain Document Root**:
   Point your domain or subdomain's **Document Root** to the project's **`public`** directory (e.g., `/public_html/dinedesk/public`).

3. **Configure Environment File (`.env`)**:
   Duplicate `.env.example` to `.env` on your server and configure your live credentials:
   ```env
   APP_NAME="DineDesk"
   APP_ENV=production
   APP_KEY=base64:... (generate via php artisan key:generate)
   APP_DEBUG=false
   APP_URL=https://your-domain.com

   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=your_database_name
   DB_USERNAME=your_database_user
   DB_PASSWORD=your_secure_password

   FILESYSTEM_DISK=public
   SANCTUM_STATEFUL_DOMAINS=your-domain.com
   ```

4. **Run Composer Dependencies & Database Migrations** (via SSH or Terminal):
   ```bash
   # Install PHP dependencies optimized for production
   composer install --no-dev --optimize-autoloader

   # Generate application encryption key
   php artisan key:generate

   # Run Database Migrations
   php artisan migrate --force

   # Create Storage Symlink (for item images & logos)
   php artisan storage:link

   # Cache Configuration and Routes for Maximum Speed
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

5. **Set Permissions**:
   Ensure the following directories are writable by the web server (chmod `775` or `777`):
   - `storage/`
   - `storage/logs/`
   - `storage/framework/`
   - `bootstrap/cache/`

---

### Option B: VPS Deployment (NGINX + PHP-FPM)

#### NGINX Configuration Example (`/etc/nginx/sites-available/dinedesk`)
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/dinedesk/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

---

## 📱 4. Connecting the Flutter Android App to Live Server

Once your web application is live at `https://your-domain.com`, update the API server URL in your Flutter app:

1. Open `DineDesk_app/lib/services/api_service.dart` or open the **Settings** view in the Flutter App.
2. Set the Server Address to:
   `https://your-domain.com/api/v1`
3. Tap **Save & Test Connection**.

---

## ✅ Deployment Checklist
- [x] Production asset bundle compiled (`npm run build`)
- [ ] Database created on server MySQL
- [ ] Environment file `.env` configured (`APP_ENV=production`, `APP_DEBUG=false`)
- [ ] `php artisan key:generate` executed
- [ ] `php artisan migrate --force` executed
- [ ] `php artisan storage:link` executed
- [ ] Permissions updated on `storage/` and `bootstrap/cache/` (775/777)
- [ ] Domain Document Root pointed to `public/`
- [ ] SSL / HTTPS certificate enabled (Let's Encrypt / Cloudflare)
