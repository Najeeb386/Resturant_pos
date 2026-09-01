import React, { useState } from 'react';
import { Head, useForm, usePage } from '@inertiajs/react';
import { AlertCircle, Lock, Mail, ArrowRight, Loader2, KeyRound, CheckCircle2, X } from 'lucide-react';

export default function Login() {
    const { errors: pageErrors, flash } = usePage().props;
    const [clientError, setClientError] = useState('');

    // Forgot Password Modal State
    const [showForgotModal, setShowForgotModal] = useState(false);
    const [forgotStep, setForgotStep] = useState('email'); // 'email' | 'otp' | 'password' | 'success'
    const [forgotEmail, setForgotEmail] = useState('');
    const [forgotOtp, setForgotOtp] = useState('');
    const [newPassword, setNewPassword] = useState('');
    const [newPasswordConfirmation, setNewPasswordConfirmation] = useState('');
    const [forgotLoading, setForgotLoading] = useState(false);
    const [forgotError, setForgotError] = useState('');
    const [forgotMsg, setForgotMsg] = useState('');

    const { data, setData, post, processing, errors: formErrors } = useForm({
        email: '',
        password: '',
    });

    const handleSubmit = (e) => {
        e.preventDefault();
        setClientError('');
        post('/login', {
            onError: (errs) => {
                if (errs.email) {
                    setClientError(errs.email);
                } else if (errs.password) {
                    setClientError(errs.password);
                } else {
                    setClientError('Invalid credentials. Please verify your email and password.');
                }
            }
        });
    };

    // Handle Forgot Password API calls
    const handleSendOtp = async (e) => {
        e.preventDefault();
        setForgotError('');
        setForgotMsg('');
        setForgotLoading(true);

        try {
            const res = await fetch('/forgot-password/send-otp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
                },
                body: JSON.stringify({ email: forgotEmail })
            });

            const data = await res.json();
            if (res.ok && data.status === 'success') {
                setForgotMsg(data.message);
                setForgotStep('otp');
            } else {
                setForgotError(data.message || 'Failed to send OTP. Please try again.');
            }
        } catch (err) {
            setForgotError('Network error. Please try again.');
        } finally {
            setForgotLoading(false);
        }
    };

    const handleVerifyOtp = async (e) => {
        e.preventDefault();
        setForgotError('');
        setForgotMsg('');
        setForgotLoading(true);

        try {
            const res = await fetch('/forgot-password/verify-otp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
                },
                body: JSON.stringify({ email: forgotEmail, otp: forgotOtp })
            });

            const data = await res.json();
            if (res.ok && data.status === 'success') {
                setForgotMsg(data.message);
                setForgotStep('password');
            } else {
                setForgotError(data.message || 'Invalid OTP code.');
            }
        } catch (err) {
            setForgotError('Network error. Please try again.');
        } finally {
            setForgotLoading(false);
        }
    };

    const handleResetPassword = async (e) => {
        e.preventDefault();
        setForgotError('');
        setForgotMsg('');

        if (newPassword !== newPasswordConfirmation) {
            setForgotError('Passwords do not match.');
            return;
        }

        setForgotLoading(true);

        try {
            const res = await fetch('/forgot-password/reset-password', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
                },
                body: JSON.stringify({
                    email: forgotEmail,
                    otp: forgotOtp,
                    password: newPassword,
                    password_confirmation: newPasswordConfirmation
                })
            });

            const data = await res.json();
            if (res.ok && data.status === 'success') {
                setForgotStep('success');
                setData('email', forgotEmail);
            } else {
                setForgotError(data.message || 'Failed to reset password.');
            }
        } catch (err) {
            setForgotError('Network error. Please try again.');
        } finally {
            setForgotLoading(false);
        }
    };

    const closeForgotModal = () => {
        setShowForgotModal(false);
        setForgotStep('email');
        setForgotError('');
        setForgotMsg('');
        setForgotOtp('');
        setNewPassword('');
        setNewPasswordConfirmation('');
    };

    const displayError = clientError || formErrors.email || formErrors.password || pageErrors?.email || pageErrors?.password || flash?.error;

    return (
        <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
            <Head title="Sign in - DineDesk Restaurant POS" />

            <div className="max-w-md w-full">
                {/* Brand Header */}
                <div className="text-center mb-8">
                    <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-white shadow-xl shadow-orange-500/10 border border-slate-100 mb-4 p-2">
                        <img src="/images/logo.png" alt="DineDesk Logo" className="w-full h-full object-contain" />
                    </div>
                    <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">Sign in to DineDesk</h1>
                    <p className="text-slate-500 text-sm mt-1">Enter your credentials to access your restaurant dashboard.</p>
                </div>

                {/* Main Card */}
                <div className="bg-white rounded-3xl shadow-xl shadow-slate-200/60 p-8 border border-slate-100">
                    <form className="space-y-5" onSubmit={handleSubmit}>
                        
                        {/* Error Alert Box */}
                        {Boolean(displayError) && (
                            <div className="bg-rose-50 border border-rose-200 rounded-2xl p-4 flex items-start gap-3.5 shadow-xs">
                                <div className="w-9 h-9 rounded-xl bg-rose-100 text-rose-600 flex items-center justify-center flex-shrink-0 mt-0.5">
                                    <AlertCircle className="w-5 h-5" />
                                </div>
                                <div className="flex-1">
                                    <h4 className="text-xs font-bold text-rose-800 uppercase tracking-wider">Authentication Failed</h4>
                                    <p className="text-xs text-rose-700 font-medium mt-0.5">
                                        {displayError}
                                    </p>
                                </div>
                            </div>
                        )}

                        {/* Email Input */}
                        <div>
                            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-2">
                                Email Address
                            </label>
                            <div className="relative">
                                <Mail className="w-5 h-5 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
                                <input
                                    type="email"
                                    required
                                    className="w-full pl-11 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-slate-900 text-sm focus:outline-none focus:ring-2 focus:ring-orange-500 focus:bg-white transition-all font-medium"
                                    placeholder="owner@dinedesk.com"
                                    value={data.email}
                                    onChange={(e) => setData('email', e.target.value)}
                                />
                            </div>
                        </div>

                        {/* Password Input & Forgot Password Link */}
                        <div>
                            <div className="flex items-center justify-between mb-2">
                                <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
                                    Password
                                </label>
                                <button
                                    type="button"
                                    onClick={() => {
                                        setForgotEmail(data.email);
                                        setShowForgotModal(true);
                                    }}
                                    className="text-xs font-bold text-orange-600 hover:text-orange-700 hover:underline transition-colors"
                                >
                                    Forgot Password?
                                </button>
                            </div>
                            <div className="relative">
                                <Lock className="w-5 h-5 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
                                <input
                                    type="password"
                                    required
                                    className="w-full pl-11 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-slate-900 text-sm focus:outline-none focus:ring-2 focus:ring-orange-500 focus:bg-white transition-all font-medium"
                                    placeholder="••••••••"
                                    value={data.password}
                                    onChange={(e) => setData('password', e.target.value)}
                                />
                            </div>
                        </div>

                        {/* Submit Button */}
                        <button
                            type="submit"
                            disabled={processing}
                            className="w-full py-3.5 px-4 bg-orange-600 hover:bg-orange-700 text-white text-sm font-bold rounded-xl shadow-lg shadow-orange-500/25 transition-all flex items-center justify-center gap-2 disabled:opacity-70"
                        >
                            {processing ? (
                                <>
                                    <Loader2 className="w-5 h-5 animate-spin" />
                                    <span>Signing in...</span>
                                </>
                            ) : (
                                <>
                                    <span>Sign in to Store</span>
                                    <ArrowRight className="w-4 h-4" />
                                </>
                            )}
                        </button>
                    </form>
                </div>
            </div>

            {/* Forgot Password OTP Modal */}
            {showForgotModal && (
                <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
                    <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-8 shadow-2xl border border-slate-100 relative animate-in fade-in zoom-in duration-200">
                        {/* Close button */}
                        <button
                            onClick={closeForgotModal}
                            className="absolute top-5 right-5 text-slate-400 hover:text-slate-600 p-1 rounded-full hover:bg-slate-100 transition-colors"
                        >
                            <X className="w-5 h-5" />
                        </button>

                        {/* Step 1: Send OTP */}
                        {forgotStep === 'email' && (
                            <div>
                                <div className="flex items-center gap-3 mb-4">
                                    <div className="w-10 h-10 rounded-2xl bg-orange-100 text-orange-600 flex items-center justify-center shrink-0">
                                        <KeyRound className="w-5 h-5" />
                                    </div>
                                    <div>
                                        <h3 className="text-xl font-extrabold text-slate-900">Reset Password</h3>
                                        <p className="text-xs text-slate-500">We will send a 6-digit OTP to your email.</p>
                                    </div>
                                </div>

                                {forgotError && (
                                    <div className="mb-4 p-3 bg-rose-50 border border-rose-200 text-rose-700 rounded-xl text-xs font-semibold">
                                        {forgotError}
                                    </div>
                                )}

                                <form onSubmit={handleSendOtp} className="space-y-4">
                                    <div>
                                        <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">Registered Email</label>
                                        <input
                                            type="email"
                                            required
                                            value={forgotEmail}
                                            onChange={e => setForgotEmail(e.target.value)}
                                            className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-orange-500"
                                            placeholder="your-email@example.com"
                                        />
                                    </div>

                                    <button
                                        type="submit"
                                        disabled={forgotLoading}
                                        className="w-full py-3 bg-orange-600 hover:bg-orange-700 text-white font-bold text-sm rounded-xl transition-colors flex items-center justify-center gap-2 disabled:opacity-70"
                                    >
                                        {forgotLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Send Verification OTP'}
                                    </button>
                                </form>
                            </div>
                        )}

                        {/* Step 2: Verify OTP */}
                        {forgotStep === 'otp' && (
                            <div>
                                <div className="flex items-center gap-3 mb-4">
                                    <div className="w-10 h-10 rounded-2xl bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
                                        <Mail className="w-5 h-5" />
                                    </div>
                                    <div>
                                        <h3 className="text-xl font-extrabold text-slate-900">Enter OTP Code</h3>
                                        <p className="text-xs text-slate-500">Check your inbox for 6-digit code sent to <b className="text-slate-800">{forgotEmail}</b></p>
                                    </div>
                                </div>

                                {forgotMsg && (
                                    <div className="mb-4 p-3 bg-emerald-50 border border-emerald-200 text-emerald-700 rounded-xl text-xs font-semibold">
                                        {forgotMsg}
                                    </div>
                                )}

                                {forgotError && (
                                    <div className="mb-4 p-3 bg-rose-50 border border-rose-200 text-rose-700 rounded-xl text-xs font-semibold">
                                        {forgotError}
                                    </div>
                                )}

                                <form onSubmit={handleVerifyOtp} className="space-y-4">
                                    <div>
                                        <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">6-Digit OTP Code</label>
                                        <input
                                            type="text"
                                            maxLength={6}
                                            required
                                            value={forgotOtp}
                                            onChange={e => setForgotOtp(e.target.value)}
                                            className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-center text-2xl font-mono font-bold tracking-widest focus:outline-none focus:ring-2 focus:ring-orange-500"
                                            placeholder="123456"
                                        />
                                    </div>

                                    <div className="flex gap-2">
                                        <button
                                            type="button"
                                            onClick={() => setForgotStep('email')}
                                            className="py-2.5 px-4 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold text-xs rounded-xl transition-colors"
                                        >
                                            Change Email
                                        </button>
                                        <button
                                            type="submit"
                                            disabled={forgotLoading}
                                            className="flex-1 py-2.5 bg-orange-600 hover:bg-orange-700 text-white font-bold text-sm rounded-xl transition-colors flex items-center justify-center gap-2 disabled:opacity-70"
                                        >
                                            {forgotLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Verify Code'}
                                        </button>
                                    </div>
                                </form>
                            </div>
                        )}

                        {/* Step 3: Set New Password */}
                        {forgotStep === 'password' && (
                            <div>
                                <div className="flex items-center gap-3 mb-4">
                                    <div className="w-10 h-10 rounded-2xl bg-purple-100 text-purple-600 flex items-center justify-center shrink-0">
                                        <Lock className="w-5 h-5" />
                                    </div>
                                    <div>
                                        <h3 className="text-xl font-extrabold text-slate-900">New Password</h3>
                                        <p className="text-xs text-slate-500">Create a new secure password for your account.</p>
                                    </div>
                                </div>

                                {forgotError && (
                                    <div className="mb-4 p-3 bg-rose-50 border border-rose-200 text-rose-700 rounded-xl text-xs font-semibold">
                                        {forgotError}
                                    </div>
                                )}

                                <form onSubmit={handleResetPassword} className="space-y-4">
                                    <div>
                                        <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">New Password</label>
                                        <input
                                            type="password"
                                            required
                                            minLength={8}
                                            value={newPassword}
                                            onChange={e => setNewPassword(e.target.value)}
                                            className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-orange-500"
                                            placeholder="Minimum 8 characters"
                                        />
                                    </div>

                                    <div>
                                        <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">Confirm New Password</label>
                                        <input
                                            type="password"
                                            required
                                            minLength={8}
                                            value={newPasswordConfirmation}
                                            onChange={e => setNewPasswordConfirmation(e.target.value)}
                                            className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-orange-500"
                                            placeholder="Re-enter password"
                                        />
                                    </div>

                                    <button
                                        type="submit"
                                        disabled={forgotLoading}
                                        className="w-full py-3 bg-orange-600 hover:bg-orange-700 text-white font-bold text-sm rounded-xl transition-colors flex items-center justify-center gap-2 disabled:opacity-70"
                                    >
                                        {forgotLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Reset Password'}
                                    </button>
                                </form>
                            </div>
                        )}

                        {/* Step 4: Success Screen */}
                        {forgotStep === 'success' && (
                            <div className="text-center py-4 space-y-4">
                                <div className="w-16 h-16 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center mx-auto">
                                    <CheckCircle2 className="w-10 h-10" />
                                </div>
                                <h3 className="text-2xl font-extrabold text-slate-900">Password Reset Successful!</h3>
                                <p className="text-sm text-slate-500">Your account password has been updated successfully. You can now log in with your new password.</p>
                                <button
                                    onClick={closeForgotModal}
                                    className="w-full py-3 bg-orange-600 hover:bg-orange-700 text-white font-bold text-sm rounded-xl transition-colors"
                                >
                                    Sign In Now
                                </button>
                            </div>
                        )}
                    </div>
                </div>
            )}
        </div>
    );
}