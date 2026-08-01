import React, { useState } from 'react';
import { Link, usePage } from '@inertiajs/react';
import { Menu, X, LogOut, LayoutDashboard, ShoppingBag, Utensils, Table, ChefHat, Package, BookOpen, Receipt, BarChart3, Users, Settings } from 'lucide-react';

export default function AdminLayout({ children }) {
    const { auth } = usePage().props;
    const user = auth?.user || { name: 'Admin' };
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    const allNavigation = [
        { name: 'Dashboard', href: '/dashboard', roles: [2, 3], icon: LayoutDashboard },
        { name: 'POS Billing', href: '/pos', roles: [2, 3, 4], icon: ShoppingBag },
        { name: 'Orders', href: '/orders', roles: [2, 3, 6], icon: Receipt },
        { name: 'Tables', href: '/tables', roles: [2, 4], icon: Table },
        { name: 'Kitchen', href: '/kitchen', roles: [2, 5], icon: ChefHat },
        { name: 'Inventory & Stock', href: '/inventory', roles: [2, 3, 5], icon: Package },
        { name: 'Menu', href: '/menu', roles: [2, 3, 4], icon: BookOpen },
        { name: 'Expenses', href: '/expenses', roles: [2], icon: Utensils },
        { name: 'Reports', href: '/reports', roles: [2], icon: BarChart3 },
        { name: 'Staff', href: '/staff', roles: [2], icon: Users },
        { name: 'Settings', href: '/settings/profile', roles: [2], icon: Settings },
    ];

    const navigation = allNavigation.filter(item => item.roles.includes(Number(user.role_id)));

    return (
        <div className="min-h-screen bg-gray-50 flex">
            {/* Mobile Backdrop */}
            {isMobileMenuOpen && (
                <div 
                    className="fixed inset-0 bg-gray-900/50 backdrop-blur-xs z-30 lg:hidden transition-opacity"
                    onClick={() => setIsMobileMenuOpen(false)}
                />
            )}

            {/* Sidebar */}
            <aside className={`w-64 bg-white shadow-xl flex flex-col fixed h-full z-40 transition-transform duration-300 left-0 top-0 ${
                isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'
            }`}>
                <div className="flex items-center justify-between px-6 h-20 border-b border-gray-100">
                    <div className="flex items-center gap-3">
                        <img src="/images/logo.png" alt="DineDesk Logo" className="w-9 h-9 rounded-xl object-contain shadow-sm" />
                        <h1 className="text-xl font-extrabold tracking-tight text-gray-900">
                            Dine<span className="text-primary">Desk</span>
                        </h1>
                    </div>
                    {/* Close button for mobile */}
                    <button 
                        onClick={() => setIsMobileMenuOpen(false)}
                        className="lg:hidden p-2 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>
                
                <nav className="flex-1 px-4 py-6 space-y-1.5 overflow-y-auto">
                    {navigation.map((item) => {
                        const isActive = window.location.pathname.startsWith(item.href);
                        const Icon = item.icon;
                        return (
                            <Link
                                key={item.name}
                                href={item.href}
                                onClick={() => setIsMobileMenuOpen(false)}
                                className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${
                                    isActive 
                                    ? 'bg-primary text-white shadow-md shadow-primary/30 font-semibold' 
                                    : 'text-gray-600 hover:bg-orange-50 hover:text-primary'
                                }`}
                            >
                                {Icon && <Icon className={`w-5 h-5 ${isActive ? 'text-white' : 'text-gray-400 group-hover:text-primary'}`} />}
                                <span className="font-medium text-sm sm:text-base">{item.name}</span>
                            </Link>
                        );
                    })}
                </nav>

                <div className="p-4 border-t border-gray-100">
                    <Link
                        href="/logout"
                        method="post"
                        as="button"
                        className="flex items-center gap-3 px-4 py-3 w-full text-left text-gray-600 rounded-xl hover:bg-red-50 hover:text-red-500 transition-colors"
                    >
                        <LogOut className="w-5 h-5 text-gray-400" />
                        <span className="font-medium text-sm sm:text-base">Logout</span>
                    </Link>
                </div>
            </aside>

            {/* Main Content Area */}
            <div className="flex-1 lg:ml-64 flex flex-col min-h-screen w-full min-w-0">
                {/* Header */}
                <header className="h-20 bg-white shadow-xs border-b border-gray-100 flex items-center justify-between px-4 sm:px-6 lg:px-8 sticky top-0 z-20">
                    <div className="flex items-center gap-3">
                        <button 
                            onClick={() => setIsMobileMenuOpen(true)}
                            className="lg:hidden p-2.5 rounded-xl text-gray-700 hover:bg-gray-100 border border-gray-200 shadow-2xs"
                            aria-label="Open menu"
                        >
                            <Menu className="w-6 h-6" />
                        </button>
                        <div>
                            <h2 className="text-base sm:text-xl font-bold text-gray-800 line-clamp-1">Welcome back, {user.name} 👋</h2>
                            <p className="text-xs sm:text-sm text-gray-500 hidden sm:block">Here's what's happening with your store today.</p>
                        </div>
                    </div>

                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-sm sm:text-base shadow-2xs">
                            {user.name ? user.name.charAt(0).toUpperCase() : 'A'}
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
