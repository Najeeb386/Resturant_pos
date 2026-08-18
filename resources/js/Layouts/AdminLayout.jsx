import React, { useState } from 'react';
import { Link, usePage } from '@inertiajs/react';
import { Menu, X, LogOut, LayoutDashboard, ShoppingBag, Utensils, Table, ChefHat, Package, BookOpen, Receipt, BarChart3, Users, Settings, Lock, AlertTriangle, ArrowRight, Mail, Box } from 'lucide-react';

export default function AdminLayout({ children }) {
    const { auth, tenantSubscription } = usePage().props;
    const user = auth?.user || { name: 'Admin' };
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    const isSuperAdmin = tenantSubscription?.isSuperAdmin || Number(user.role_id) === 1;
    const subStatus = tenantSubscription?.status || 'active';
    const allowedFeatures = Array.isArray(tenantSubscription?.features) ? tenantSubscription.features : [];

    const allNavigation = [
        { name: 'Dashboard', href: '/dashboard', roles: [2, 3], feature: 'dashboard', icon: LayoutDashboard },
        { name: 'POS Billing', href: '/pos', roles: [2, 3, 4], feature: 'pos_billing', icon: ShoppingBag },
        { name: 'Orders', href: '/orders', roles: [2, 3, 6], feature: 'orders', icon: Receipt },
        { name: 'Tables', href: '/tables', roles: [2, 4], feature: 'tables', icon: Table },
        { name: 'Kitchen', href: '/kitchen', roles: [2, 5], feature: 'kitchen', icon: ChefHat },
        { name: 'Inventory & Stock', href: '/inventory', roles: [2, 3, 5], feature: 'inventory', icon: Package },
        { name: 'Menu', href: '/menu', roles: [2, 3, 4], feature: 'menu', icon: BookOpen },
        { name: 'AI 3D Menu Studio', href: '/menu/3d-studio', roles: [2, 3, 4], feature: 'ai_3d_scanner', icon: Box },
        { name: 'Expenses', href: '/expenses', roles: [2], feature: 'expenses', icon: Utensils },
        { name: 'Reports', href: '/reports', roles: [2], feature: 'reports', icon: BarChart3 },
        { name: 'Staff', href: '/staff', roles: [2], feature: 'staff', icon: Users },
        { name: 'Settings', href: '/settings/profile', roles: [2], feature: 'settings', icon: Settings },
    ];

    // Check if a feature is allowed by plan
    const isFeatureAllowed = (featureKey) => {
        if (isSuperAdmin) return true;
        if (featureKey === 'dashboard' || featureKey === 'settings') return true;
        if (subStatus !== 'active') return false;

        // Matches feature ID or feature label name
        return allowedFeatures.some(f => 
            f === featureKey || 
            (typeof f === 'string' && f.toLowerCase().includes(featureKey.replace('_', ' ')))
        );
    };

    // Filter sidebar navigation
    const userRoleNavigation = allNavigation.filter(item => item.roles.includes(Number(user.role_id)));
    const navigation = userRoleNavigation.filter(item => isFeatureAllowed(item.feature));

    // Determine current active page & feature requirement
    const currentPath = window.location.pathname;
    const currentNavItem = allNavigation.find(item => currentPath.startsWith(item.href) && item.href !== '#');
    const isCurrentPageAllowed = !currentNavItem || isFeatureAllowed(currentNavItem.feature);

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
                
                {/* Subscription Status Banner in Sidebar */}
                {!isSuperAdmin && (
                    <div className="px-4 pt-4">
                        <div className={`p-3 rounded-xl border text-xs ${
                            subStatus === 'active' 
                                ? 'bg-emerald-50 border-emerald-100 text-emerald-800' 
                                : 'bg-amber-50 border-amber-200 text-amber-900'
                        }`}>
                            <div className="font-bold flex items-center justify-between">
                                <span>{tenantSubscription?.plan_name || 'Subscription'}</span>
                                <span className={`px-1.5 py-0.5 rounded text-[10px] uppercase font-extrabold ${
                                    subStatus === 'active' ? 'bg-emerald-200 text-emerald-900' : 'bg-amber-200 text-amber-900'
                                }`}>
                                    {subStatus}
                                </span>
                            </div>
                            {tenantSubscription?.ends_at && (
                                <div className="text-[11px] opacity-80 mt-1">
                                    Expires: {tenantSubscription.ends_at}
                                </div>
                            )}
                        </div>
                    </div>
                )}

                <nav className="flex-1 px-4 py-4 space-y-1.5 overflow-y-auto">
                    {navigation.map((item) => {
                        const isActive = currentPath.startsWith(item.href);
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
                    {subStatus !== 'active' && !isSuperAdmin ? (
                        <div className="max-w-2xl mx-auto my-12 bg-white border border-rose-200 rounded-3xl p-8 sm:p-10 shadow-xl text-center">
                            <div className="w-16 h-16 bg-rose-100 text-rose-600 rounded-2xl flex items-center justify-center mx-auto mb-5 shadow-xs">
                                <AlertTriangle className="w-8 h-8" />
                            </div>
                            
                            <h2 className="text-2xl sm:text-3xl font-extrabold text-slate-900 mb-3">
                                Subscription Expired
                            </h2>
                            
                            <p className="text-slate-600 text-base mb-6 leading-relaxed max-w-md mx-auto">
                                Your subscription has expired. For getting access kindly renew your subscription.
                            </p>

                            <div className="bg-slate-50 border border-slate-200 rounded-2xl p-5 text-left max-w-md mx-auto mb-6">
                                <h4 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">
                                    SaaS Administrator Contact Details
                                </h4>
                                <div className="flex items-center gap-3 text-sm text-slate-800 font-semibold mb-1">
                                    <Mail className="w-4 h-4 text-blue-600" />
                                    <span>admin@dinedesk.com</span>
                                </div>
                                <p className="text-xs text-slate-500 mt-2">
                                    Please contact the administrator to renew or extend your restaurant subscription plan.
                                </p>
                            </div>

                            <div className="flex justify-center gap-3">
                                <Link
                                    href="/logout"
                                    method="post"
                                    as="button"
                                    className="px-6 py-2.5 bg-slate-900 text-white font-medium rounded-xl hover:bg-slate-800 transition-colors text-sm"
                                >
                                    Log Out
                                </Link>
                            </div>
                        </div>
                    ) : isCurrentPageAllowed ? (
                        children
                    ) : (
                        <div className="max-w-2xl mx-auto my-12 bg-white border border-amber-200 rounded-3xl p-8 shadow-xl text-center">
                            <div className="w-16 h-16 bg-amber-100 text-amber-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
                                <Lock className="w-8 h-8" />
                            </div>
                            <h2 className="text-2xl font-bold text-gray-900 mb-2">
                                Feature Not Included in Your Plan
                            </h2>
                            <p className="text-gray-600 mb-6 max-w-md mx-auto">
                                The module "{currentNavItem?.name || 'Feature'}" is not enabled under your current plan ({tenantSubscription?.plan_name || 'Standard'}). Please contact the SaaS Administrator to upgrade your plan.
                            </p>
                            <div className="flex justify-center gap-4">
                                <Link 
                                    href="/dashboard" 
                                    className="px-6 py-3 bg-gray-900 text-white font-semibold rounded-xl hover:bg-gray-800 transition-colors inline-flex items-center gap-2 text-sm"
                                >
                                    Back to Dashboard
                                    <ArrowRight className="w-4 h-4" />
                                </Link>
                            </div>
                        </div>
                    )}
                </main>
            </div>
        </div>
    );
}
