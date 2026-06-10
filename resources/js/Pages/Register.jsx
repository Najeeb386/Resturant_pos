import React, { useEffect } from 'react';
import { Head, useForm, Link } from '@inertiajs/react';
import { Button } from '../Components/ui/Button';
import { Store, Loader2, ArrowLeft } from 'lucide-react';

export default function Register({ plans = [], currencySymbol = '$' }) {
    const { data, setData, post, processing, errors } = useForm({
        restaurant_name: '',
        name: '',
        email: '',
        password: '',
        plan_id: '',
    });

    // Auto-select plan from URL if present
    useEffect(() => {
        const urlParams = new URLSearchParams(window.location.search);
        const planParam = urlParams.get('plan');
        if (planParam) {
            setData('plan_id', planParam);
        } else if (plans.length > 0) {
            setData('plan_id', plans[0].id.toString());
        }
    }, [plans]);

    const submit = (e) => {
        e.preventDefault();
        post('/register');
    };

    return (
        <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center p-4 selection:bg-primary/30">
            <Head title="Start Free Trial - RestoPOS" />

            <div className="w-full max-w-md">
                <div className="text-center mb-8">
                    <Link href="/" className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-gradient-to-tr from-primary to-orange-400 text-white shadow-lg mb-4 hover:shadow-xl transition-shadow">
                        <Store className="w-6 h-6" />
                    </Link>
                    <h1 className="text-3xl font-bold text-gray-900 mb-2">Create your account</h1>
                    <p className="text-gray-500">Start your 14-day free trial. No credit card required.</p>
                </div>

                <div className="bg-white rounded-3xl shadow-xl p-8 border border-gray-100">
                    <form onSubmit={submit} className="space-y-5">
                        
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Restaurant Name</label>
                            <input
                                type="text"
                                value={data.restaurant_name}
                                onChange={e => setData('restaurant_name', e.target.value)}
                                className="w-full px-4 py-2.5 bg-white border border-gray-200 rounded-xl text-gray-900 focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                placeholder="The Great Burger"
                                required
                            />
                            {errors.restaurant_name && <p className="text-red-500 text-xs mt-1">{errors.restaurant_name}</p>}
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Your Full Name</label>
                            <input
                                type="text"
                                value={data.name}
                                onChange={e => setData('name', e.target.value)}
                                className="w-full px-4 py-2.5 bg-white border border-gray-200 rounded-xl text-gray-900 focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                placeholder="John Doe"
                                required
                            />
                            {errors.name && <p className="text-red-500 text-xs mt-1">{errors.name}</p>}
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Email Address</label>
                            <input
                                type="email"
                                value={data.email}
                                onChange={e => setData('email', e.target.value)}
                                className="w-full px-4 py-2.5 bg-white border border-gray-200 rounded-xl text-gray-900 focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                placeholder="john@example.com"
                                required
                            />
                            {errors.email && <p className="text-red-500 text-xs mt-1">{errors.email}</p>}
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Password</label>
                            <input
                                type="password"
                                value={data.password}
                                onChange={e => setData('password', e.target.value)}
                                className="w-full px-4 py-2.5 bg-white border border-gray-200 rounded-xl text-gray-900 focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                placeholder="••••••••"
                                required
                            />
                            {errors.password && <p className="text-red-500 text-xs mt-1">{errors.password}</p>}
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Select Plan</label>
                            <select
                                value={data.plan_id}
                                onChange={e => setData('plan_id', e.target.value)}
                                className="w-full px-4 py-2.5 bg-white border border-gray-200 rounded-xl text-gray-900 focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                required
                            >
                                <option value="" disabled>Choose a plan...</option>
                                {plans.map(plan => (
                                    <option key={plan.id} value={plan.id}>
                                        {plan.name} - {currencySymbol}{plan.price}/{plan.billing_cycle}
                                    </option>
                                ))}
                            </select>
                            {errors.plan_id && <p className="text-red-500 text-xs mt-1">{errors.plan_id}</p>}
                        </div>

                        <div className="pt-2">
                            <Button 
                                type="submit" 
                                disabled={processing}
                                className="w-full py-3 bg-primary hover:bg-orange-600 text-white rounded-xl font-bold shadow-lg shadow-primary/20 transition-all flex justify-center items-center gap-2"
                            >
                                {processing && <Loader2 className="w-5 h-5 animate-spin" />}
                                Start 14-Day Free Trial
                            </Button>
                        </div>
                    </form>

                    <div className="mt-6 text-center">
                        <p className="text-sm text-gray-500">
                            Already have an account?{' '}
                            <Link href="/login" className="text-primary font-bold hover:underline">
                                Log in
                            </Link>
                        </p>
                    </div>
                </div>

                <div className="mt-6 text-center">
                    <Link href="/" className="inline-flex items-center gap-2 text-sm text-gray-400 hover:text-gray-600 transition-colors">
                        <ArrowLeft className="w-4 h-4" /> Back to website
                    </Link>
                </div>
            </div>
        </div>
    );
}
