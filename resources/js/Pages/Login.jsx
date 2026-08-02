import React, { useState } from 'react';
import { Head, useForm, usePage } from '@inertiajs/react';
import { AlertCircle, Lock, Mail, ArrowRight, Loader2 } from 'lucide-react';

export default function Login() {
    const { errors: pageErrors, flash } = usePage().props;
    const [clientError, setClientError] = useState('');

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
                        
                        {/* Beautiful Error Alert Box */}
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

                        {/* Password Input */}
                        <div>
                            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-2">
                                Password
                            </label>
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
        </div>
    );
}