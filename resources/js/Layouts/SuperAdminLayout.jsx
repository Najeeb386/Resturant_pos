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
    X,
    ChevronLeft,
    ChevronRight
} from 'lucide-react';

export default function SuperAdminLayout({ children }) {
    const { auth } = usePage().props;
    const user = auth?.user || { name: 'Super Admin' };
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    // Persist sidebar collapsed state in localStorage
    const [isCollapsed, setIsCollapsed] = useState(() => {
        if (typeof window !== 'undefined') {
            return localStorage.getItem('superadmin_sidebar_collapsed') === 'true';
        }
        return false;
    });

    const toggleSidebar = () => {
        setIsCollapsed(prev => {
            const next = !prev;
            if (typeof window !== 'undefined') {
                localStorage.setItem('superadmin_sidebar_collapsed', String(next));
            }
            return next;
        });
    };

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
            <aside className={`bg-slate-900 shadow-xl flex flex-col fixed h-full z-40 transition-all duration-300 left-0 top-0 ${
                isCollapsed ? 'lg:w-20' : 'lg:w-64'
            } ${
                isMobileMenuOpen ? 'w-64 translate-x-0' : '-translate-x-full lg:translate-x-0'
            }`}>
                <div className="flex items-center justify-between px-4 h-20 border-b border-slate-800 relative">
                    <div className="flex items-center gap-3 overflow-hidden">
                        <img src="/images/logo.png" alt="DineDesk Logo" className="w-9 h-9 rounded-xl object-contain shadow-sm bg-slate-800 p-1 shrink-0" />
                        <h1 className={`text-xl font-extrabold tracking-tight text-white transition-opacity duration-200 ${
                            isCollapsed ? 'lg:hidden' : 'block'
                        }`}>
                            Dine<span className="text-blue-400">Desk</span>
                        </h1>
                    </div>

                    {/* Desktop Toggle Button */}
                    <button 
                        onClick={toggleSidebar}
                        className="hidden lg:flex items-center justify-center w-7 h-7 rounded-full bg-slate-800 hover:bg-blue-600 hover:text-white text-slate-400 shadow-xs transition-colors"
                        title={isCollapsed ? "Expand Sidebar" : "Collapse Sidebar"}
                    >
                        {isCollapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
                    </button>

                    {/* Mobile Close Button */}
                    <button 
                        onClick={() => setIsMobileMenuOpen(false)}
                        className="lg:hidden p-2 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                <nav className="flex-1 px-3 py-6 space-y-1.5 overflow-y-auto overflow-x-hidden">
                    {navigation.map((item) => {
                        const isActive = typeof window !== 'undefined' && window.location.pathname.startsWith(item.href) && item.href !== '#';
                        const Icon = item.icon;
                        return (
                            <Link
                                key={item.name}
                                href={item.href}
                                onClick={() => setIsMobileMenuOpen(false)}
                                title={isCollapsed ? item.name : undefined}
                                className={`flex items-center gap-3 px-3.5 py-3 rounded-xl transition-all relative group ${
                                    isActive 
                                    ? 'bg-blue-600 text-white shadow-md shadow-blue-500/30 font-semibold' 
                                    : 'text-slate-400 hover:bg-slate-800 hover:text-white'
                                } ${isCollapsed ? 'lg:justify-center' : ''}`}
                            >
                                <Icon className={`w-5 h-5 shrink-0 ${isActive ? 'text-white' : ''}`} />
                                <span className={`font-medium text-sm transition-opacity duration-200 whitespace-nowrap ${
                                    isCollapsed ? 'lg:hidden' : 'block'
                                }`}>
                                    {item.name}
                                </span>
                                {isCollapsed && (
                                    <div className="hidden lg:group-hover:block absolute left-full ml-2 px-3 py-1.5 bg-slate-800 text-white text-xs font-semibold rounded-lg shadow-lg z-50 whitespace-nowrap">
                                        {item.name}
                                    </div>
                                )}
                            </Link>
                        );
                    })}
                </nav>

                <div className="p-3 border-t border-slate-800">
                    <Link
                        href="/logout"
                        method="post"
                        as="button"
                        title={isCollapsed ? "Logout" : undefined}
                        className={`flex items-center gap-3 px-3.5 py-3 w-full text-left text-slate-400 rounded-xl hover:bg-red-500/10 hover:text-red-400 transition-colors relative group ${
                            isCollapsed ? 'lg:justify-center' : ''
                        }`}
                    >
                        <LogOut className="w-5 h-5 shrink-0" />
                        <span className={`font-medium text-sm transition-opacity duration-200 ${
                            isCollapsed ? 'lg:hidden' : 'block'
                        }`}>
                            Logout
                        </span>
                        {isCollapsed && (
                            <div className="hidden lg:group-hover:block absolute left-full ml-2 px-3 py-1.5 bg-red-600 text-white text-xs font-semibold rounded-lg shadow-lg z-50 whitespace-nowrap">
                                Logout
                            </div>
                        )}
                    </Link>
                </div>
            </aside>

            {/* Main Content */}
            <div className={`flex-1 flex flex-col min-h-screen w-full min-w-0 transition-all duration-300 ${
                isCollapsed ? 'lg:ml-20' : 'lg:ml-64'
            }`}>
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
                        
                        {/* Desktop Toggle Button */}
                        <button
                            onClick={toggleSidebar}
                            className="hidden lg:flex items-center justify-center p-2 rounded-xl text-slate-500 hover:text-blue-600 hover:bg-slate-100 border border-slate-200 transition-colors"
                            title={isCollapsed ? "Expand Sidebar" : "Collapse Sidebar"}
                        >
                            {isCollapsed ? <ChevronRight className="w-5 h-5" /> : <ChevronLeft className="w-5 h-5" />}
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
