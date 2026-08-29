<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Helpers\MailConfigHelper;
use App\Mail\ResetPasswordOtpMail;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

class ForgotPasswordController extends Controller
{
    /**
     * Send 6-digit OTP to user email for password reset
     */
    public function sendOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $email = strtolower(trim($request->email));
        $user = User::where('email', $email)->first();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'No account found with this email address.',
            ], 404);
        }

        // Generate 6-digit numeric OTP
        $otp = sprintf("%06d", mt_rand(100000, 999999));

        // Delete any existing OTP tokens for this email
        DB::table('password_reset_otps')->where('email', $email)->delete();

        // Save new OTP with 10-minute expiration
        DB::table('password_reset_otps')->insert([
            'email' => $email,
            'otp' => $otp,
            'expires_at' => now()->addMinutes(10),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Apply dynamic SMTP settings
        MailConfigHelper::applySettings();

        try {
            Mail::to($email)->send(new ResetPasswordOtpMail($otp));

            return response()->json([
                'status' => 'success',
                'message' => 'Verification code (OTP) sent to your email address.',
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to send OTP email: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Verify submitted OTP code
     */
    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|string|size:6',
        ]);

        $email = strtolower(trim($request->email));
        $otp = trim($request->otp);

        $record = DB::table('password_reset_otps')
            ->where('email', $email)
            ->where('otp', $otp)
            ->first();

        if (!$record) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid verification code. Please check and try again.',
            ], 422);
        }

        if (Carbon::parse($record->expires_at)->isPast()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Verification code has expired. Please request a new code.',
            ], 422);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'OTP verified successfully.',
        ]);
    }

    /**
     * Reset user password using verified OTP
     */
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|string|size:6',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $email = strtolower(trim($request->email));
        $otp = trim($request->otp);

        $record = DB::table('password_reset_otps')
            ->where('email', $email)
            ->where('otp', $otp)
            ->first();

        if (!$record || Carbon::parse($record->expires_at)->isPast()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid or expired OTP session. Please restart the process.',
            ], 422);
        }

        $user = User::where('email', $email)->first();
        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User account not found.',
            ], 404);
        }

        // Update password
        $user->password = Hash::make($request->password);
        $user->save();

        // Clear OTP token
        DB::table('password_reset_otps')->where('email', $email)->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Password reset successfully! You can now log in.',
        ]);
    }
}
