# ⚡ Hostinger Business Web Hosting Deployment Guide for DineDesk

This step-by-step guide is tailored specifically for **Hostinger Business Web Hosting** (hPanel).

---

## 🎯 Summary of What You Need
1. All project files (already built with production JS/CSS in `public/build/`).
2. A MySQL Database created inside **Hostinger hPanel**.
3. Editing `.env` on Hostinger.

---

## 📋 STEP 1: Compress (ZIP) Your Project Files

On your local computer, select all files in `d:\Softwares\Xampp\htdocs\Resturant_pos` and create a `.zip` archive (e.g. `dinedesk-deploy.zip`).

> ⚠️ **Exclude these folder(s)** from the zip file to keep it small and fast:
> - `node_modules/` (not needed on server because `public/build/` is already compiled!)
> - `.git/` (optional)
> - `.env` (you will create this on Hostinger)

---

## 🌐 STEP 2: Create MySQL Database in Hostinger hPanel

1. Log into your **Hostinger Dashboard** (hPanel).
2. Go to **Databases** -> **Management** (or **MySQL Databases**).
3. Create a new database:
   - **Database Name**: e.g., `u123456789_dinedesk`
   - **Database Username**: e.g., `u123456789_posuser`
   - **Password**: Enter a strong password and save it!
4. Click **Create**.

---

## 📁 STEP 3: Upload & Extract Files in Hostinger File Manager

1. In hPanel, go to **Files** -> **File Manager**.
2. Navigate to `public_html` (or your domain folder, e.g. `public_html/dinedesk`).
3. Click **Upload** (top right) and select your `dinedesk-deploy.zip`.
4. Right-click `dinedesk-deploy.zip` -> select **Extract** -> extract into current directory.

---

## 🔀 STEP 4: Point Domain to `public/` Folder in Hostinger

In Hostinger, Laravel requires the web server to load from the `public/` directory.

### Method A (Recommended in Hostinger hPanel):
1. In hPanel, go to **Websites** -> click **Manage** next to your domain.
2. Go to **General Information** / **Folder / Document Root**.
3. Change the **Directory Root** from `public_html` to `public_html/public` (or `public_html/dinedesk/public`).
4. Click **Save**.

### Method B (If Hostinger hPanel doesn't let you change root):
If your domain root is stuck at `public_html`, create a `.htaccess` file directly inside `public_html/` with this exact content:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^$ public/ [L]
    RewriteRule (.*) public/$1 [L]
</IfModule>
```

---

## ⚙️ STEP 5: Create and Configure `.env` File

1. Inside Hostinger File Manager, find `.env.example` in your project folder.
2. Rename it or copy it to `.env`.
3. Open `.env` in Hostinger File Manager Code Editor and update:

```env
APP_NAME="DineDesk"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://your-domain.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=u123456789_dinedesk
DB_USERNAME=u123456789_posuser
DB_PASSWORD=your_hostinger_db_password

SESSION_DRIVER=database
FILESYSTEM_DISK=public
SANCTUM_STATEFUL_DOMAINS=your-domain.com
```

---

## 💻 STEP 6: Run Commands via Hostinger SSH Access / Terminal

Hostinger Business Hosting includes **SSH Access / Terminal** directly in hPanel!

1. In hPanel, go to **Advanced** -> **SSH Access** (or **Terminal**).
2. Enable SSH Access and copy your SSH login details, or click **Open Web Terminal**.
3. In the Hostinger Terminal, navigate to your folder:
   ```bash
   cd public_html
   ```
4. Run these exact commands:
   ```bash
   # Install composer dependencies
   composer install --no-dev --optimize-autoloader

   # Generate production app key
   php artisan key:generate

   # Run Database Migrations (creates tables, users, menu)
   php artisan migrate --force

   # Create storage link for uploaded food images & logos
   php artisan storage:link

   # Clear and cache configs for ultra speed
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

---

## 🔒 STEP 7: Check Storage Permissions & SSL

1. In Hostinger hPanel, go to **Security** -> **SSL** -> Install free SSL certificate (HTTPS).
2. In File Manager, right-click `storage` and `bootstrap/cache` -> set permissions to `775` or `777`.

---

## 📱 STEP 8: Connect Your Android Flutter App

1. Open your Flutter App settings on your phone or Android POS terminal.
2. Update the **Server URL** to:
   `https://your-domain.com/api/v1`
3. Tap **Save & Test Connection**.
4. Log in with your SuperAdmin / Owner account! 🎉

---

### 🎉 All Done! Your DineDesk POS System is Live on Hostinger!
