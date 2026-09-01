import React from 'react';
import SuperAdminLayout from '../../Layouts/SuperAdminLayout';
import { useForm } from '@inertiajs/react';
import { Card, CardContent, CardHeader, CardTitle } from '../../Components/ui/Card';
import { Button } from '../../Components/ui/Button';
import { User, Lock, DollarSign, Mail, Send, CheckCircle, AlertCircle } from 'lucide-react';

export default function Settings({ auth, settings }) {
    // Profile form
    const profileForm = useForm({
        name: auth?.user?.name || '',
    });

    // Password form
    const passwordForm = useForm({
        current_password: '',
        password: '',
        password_confirmation: '',
    });

    // Currency form
    const currencyForm = useForm({
        currency: settings?.currency || 'USD',
        currency_symbol: settings?.currency_symbol || '$',
    });

    // SMTP Form
    const smtpForm = useForm({
        mail_host: settings?.mail_host || '',
        mail_port: settings?.mail_port || 587,
        mail_username: settings?.mail_username || '',
        mail_password: settings?.mail_password || '',
        mail_encryption: settings?.mail_encryption || 'tls',
        mail_from_address: settings?.mail_from_address || '',
        mail_from_name: settings?.mail_from_name || 'DineDesk POS',
    });

    // Test Email Form
    const testSmtpForm = useForm({
        test_email: auth?.user?.email || '',
    });

    const updateProfile = (e) => {
        e.preventDefault();
        profileForm.post('/admin/settings/profile', {
            preserveScroll: true,
        });
    };

    const updatePassword = (e) => {
        e.preventDefault();
        passwordForm.post('/admin/settings/password', {
            preserveScroll: true,
            onSuccess: () => passwordForm.reset(),
        });
    };

    const updateCurrency = (e) => {
        e.preventDefault();
        currencyForm.post('/admin/settings/currency', {
            preserveScroll: true,
        });
    };

    const updateSmtp = (e) => {
        e.preventDefault();
        smtpForm.post('/admin/settings/smtp', {
            preserveScroll: true,
        });
    };

    const sendTestEmail = (e) => {
        e.preventDefault();
        testSmtpForm.post('/admin/settings/test-smtp', {
            preserveScroll: true,
        });
    };

    return (
        <SuperAdminLayout>
            <div className="max-w-4xl mx-auto space-y-8 pb-12">
                <div>
                    <h1 className="text-3xl font-bold text-slate-900">Settings</h1>
                    <p className="text-slate-500 mt-1">Manage your SaaS admin account, SMTP email server, and platform preferences.</p>
                </div>

                {/* Profile Settings */}
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <User className="w-5 h-5" /> Profile Information
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <form onSubmit={updateProfile} className="space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Full Name</label>
                                <input
                                    type="text"
                                    value={profileForm.data.name}
                                    onChange={e => profileForm.setData('name', e.target.value)}
                                    className="w-full border border-slate-300 rounded-lg px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    required
                                />
                            </div>

                            <div className="pt-2">
                                <Button type="submit" disabled={profileForm.processing}>
                                    Save Profile
                                </Button>
                            </div>
                        </form>
                    </CardContent>
                </Card>

                {/* Change Password */}
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Lock className="w-5 h-5" /> Change Password
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <form onSubmit={updatePassword} className="space-y-4">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Current Password</label>
                                    <input
                                        type="password"
                                        value={passwordForm.data.current_password}
                                        onChange={e => passwordForm.setData('current_password', e.target.value)}
                                        className="w-full border border-slate-300 rounded-lg px-4 py-2.5"
                                        required
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">New Password</label>
                                    <input
                                        type="password"
                                        value={passwordForm.data.password}
                                        onChange={e => passwordForm.setData('password', e.target.value)}
                                        className="w-full border border-slate-300 rounded-lg px-4 py-2.5"
                                        required
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Confirm New Password</label>
                                <input
                                    type="password"
                                    value={passwordForm.data.password_confirmation}
                                    onChange={e => passwordForm.setData('password_confirmation', e.target.value)}
                                    className="w-full border border-slate-300 rounded-lg px-4 py-2.5"
                                    required
                                />
                            </div>

                            <div className="pt-2">
                                <Button type="submit" disabled={passwordForm.processing} variant="outline">
                                    Update Password
                                </Button>
                            </div>
                        </form>
                    </CardContent>
                </Card>

                {/* Platform Currency Settings */}
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <DollarSign className="w-5 h-5" /> Platform Currency Settings
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <form onSubmit={updateCurrency} className="space-y-4">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Currency Code</label>
                                    <input
                                        type="text"
                                        value={currencyForm.data.currency}
                                        onChange={e => currencyForm.setData('currency', e.target.value)}
                                        className="w-full border border-slate-300 rounded-lg px-4 py-2.5"
                                        placeholder="USD"
                                        required
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Currency Symbol</label>
                                    <input
                                        type="text"
                                        value={currencyForm.data.currency_symbol}
                                        onChange={e => currencyForm.setData('currency_symbol', e.target.value)}
                                        className="w-full border border-slate-300 rounded-lg px-4 py-2.5"
                                        placeholder="$"
                                        required
                                    />
                                </div>
                            </div>

                            <div className="pt-2">
                                <Button type="submit" disabled={currencyForm.processing}>
                                    Save Currency Settings
                                </Button>
                            </div>
                        </form>
                    </CardContent>
                </Card>

                {/* SMTP Mail Server Settings */}
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Mail className="w-5 h-5 text-blue-600" /> SMTP Mail Server Configuration
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-6">
                        <p className="text-xs text-slate-500">
                            Configure your custom SMTP mail credentials to send OTP password resets, notifications, and tenant emails.
                        </p>

                        <form onSubmit={updateSmtp} className="space-y-4">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">SMTP Host</label>
                                    <input
                                        type="text"
                                        value={smtpForm.data.mail_host}
                                        onChange={e => smtpForm.setData('mail_host', e.target.value)}
                                        className="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm"
                                        placeholder="smtp.gmail.com or mail.yourdomain.com"
                                        required
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">SMTP Port</label>
                                    <input
                                        type="number"
                                        value={smtpForm.data.mail_port}
                                        onChange={e => smtpForm.setData('mail_port', e.target.value)}
                                        className="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm"
                                        placeholder="587"
                                        required
                                    />
                                </div>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">SMTP Username / Email</label>
                                    <input
                                        type="text"
                                        value={smtpForm.data.mail_username}
                                        onChange={e => smtpForm.setData('mail_username', e.target.value)}
                                        className="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm"
                                        placeholder="info@yourdomain.com"
                                        required
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">SMTP Password</label>
                                    <input
                                        type="password"
                                        value={smtpForm.data.mail_password}
                                        onChange={e => smtpForm.setData('mail_password', e.target.value)}
                                        className="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm"
                                        placeholder="••••••••••••"
                                    />
                                </div>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Encryption</label>
                                    <select
                                        value={smtpForm.data.mail_encryption}
                                        onChange={e => smtpForm.setData('mail_encryption', e.target.value)}
                                        className="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm bg-white"
                                    >
                                        <option value="tls">TLS (Port 587 / 25)</option>
                                        <option value="ssl">SSL (Port 465)</option>
                                        <option value="null">None</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">From Address</label>
                                    <input
                                        type="email"
                                        value={smtpForm.data.mail_from_address}
                                        onChange={e => smtpForm.setData('mail_from_address', e.target.value)}
                                        className="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm"
                                        placeholder="noreply@yourdomain.com"
                                        required
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">From Sender Name</label>
                                    <input
                                        type="text"
                                        value={smtpForm.data.mail_from_name}
                                        onChange={e => smtpForm.setData('mail_from_name', e.target.value)}
                                        className="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm"
                                        placeholder="DineDesk POS"
                                        required
                                    />
                                </div>
                            </div>

                            <div className="pt-2">
                                <Button type="submit" disabled={smtpForm.processing}>
                                    Save SMTP Settings
                                </Button>
                            </div>
                        </form>

                        {/* Test Email Section */}
                        <div className="border-t border-slate-100 pt-5 mt-6">
                            <h4 className="text-sm font-bold text-slate-800 mb-2 flex items-center gap-1.5">
                                <Send className="w-4 h-4 text-emerald-600" /> Send Test Email
                            </h4>
                            <form onSubmit={sendTestEmail} className="flex flex-col sm:flex-row gap-3 items-end">
                                <div className="flex-1 w-full">
                                    <label className="block text-xs font-medium text-slate-500 mb-1">Recipient Email</label>
                                    <input
                                        type="email"
                                        value={testSmtpForm.data.test_email}
                                        onChange={e => testSmtpForm.setData('test_email', e.target.value)}
                                        className="w-full border border-slate-300 rounded-lg px-4 py-2 text-sm"
                                        placeholder="your-email@example.com"
                                        required
                                    />
                                </div>
                                <Button type="submit" variant="outline" disabled={testSmtpForm.processing} className="w-full sm:w-auto">
                                    {testSmtpForm.processing ? 'Sending...' : 'Send Test Mail'}
                                </Button>
                            </form>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </SuperAdminLayout>
    );
}

