import React from 'react';
import { Link, usePage } from '@inertiajs/react';

export default function AdminLayout({ children }) {
    const { auth } = usePage().props;
    const user = auth?.user || { name: 'Admin' };

    const navigation = [
        { name: 'Dashboard', href: '/dashboard' },
        { name: 'POS Billing', href: '/pos' },
        { name: 'Tables', href: '/tables' },
        { name: 'Kitchen', href: '/kitchen' },
        { name: 'Menu', href: '/menu' },
        { name: 'Settings', href: '/settings/profile' },
    ];

    if (user.role_id === 2) {
        navigation.splice(5, 0, { name: 'Staff', href: '/staff' });
    }

    return (
        <div className="min-h-screen bg-background flex">
            {/* Sidebar */}
            <div className="w-64 bg-white shadow-xl flex flex-col fixed h-full z-10 transition-all duration-300">
                <div className="flex items-center justify-center h-20 border-b border-gray-100">
                    <h1 className="text-2xl font-bold text-primary flex items-center gap-2">
                        <span className="bg-primary text-white p-2 rounded-lg">POS</span>
                        Smart
                    </h1>
                </div>
                <nav className="flex-1 px-4 py-6 space-y-2 overflow-y-auto">
                    {navigation.map((item) => {
                        const isActive = window.location.pathname.startsWith(item.href);
                        return (
                            <Link
                                key={item.name}
                                href={item.href}
                                className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 ${
                                    isActive 
                                    ? 'bg-primary text-white shadow-md shadow-primary/30' 
                                    : 'text-gray-500 hover:bg-orange-50 hover:text-primary'
                                }`}
                            >
                                <span className="font-medium">{item.name}</span>
                            </Link>
                        );
                    })}
                </nav>
                <div className="p-4 border-t border-gray-100">
                    <Link
                        href="/logout"
                        method="post"
                        as="button"
                        className="flex items-center gap-3 px-4 py-3 w-full text-left text-gray-500 rounded-xl hover:bg-red-50 hover:text-red-500 transition-colors duration-200"
                    >
                        <span className="font-medium">Logout</span>
                    </Link>
                </div>
            </div>

            {/* Main Content */}
            <div className="flex-1 ml-64 flex flex-col min-h-screen">
                {/* Header */}
                <header className="h-20 bg-white shadow-sm flex items-center justify-between px-8 z-0">
                    <div>
                        <h2 className="text-xl font-bold text-gray-800">Welcome back, {user.name} 👋</h2>
                        <p className="text-sm text-gray-500">Here's what's happening with your store today.</p>
                    </div>
                    <div className="flex items-center gap-4">
                        <div className="w-10 h-10 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold">
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
