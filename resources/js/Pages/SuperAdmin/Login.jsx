import React, { useState } from 'react';
import { Head, useForm, usePage, Link } from '@inertiajs/react';
import { Button } from '../../Components/ui/Button';
import { AlertCircle, Loader2, ArrowLeft, Mail, Lock } from 'lucide-react';

export default function AdminLogin() {
    const { errors: pageErrors, flash } = usePage().props;
    const [clientError, setClientError] = useState('');

    const { data, setData, post, processing, errors: formErrors } = useForm({
        email: '',
        password: '',
    });

    const submit = (e) => {
        e.preventDefault();
        setClientError('');
        post('/admin/login', {
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
        <div className="min-h-screen bg-slate-950 flex items-center justify-center p-4 selection:bg-blue-500/30">
            <Head title="DineDesk SaaS Admin Portal - Login" />
            
            <div className="w-full max-w-md">
                <div className="text-center mb-8">
                    <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-slate-900 border border-slate-800 shadow-xl mb-4 p-2.5">
                        <img src="/images/logo.png" alt="DineDesk Logo" className="w-full h-full object-contain" />
                    </div>
                    <h1 className="text-3xl font-extrabold text-white mb-1 tracking-tight">DineDesk SaaS Admin</h1>
                    <p className="text-slate-400 text-sm">Secure access for platform administrators.</p>
                </div>

                <div className="bg-slate-900 rounded-3xl shadow-2xl p-8 border border-slate-800">
                    <form onSubmit={submit} className="space-y-5">
                        
                        {/* Beautiful Error Alert Box */}
                        {Boolean(displayError) && (
                            <div className="bg-rose-500/10 border border-rose-500/30 rounded-2xl p-4 flex items-start gap-3.5 shadow-xs">
                                <div className="w-9 h-9 rounded-xl bg-rose-500/20 text-rose-400 flex items-center justify-center flex-shrink-0 mt-0.5">
                                    <AlertCircle className="w-5 h-5" />
                                </div>
                                <div className="flex-1">
                                    <h4 className="text-xs font-bold text-rose-400 uppercase tracking-wider">Authentication Failed</h4>
                                    <p className="text-xs text-rose-300 font-medium mt-0.5">
                                        {displayError}
                                    </p>
                                </div>
                            </div>
                        )}

                        <div>
                            <label className="block text-xs font-bold text-slate-300 uppercase tracking-wider mb-2">Admin Email</label>
                            <div className="relative">
                                <Mail className="w-5 h-5 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500" />
                                <input
                                    type="email"
                                    value={data.email}
                                    onChange={e => setData('email', e.target.value)}
                                    className="w-full pl-11 pr-4 py-3 bg-slate-950 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all text-sm font-medium"
                                    placeholder="admin@dinedesk.com"
                                    required
                                />
                            </div>
                        </div>

                        <div>
                            <label className="block text-xs font-bold text-slate-300 uppercase tracking-wider mb-2">Password</label>
                            <div className="relative">
                                <Lock className="w-5 h-5 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500" />
                                <input
                                    type="password"
                                    value={data.password}
                                    onChange={e => setData('password', e.target.value)}
                                    className="w-full pl-11 pr-4 py-3 bg-slate-950 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all text-sm font-medium"
                                    placeholder="••••••••"
                                    required
                                />
                            </div>
                        </div>

                        <Button 
                            type="submit" 
                            disabled={processing}
                            className="w-full py-3.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold shadow-lg shadow-blue-500/25 transition-all flex justify-center items-center gap-2 text-sm"
                        >
                            {processing && <Loader2 className="w-5 h-5 animate-spin" />}
                            Access Admin Portal
                        </Button>
                    </form>
                </div>

                <div className="mt-8 text-center">
                    <Link href="/" className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-slate-300 transition-colors">
                        <ArrowLeft className="w-4 h-4" /> Back to main site
                    </Link>
                </div>
            </div>
        </div>
    );
}
