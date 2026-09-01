<?php

namespace App\Helpers;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Config;

class MailConfigHelper
{
    /**
     * Apply runtime SMTP settings stored in platform_settings database table
     */
    public static function applySettings(): void
    {
        try {
            $settings = DB::table('platform_settings')->first();

            if ($settings && !empty($settings->mail_host) && !empty($settings->mail_username)) {
                Config::set('mail.default', $settings->mail_mailer ?? 'smtp');
                Config::set('mail.mailers.smtp.transport', 'smtp');
                Config::set('mail.mailers.smtp.host', trim($settings->mail_host));
                Config::set('mail.mailers.smtp.port', (int)($settings->mail_port ?? 587));
                Config::set('mail.mailers.smtp.username', trim($settings->mail_username));
                Config::set('mail.mailers.smtp.password', trim($settings->mail_password ?? ''));
                Config::set('mail.mailers.smtp.encryption', strtolower(trim($settings->mail_encryption ?? 'tls')));
                
                if (!empty($settings->mail_from_address)) {
                    Config::set('mail.from.address', trim($settings->mail_from_address));
                } else {
                    Config::set('mail.from.address', trim($settings->mail_username));
                }

                if (!empty($settings->mail_from_name)) {
                    Config::set('mail.from.name', trim($settings->mail_from_name));
                } else {
                    Config::set('mail.from.name', 'DineDesk POS');
                }
            } else {
                // If SMTP is not yet configured by SuperAdmin, fall back to log mailer safely
                Config::set('mail.default', 'log');
            }
        } catch (\Throwable $e) {
            // Log fallback if DB query fails
            Config::set('mail.default', 'log');
        }
    }
}
