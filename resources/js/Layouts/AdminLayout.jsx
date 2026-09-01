import React, { useState, useEffect } from 'react';
import { Link, usePage } from '@inertiajs/react';
import { 
    Menu, X, LogOut, LayoutDashboard, ShoppingBag, Utensils, Table, 
    ChefHat, Package, BookOpen, Receipt, BarChart3, Users, Settings, 
    Lock, AlertTriangle, ArrowRight, Mail, Box, ChevronLeft, ChevronRight 
} from 'lucide-react';

export default function AdminLayout({ children }) {
    const { auth, tenantSubscription } = usePage().props;
    const user = auth?.user || { name: 'Admin' };
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    // Persist sidebar collapsed state in localStorage
    const [isCollapsed, setIsCollapsed] = useState(() => {
        if (typeof window !== 'undefined') {
            return localStorage.getItem('sidebar_collapsed') === 'true';
        }
        return false;
    });

    const toggleSidebar = () => {
        setIsCollapsed(prev => {
            const next = !prev;
            if (typeof window !== 'undefined') {
                localStorage.setItem('sidebar_collapsed', String(next));
            }
            return next;
        });
    };

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

    const isFeatureAllowed = (featureKey) => {
        if (isSuperAdmin) return true;
        if (featureKey === 'dashboard' || featureKey === 'settings') return true;
        if (subStatus !== 'active') return false;
        return allowedFeatures.some(f => 
            f === featureKey || 
            (typeof f === 'string' && f.toLowerCase().includes(featureKey.replace('_', ' ')))
        );
    };

    const userRoleNavigation = allNavigation.filter(item => item.roles.includes(Number(user.role_id)));
    const navigation = userRoleNavigation.filter(item => isFeatureAllowed(item.feature));

    const currentPath = typeof window !== 'undefined' ? window.location.pathname : '';
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
            <aside className={`bg-white shadow-xl flex flex-col fixed h-full z-40 transition-all duration-300 left-0 top-0 ${
                isCollapsed ? 'lg:w-20' : 'lg:w-64'
            } ${
                isMobileMenuOpen ? 'w-64 translate-x-0' : '-translate-x-full lg:translate-x-0'
            }`}>
                {/* Header Logo & Collapse Toggle */}
                <div className="flex items-center justify-between px-4 h-20 border-b border-gray-100 relative">
                    <div className="flex items-center gap-3 overflow-hidden">
                        <img src="/images/logo.png" alt="DineDesk Logo" className="w-9 h-9 rounded-xl object-contain shadow-sm shrink-0" />
                        <h1 className={`text-xl font-extrabold tracking-tight text-gray-900 transition-opacity duration-200 ${
                            isCollapsed ? 'lg:hidden' : 'block'
                        }`}>
                            Dine<span className="text-primary">Desk</span>
                        </h1>
                    </div>

                    {/* Desktop Collapse / Expand Toggle Button */}
                    <button 
                        onClick={toggleSidebar}
                        className="hidden lg:flex items-center justify-center w-7 h-7 rounded-full bg-gray-100 hover:bg-primary hover:text-white text-gray-500 shadow-xs transition-colors"
                        title={isCollapsed ? "Expand Sidebar" : "Collapse Sidebar"}
                    >
                        {isCollapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
                    </button>

                    {/* Mobile Close Button */}
                    <button 
                        onClick={() => setIsMobileMenuOpen(false)}
                        className="lg:hidden p-2 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>
                
                {/* Subscription Status Banner */}
                {!isSuperAdmin && (
                    <div className="px-3 pt-3">
                        <div className={`p-2.5 rounded-xl border text-xs transition-all ${
                            subStatus === 'active' 
                                ? 'bg-emerald-50 border-emerald-100 text-emerald-800' 
                                : 'bg-amber-50 border-amber-200 text-amber-900'
                        }`}>
                            <div className="font-bold flex items-center justify-between">
                                <span className={isCollapsed ? 'lg:hidden' : 'block'}>
                                    {tenantSubscription?.plan_name || 'Subscription'}
                                </span>
                                <span className={`px-1.5 py-0.5 rounded text-[10px] uppercase font-extrabold mx-auto lg:mx-0 ${
                                    subStatus === 'active' ? 'bg-emerald-200 text-emerald-900' : 'bg-amber-200 text-amber-900'
                                }`}>
                                    {subStatus}
                                </span>
                            </div>
                            {tenantSubscription?.ends_at && !isCollapsed && (
                                <div className="text-[11px] opacity-80 mt-1 hidden lg:block">
                                    Expires: {tenantSubscription.ends_at}
                                </div>
                            )}
                        </div>
                    </div>
                )}

                {/* Navigation Links */}
                <nav className="flex-1 px-3 py-4 space-y-1.5 overflow-y-auto overflow-x-hidden">
                    {navigation.map((item) => {
                        const isActive = currentPath.startsWith(item.href);
                        const Icon = item.icon;
                        return (
                            <Link
                                key={item.name}
                                href={item.href}
                                onClick={() => setIsMobileMenuOpen(false)}
                                title={isCollapsed ? item.name : undefined}
                                className={`flex items-center gap-3 px-3.5 py-3 rounded-xl transition-all relative group ${
                                    isActive 
                                    ? 'bg-primary text-white shadow-md shadow-primary/30 font-semibold' 
                                    : 'text-gray-600 hover:bg-orange-50 hover:text-primary'
                                } ${isCollapsed ? 'lg:justify-center' : ''}`}
                            >
                                {Icon && <Icon className={`w-5 h-5 shrink-0 ${isActive ? 'text-white' : 'text-gray-400 group-hover:text-primary'}`} />}
                                <span className={`font-medium text-sm transition-opacity duration-200 whitespace-nowrap ${
                                    isCollapsed ? 'lg:hidden' : 'block'
                                }`}>
                                    {item.name}
                                </span>
                                {isCollapsed && (
                                    <div className="hidden lg:group-hover:block absolute left-full ml-2 px-3 py-1.5 bg-gray-900 text-white text-xs font-semibold rounded-lg shadow-lg z-50 whitespace-nowrap">
                                        {item.name}
                                    </div>
                                )}
                            </Link>
                        );
                    })}
                </nav>

                {/* Logout Button */}
                <div className="p-3 border-t border-gray-100">
                    <Link
                        href="/logout"
                        method="post"
                        as="button"
                        title={isCollapsed ? "Logout" : undefined}
                        className={`flex items-center gap-3 px-3.5 py-3 w-full text-left text-gray-600 rounded-xl hover:bg-red-50 hover:text-red-500 transition-colors relative group ${
                            isCollapsed ? 'lg:justify-center' : ''
                        }`}
                    >
                        <LogOut className="w-5 h-5 text-gray-400 shrink-0 group-hover:text-red-500" />
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

            {/* Main Content Area */}
            <div className={`flex-1 flex flex-col min-h-screen w-full min-w-0 transition-all duration-300 ${
                isCollapsed ? 'lg:ml-20' : 'lg:ml-64'
            }`}>
                {/* Top Header */}
                <header className="h-20 bg-white shadow-xs border-b border-gray-100 flex items-center justify-between px-4 sm:px-6 lg:px-8 sticky top-0 z-20">
                    <div className="flex items-center gap-3">
                        {/* Mobile Open Drawer Button */}
                        <button 
                            onClick={() => setIsMobileMenuOpen(true)}
                            className="lg:hidden p-2.5 rounded-xl text-gray-700 hover:bg-gray-100 border border-gray-200 shadow-2xs"
                            aria-label="Open menu"
                        >
                            <Menu className="w-6 h-6" />
                        </button>
                        
                        {/* Desktop Toggle Button in Top Bar */}
                        <button
                            onClick={toggleSidebar}
                            className="hidden lg:flex items-center justify-center p-2 rounded-xl text-gray-500 hover:text-primary hover:bg-orange-50 border border-gray-200 transition-colors"
                            title={isCollapsed ? "Expand Sidebar" : "Collapse Sidebar"}
                        >
                            {isCollapsed ? <ChevronRight className="w-5 h-5" /> : <ChevronLeft className="w-5 h-5" />}
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
                <main className="flex-1 p-3 sm:p-5 lg:p-6 min-w-0 max-w-full overflow-x-hidden">
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
