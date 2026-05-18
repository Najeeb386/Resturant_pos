import React from 'react';
import { Link, usePage } from '@inertiajs/react';
import { 
    LayoutDashboard, 
    Store, 
    CreditCard,
    LogOut,
    Users
} from 'lucide-react';

export default function SuperAdminLayout({ children }) {
    const { auth } = usePage().props;
    const user = auth?.user || { name: 'Super Admin' };

    const navigation = [
        { name: 'Dashboard', href: '/admin/dashboard', icon: LayoutDashboard },
        { name: 'Tenants (Restaurants)', href: '/admin/restaurants', icon: Store },
        { name: 'Subscription Plans', href: '/admin/plans', icon: CreditCard },
        { name: 'Admins', href: '#', icon: Users },
    ];

    return (
        <div className="min-h-screen bg-slate-50 flex">
            {/* Sidebar */}
            <div className="w-64 bg-slate-900 shadow-xl flex flex-col fixed h-full z-10 transition-all duration-300">
                <div className="flex items-center justify-center h-20 border-b border-slate-800">
                    <h1 className="text-2xl font-bold text-white flex items-center gap-2">
                        <span className="bg-blue-600 text-white p-2 rounded-lg text-sm tracking-widest uppercase">SaaS</span>
                        Admin
                    </h1>
                </div>
                <nav className="flex-1 px-4 py-6 space-y-2 overflow-y-auto">
                    {navigation.map((item) => {
                        const isActive = window.location.pathname.startsWith(item.href) && item.href !== '#';
                        return (
                            <Link
                                key={item.name}
                                href={item.href}
                                className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 ${
                                    isActive 
                                    ? 'bg-blue-600 text-white shadow-md shadow-blue-500/30' 
                                    : 'text-slate-400 hover:bg-slate-800 hover:text-white'
                                }`}
                            >
                                <item.icon className={`w-5 h-5 ${isActive ? 'text-white' : ''}`} />
                                <span className="font-medium">{item.name}</span>
                            </Link>
                        );
                    })}
                </nav>
                <div className="p-4 border-t border-slate-800">
                    <Link
                        href="/logout"
                        method="post"
                        as="button"
                        className="flex items-center gap-3 px-4 py-3 w-full text-left text-slate-400 rounded-xl hover:bg-red-500/10 hover:text-red-400 transition-colors duration-200"
                    >
                        <LogOut className="w-5 h-5" />
                        <span className="font-medium">Logout</span>
                    </Link>
                </div>
            </div>

            {/* Main Content */}
            <div className="flex-1 ml-64 flex flex-col min-h-screen">
                {/* Header */}
                <header className="h-20 bg-white shadow-sm flex items-center justify-between px-8 z-0">
                    <div>
                        <h2 className="text-xl font-bold text-slate-800">Super Admin Portal</h2>
                        <p className="text-sm text-slate-500">Manage tenants and platform metrics.</p>
                    </div>
                    <div className="flex items-center gap-4">
                        <div className="w-10 h-10 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center font-bold">
                            {user.name.charAt(0).toUpperCase()}
                        </div>
                    </div>
                </header>

                {/* Page Content */}
                <main className="flex-1 p-8">
                    {children}
                </main>
            </div>
        </div>
    );
}
