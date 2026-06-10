import React from 'react';
import { Head, useForm, Link } from '@inertiajs/react';
import { Button } from '../../Components/ui/Button';
import { ShieldAlert, Loader2, ArrowLeft } from 'lucide-react';

export default function AdminLogin() {
    const { data, setData, post, processing, errors } = useForm({
        email: '',
        password: '',
    });

    const submit = (e) => {
        e.preventDefault();
        post('/admin/login');
    };

    return (
        <div className="min-h-screen bg-gray-900 flex items-center justify-center p-4 selection:bg-primary/30">
            <Head title="Super Admin Portal - Login" />
            
            <div className="w-full max-w-md">
                <div className="text-center mb-8">
                    <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gray-800 border border-gray-700 shadow-xl mb-4">
                        <ShieldAlert className="w-8 h-8 text-primary" />
                    </div>
                    <h1 className="text-3xl font-bold text-white mb-2">Admin Portal</h1>
                    <p className="text-gray-400">Secure access for platform administrators.</p>
                </div>

                <div className="bg-gray-800 rounded-3xl shadow-2xl p-8 border border-gray-700">
                    <form onSubmit={submit} className="space-y-6">
                        <div>
                            <label className="block text-sm font-medium text-gray-300 mb-2">Admin Email</label>
                            <input
                                type="email"
                                value={data.email}
                                onChange={e => setData('email', e.target.value)}
                                className="w-full px-4 py-3 bg-gray-900 border border-gray-700 rounded-xl text-white focus:ring-2 focus:ring-primary/50 focus:border-primary outline-none transition-all"
                                placeholder="admin@restopos.com"
                                required
                            />
                            {errors.email && <p className="text-red-400 text-sm mt-2">{errors.email}</p>}
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-300 mb-2">Password</label>
                            <input
                                type="password"
                                value={data.password}
                                onChange={e => setData('password', e.target.value)}
                                className="w-full px-4 py-3 bg-gray-900 border border-gray-700 rounded-xl text-white focus:ring-2 focus:ring-primary/50 focus:border-primary outline-none transition-all"
                                placeholder="••••••••"
                                required
                            />
                        </div>

                        <Button 
                            type="submit" 
                            disabled={processing}
                            className="w-full py-3 bg-primary hover:bg-orange-600 text-white rounded-xl font-bold shadow-lg shadow-primary/20 transition-all flex justify-center items-center gap-2"
                        >
                            {processing && <Loader2 className="w-5 h-5 animate-spin" />}
                            Access Portal
                        </Button>
                    </form>
                </div>

                <div className="mt-8 text-center">
                    <Link href="/" className="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-gray-300 transition-colors">
                        <ArrowLeft className="w-4 h-4" /> Back to main site
                    </Link>
                </div>
            </div>
        </div>
    );
}
