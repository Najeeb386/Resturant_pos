import React from 'react';
import SuperAdminLayout from '../../Layouts/SuperAdminLayout';
import { useForm } from '@inertiajs/react';
import { Card, CardContent, CardHeader, CardTitle } from '../../Components/ui/Card';
import { Button } from '../../Components/ui/Button';
import { User, Lock, DollarSign } from 'lucide-react';

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

    return (
        <SuperAdminLayout>
            <div className="max-w-4xl mx-auto space-y-8">
                <div>
                    <h1 className="text-3xl font-bold text-slate-900">Settings</h1>
                    <p className="text-slate-500 mt-1">Manage your SaaS admin account and platform preferences.</p>
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
            </div>
        </SuperAdminLayout>
    );
}
