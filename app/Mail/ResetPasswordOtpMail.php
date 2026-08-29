<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ResetPasswordOtpMail extends Mailable
{
    use Queueable, SerializesModels;

    public string $otp;

    /**
     * Create a new message instance.
     */
    public function __construct(string $otp)
    {
        $this->otp = $otp;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'DineDesk POS - Password Reset OTP Code: ' . $this->otp,
        );
    }

    /**
     * Get the message content definition.
     */
    public function content(): Content
    {
        return new Content(
            htmlString: '
                <div style="font-family: Arial, sans-serif; max-width: 550px; margin: 20px auto; padding: 25px; border: 1px solid #e2e8f0; border-radius: 16px; background-color: #ffffff;">
                    <div style="text-align: center; margin-bottom: 20px;">
                        <h2 style="color: #ff6b00; margin: 0; font-size: 24px; font-weight: 800;">DineDesk POS</h2>
                        <p style="color: #64748b; font-size: 14px; margin-top: 4px;">Security Code for Password Reset</p>
                    </div>
                    <div style="background-color: #f8fafc; border: 1px solid #f1f5f9; padding: 20px; border-radius: 12px; text-align: center; margin-bottom: 20px;">
                        <p style="color: #334155; font-size: 14px; margin-top: 0; margin-bottom: 10px;">Use the following 6-digit verification code to reset your account password:</p>
                        <div style="font-size: 32px; font-weight: 900; letter-spacing: 6px; color: #0f172a; padding: 12px 24px; background: #ffffff; display: inline-block; border-radius: 10px; border: 2px dashed #ff6b00;">
                            ' . $this->otp . '
                        </div>
                        <p style="color: #ef4444; font-size: 12px; margin-bottom: 0; margin-top: 12px; font-weight: 600;">⏱️ This code will expire in 10 minutes.</p>
                    </div>
                    <p style="color: #64748b; font-size: 13px; line-height: 1.5;">If you did not request a password reset, please ignore this email or contact support if you suspect unauthorized access.</p>
                    <hr style="border: none; border-top: 1px solid #f1f5f9; margin: 20px 0;" />
                    <p style="color: #94a3b8; font-size: 11px; text-align: center; margin: 0;">&copy; ' . date('Y') . ' DineDesk Restaurant POS System. All rights reserved.</p>
                </div>
            '
        );
    }
}
