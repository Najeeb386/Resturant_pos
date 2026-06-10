import React from 'react';
import { Head, Link } from '@inertiajs/react';
import { ArrowRight, CheckCircle2, Store, Utensils, BarChart3, Zap } from 'lucide-react';

export default function Landing({ plans = [], currencySymbol = '$' }) {
    return (
        <div className="min-h-screen bg-gray-50 font-sans selection:bg-primary/20 selection:text-primary">
            <Head title="Restaurant POS SaaS - Modern Management System" />

            {/* Navigation */}
            <nav className="fixed w-full top-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-100">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between h-20 items-center">
                        <div className="flex items-center gap-2">
                            <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-primary to-orange-400 flex items-center justify-center text-white shadow-lg shadow-primary/30">
                                <Store className="w-6 h-6" />
                            </div>
                            <span className="text-xl font-bold bg-gradient-to-r from-gray-900 to-gray-600 bg-clip-text text-transparent">RestoPOS</span>
                        </div>
                        <div className="flex items-center gap-4">
                            <Link href="/login" className="text-gray-600 hover:text-gray-900 font-medium text-sm transition-colors">
                                Login
                            </Link>
                            <Link href="/register" className="bg-gray-900 hover:bg-black text-white px-5 py-2.5 rounded-full font-medium text-sm transition-all shadow-md hover:shadow-xl hover:-translate-y-0.5">
                                Get Started
                            </Link>
                        </div>
                    </div>
                </div>
            </nav>

            {/* Hero Section */}
            <div className="relative pt-32 pb-20 sm:pt-40 sm:pb-24 overflow-hidden">
                <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-orange-100/50 via-white to-white -z-10"></div>
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
                    <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-50 border border-orange-100 text-primary text-sm font-medium mb-8">
                        <Zap className="w-4 h-4" /> <span>The ultimate operating system for restaurants</span>
                    </div>
                    <h1 className="text-5xl sm:text-7xl font-extrabold text-gray-900 tracking-tight mb-8">
                        Manage your restaurant <br className="hidden sm:block" />
                        <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-orange-500">beautifully.</span>
                    </h1>
                    <p className="max-w-2xl mx-auto text-lg sm:text-xl text-gray-500 mb-10">
                        Everything you need to run your restaurant, from tableside ordering to kitchen display systems and real-time analytics, all in one platform.
                    </p>
                    <div className="flex flex-col sm:flex-row justify-center gap-4">
                        <Link href="/register" className="inline-flex justify-center items-center gap-2 bg-primary hover:bg-orange-600 text-white px-8 py-4 rounded-full font-bold text-lg transition-all shadow-lg shadow-primary/30 hover:shadow-xl hover:-translate-y-1">
                            Start Free Trial <ArrowRight className="w-5 h-5" />
                        </Link>
                        <a href="#pricing" className="inline-flex justify-center items-center gap-2 bg-white hover:bg-gray-50 text-gray-900 px-8 py-4 rounded-full font-bold text-lg transition-all border border-gray-200 shadow-sm hover:shadow-md">
                            View Pricing
                        </a>
                    </div>
                </div>
            </div>

            {/* Features Section */}
            <div className="py-24 bg-white">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="text-center max-w-3xl mx-auto mb-16">
                        <h2 className="text-3xl font-bold text-gray-900 mb-4">Powerful tools for modern restaurants</h2>
                        <p className="text-gray-500 text-lg">Stop juggling multiple outdated systems. RestoPOS gives you a single, elegant platform to manage every aspect of your business.</p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                        {/* Feature 1 */}
                        <div className="p-8 rounded-3xl bg-gray-50 border border-gray-100 hover:shadow-xl hover:-translate-y-1 transition-all duration-300">
                            <div className="w-14 h-14 rounded-2xl bg-white border border-gray-100 shadow-sm flex items-center justify-center text-primary mb-6">
                                <Store className="w-7 h-7" />
                            </div>
                            <h3 className="text-xl font-bold text-gray-900 mb-3">Lightning Fast POS</h3>
                            <p className="text-gray-500 leading-relaxed">Take orders quickly, manage tables, and process payments securely. Designed for speed during the busiest hours.</p>
                        </div>
                        {/* Feature 2 */}
                        <div className="p-8 rounded-3xl bg-gray-50 border border-gray-100 hover:shadow-xl hover:-translate-y-1 transition-all duration-300">
                            <div className="w-14 h-14 rounded-2xl bg-white border border-gray-100 shadow-sm flex items-center justify-center text-orange-500 mb-6">
                                <Utensils className="w-7 h-7" />
                            </div>
                            <h3 className="text-xl font-bold text-gray-900 mb-3">Kitchen Display</h3>
                            <p className="text-gray-500 leading-relaxed">No more lost paper tickets. Send orders directly to the kitchen and track preparation times in real-time.</p>
                        </div>
                        {/* Feature 3 */}
                        <div className="p-8 rounded-3xl bg-gray-50 border border-gray-100 hover:shadow-xl hover:-translate-y-1 transition-all duration-300">
                            <div className="w-14 h-14 rounded-2xl bg-white border border-gray-100 shadow-sm flex items-center justify-center text-blue-500 mb-6">
                                <BarChart3 className="w-7 h-7" />
                            </div>
                            <h3 className="text-xl font-bold text-gray-900 mb-3">Live Analytics</h3>
                            <p className="text-gray-500 leading-relaxed">Make data-driven decisions with real-time insights into your sales, best-selling items, and low stock warnings.</p>
                        </div>
                    </div>
                </div>
            </div>

            {/* Pricing Section */}
            <div id="pricing" className="py-24 bg-gray-50">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="text-center max-w-3xl mx-auto mb-16">
                        <h2 className="text-3xl font-bold text-gray-900 mb-4">Simple, transparent pricing</h2>
                        <p className="text-gray-500 text-lg">Choose the perfect plan for your restaurant's size. No hidden fees or surprises.</p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 max-w-5xl mx-auto">
                        {plans.map((plan, index) => (
                            <div key={plan.id} className="bg-white rounded-3xl p-8 border border-gray-100 shadow-lg hover:shadow-xl transition-shadow relative overflow-hidden">
                                {index === 1 && (
                                    <div className="absolute top-0 inset-x-0 h-1.5 bg-gradient-to-r from-primary to-orange-500"></div>
                                )}
                                <h3 className="text-2xl font-bold text-gray-900 mb-2">{plan.name}</h3>
                                <div className="flex items-baseline gap-1 mb-6">
                                    <span className="text-4xl font-extrabold text-gray-900">{currencySymbol}{plan.price}</span>
                                    <span className="text-gray-500 font-medium">/{plan.billing_cycle}</span>
                                </div>
                                <ul className="space-y-4 mb-8">
                                    <li className="flex items-center gap-3 text-gray-600">
                                        <CheckCircle2 className="w-5 h-5 text-green-500 flex-shrink-0" />
                                        <span>Up to {plan.max_users} Staff Members</span>
                                    </li>
                                    <li className="flex items-center gap-3 text-gray-600">
                                        <CheckCircle2 className="w-5 h-5 text-green-500 flex-shrink-0" />
                                        <span>{plan.max_branches} Location(s)</span>
                                    </li>
                                    {plan.features?.map((feature, i) => (
                                        <li key={i} className="flex items-center gap-3 text-gray-600">
                                            <CheckCircle2 className="w-5 h-5 text-green-500 flex-shrink-0" />
                                            <span>{feature}</span>
                                        </li>
                                    ))}
                                </ul>
                                <Link 
                                    href={`/register?plan=${plan.id}`} 
                                    className={`block w-full text-center py-3 rounded-xl font-bold transition-colors ${
                                        index === 1 
                                            ? 'bg-primary hover:bg-orange-600 text-white shadow-md shadow-primary/20' 
                                            : 'bg-gray-100 hover:bg-gray-200 text-gray-900'
                                    }`}
                                >
                                    Get Started
                                </Link>
                            </div>
                        ))}

                        {plans.length === 0 && (
                            <div className="col-span-full py-12 text-center text-gray-500 bg-white rounded-3xl border border-gray-100">
                                No pricing plans configured yet. Please check back later.
                            </div>
                        )}
                    </div>
                </div>
            </div>

            {/* Footer */}
            <footer className="bg-white border-t border-gray-100 py-12">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row justify-between items-center gap-4">
                    <div className="flex items-center gap-2">
                        <div className="w-8 h-8 rounded-lg bg-gray-900 flex items-center justify-center text-white">
                            <Store className="w-4 h-4" />
                        </div>
                        <span className="text-lg font-bold text-gray-900">RestoPOS</span>
                    </div>
                    <p className="text-gray-500 text-sm">© {new Date().getFullYear()} RestoPOS Inc. All rights reserved.</p>
                    <div className="flex gap-4">
                        <Link href="/admin/login" className="text-sm text-gray-400 hover:text-gray-900 transition-colors">Admin Portal</Link>
                    </div>
                </div>
            </footer>
        </div>
    );
}
