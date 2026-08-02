import React, { useState } from 'react';
import { Link, usePage } from '@inertiajs/react';
import { 
    LayoutDashboard, 
    Store, 
    CreditCard,
    RefreshCw,
    Receipt,
    BarChart3,
    LogOut,
    Settings,
    Menu,
    X
} from 'lucide-react';

export default function SuperAdminLayout({ children }) {
    const { auth } = usePage().props;
    const user = auth?.user || { name: 'Super Admin' };
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    const navigation = [
        { name: 'Dashboard', href: '/admin/dashboard', icon: LayoutDashboard },
        { name: 'Tenants (Restaurants)', href: '/admin/restaurants', icon: Store },
        { name: 'Subscriptions', href: '/admin/subscriptions', icon: RefreshCw },
        { name: 'Subscription Plans', href: '/admin/plans', icon: CreditCard },
        { name: 'Platform Expenses', href: '/admin/expenses', icon: Receipt },
        { name: 'Financial Reports', href: '/admin/reports', icon: BarChart3 },
        { name: 'Settings', href: '/admin/settings', icon: Settings },
    ];

    return (
        <div className="min-h-screen bg-slate-50 flex">
            {/* Mobile Backdrop */}
            {isMobileMenuOpen && (
                <div 
                    className="fixed inset-0 bg-slate-950/60 backdrop-blur-xs z-30 lg:hidden transition-opacity"
                    onClick={() => setIsMobileMenuOpen(false)}
                />
            )}

            {/* Sidebar */}
            <aside className={`w-64 bg-slate-900 shadow-xl flex flex-col fixed h-full z-40 transition-transform duration-300 left-0 top-0 ${
                isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'
            }`}>
                <div className="flex items-center justify-between px-6 h-20 border-b border-slate-800">
                    <div className="flex items-center gap-3">
                        <img src="/images/logo.png" alt="DineDesk Logo" className="w-9 h-9 rounded-xl object-contain shadow-sm bg-slate-800 p-1" />
                        <h1 className="text-xl font-extrabold tracking-tight text-white">
                            Dine<span className="text-blue-400">Desk</span>
                        </h1>
                    </div>
                    <button 
                        onClick={() => setIsMobileMenuOpen(false)}
                        className="lg:hidden p-2 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                <nav className="flex-1 px-4 py-6 space-y-1.5 overflow-y-auto">
                    {navigation.map((item) => {
                        const isActive = window.location.pathname.startsWith(item.href) && item.href !== '#';
                        const Icon = item.icon;
                        return (
                            <Link
                                key={item.name}
                                href={item.href}
                                onClick={() => setIsMobileMenuOpen(false)}
                                className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${
                                    isActive 
                                    ? 'bg-blue-600 text-white shadow-md shadow-blue-500/30 font-semibold' 
                                    : 'text-slate-400 hover:bg-slate-800 hover:text-white'
                                }`}
                            >
                                <Icon className={`w-5 h-5 ${isActive ? 'text-white' : ''}`} />
                                <span className="font-medium text-sm sm:text-base">{item.name}</span>
                            </Link>
                        );
                    })}
                </nav>

                <div className="p-4 border-t border-slate-800">
                    <Link
                        href="/logout"
                        method="post"
                        as="button"
                        className="flex items-center gap-3 px-4 py-3 w-full text-left text-slate-400 rounded-xl hover:bg-red-500/10 hover:text-red-400 transition-colors"
                    >
                        <LogOut className="w-5 h-5" />
                        <span className="font-medium text-sm sm:text-base">Logout</span>
                    </Link>
                </div>
            </aside>

            {/* Main Content */}
            <div className="flex-1 lg:ml-64 flex flex-col min-h-screen w-full min-w-0">
                {/* Header */}
                <header className="h-20 bg-white shadow-xs border-b border-slate-100 flex items-center justify-between px-4 sm:px-6 lg:px-8 sticky top-0 z-20">
                    <div className="flex items-center gap-3">
                        <button 
                            onClick={() => setIsMobileMenuOpen(true)}
                            className="lg:hidden p-2.5 rounded-xl text-slate-700 hover:bg-slate-100 border border-slate-200 shadow-2xs"
                            aria-label="Open menu"
                        >
                            <Menu className="w-6 h-6" />
                        </button>
                        <div>
                            <h2 className="text-base sm:text-xl font-bold text-slate-800">Super Admin Portal</h2>
                            <p className="text-xs sm:text-sm text-slate-500 hidden sm:block">Manage tenants and platform metrics.</p>
                        </div>
                    </div>
                    <div className="flex items-center gap-4">
                        <div className="w-10 h-10 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center font-bold text-sm sm:text-base">
                            {user.name ? user.name.charAt(0).toUpperCase() : 'S'}
                        </div>
                    </div>
                </header>

                {/* Page Content */}
                <main className="flex-1 p-4 sm:p-6 lg:p-8 min-w-0">
                    {children}
                </main>
            </div>
        </div>
    );
}
