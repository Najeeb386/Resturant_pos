import React, { useState, useMemo } from 'react';
import SuperAdminLayout from '../../Layouts/SuperAdminLayout';
import { Card, CardContent } from '../../Components/ui/Card';
import { Badge } from '../../Components/ui/Badge';
import { Button } from '../../Components/ui/Button';
import { 
    Search, 
    Filter, 
    RefreshCw, 
    Calendar, 
    XCircle, 
    CheckCircle2, 
    Clock, 
    AlertTriangle,
    Plus,
    X,
    Layers
} from 'lucide-react';
import { useForm, router } from '@inertiajs/react';
import { Dialog } from '@headlessui/react';

export default function Subscriptions({ subscriptions = [], plans = [] }) {
    const [searchTerm, setSearchTerm] = useState('');
    const [statusFilter, setStatusFilter] = useState('all');
    const [planFilter, setPlanFilter] = useState('all');

    // State for Extend Modal
    const [selectedSubForExtend, setSelectedSubForExtend] = useState(null);
    const [extendMonths, setExtendMonths] = useState(1);
    const [isExtendModalOpen, setIsExtendModalOpen] = useState(false);

    // Compute Summary Stats
    const stats = useMemo(() => {
        const total = subscriptions.length;
        let active = 0;
        let expired = 0;
        let cancelled = 0;

        subscriptions.forEach(sub => {
            const isExpired = sub.ends_at && new Date(sub.ends_at) < new Date();
            if (sub.status === 'cancelled') {
                cancelled++;
            } else if (sub.status === 'expired' || isExpired) {
                expired++;
            } else if (sub.status === 'active') {
                active++;
            }
        });

        return { total, active, expired, cancelled };
    }, [subscriptions]);

    // Real-time Search and Filter Logic
    const filteredSubscriptions = useMemo(() => {
        return subscriptions.filter(sub => {
            const isExpired = sub.ends_at && new Date(sub.ends_at) < new Date();
            const currentStatus = sub.status === 'cancelled' 
                ? 'cancelled' 
                : (isExpired ? 'expired' : (sub.status || 'active'));

            // Search query match
            const searchLower = searchTerm.toLowerCase();
            const restaurantName = sub.restaurant?.name?.toLowerCase() || '';
            const restaurantEmail = sub.restaurant?.email?.toLowerCase() || '';
            const planName = sub.plan?.name?.toLowerCase() || '';
            const matchesSearch = !searchTerm || 
                restaurantName.includes(searchLower) || 
                restaurantEmail.includes(searchLower) ||
                planName.includes(searchLower);

            // Status filter match
            const matchesStatus = statusFilter === 'all' || currentStatus === statusFilter;

            // Plan filter match
            const matchesPlan = planFilter === 'all' || (sub.plan?.id?.toString() === planFilter.toString());

            return matchesSearch && matchesStatus && matchesPlan;
        });
    }, [subscriptions, searchTerm, statusFilter, planFilter]);

    // Action Handlers
    const handleRenew = (subId) => {
        if (confirm('Are you sure you want to renew this subscription for 1 month?')) {
            router.post(`/admin/subscriptions/${subId}/renew`, { months: 1 });
        }
    };

    const openExtendModal = (sub) => {
        setSelectedSubForExtend(sub);
        setExtendMonths(1);
        setIsExtendModalOpen(true);
    };

    const handleExtendSubmit = (e) => {
        e.preventDefault();
        if (!selectedSubForExtend) return;

        router.post(`/admin/subscriptions/${selectedSubForExtend.id}/extend`, { months: extendMonths }, {
            onSuccess: () => {
                setIsExtendModalOpen(false);
                setSelectedSubForExtend(null);
            }
        });
    };

    const handleCancel = (subId) => {
        if (confirm('Are you sure you want to cancel this subscription? The restaurant will lose access after expiry.')) {
            router.post(`/admin/subscriptions/${subId}/cancel`);
        }
    };

    const clearFilters = () => {
        setSearchTerm('');
        setStatusFilter('all');
        setPlanFilter('all');
    };

    return (
        <SuperAdminLayout>
            {/* Header */}
            <div className="mb-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900 mb-1">Subscription Management</h1>
                    <p className="text-slate-500 text-sm">Monitor, renew, extend, and manage all tenant subscriptions.</p>
                </div>
            </div>

            {/* Metrics Overview */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
                <Card className="border-slate-200 bg-white">
                    <CardContent className="p-4 flex items-center justify-between">
                        <div>
                            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Total Subscriptions</p>
                            <h3 className="text-2xl font-extrabold text-slate-900 mt-1">{stats.total}</h3>
                        </div>
                        <div className="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
                            <Layers className="w-6 h-6" />
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-slate-200 bg-white">
                    <CardContent className="p-4 flex items-center justify-between">
                        <div>
                            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Active</p>
                            <h3 className="text-2xl font-extrabold text-emerald-600 mt-1">{stats.active}</h3>
                        </div>
                        <div className="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
                            <CheckCircle2 className="w-6 h-6" />
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-slate-200 bg-white">
                    <CardContent className="p-4 flex items-center justify-between">
                        <div>
                            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Expired</p>
                            <h3 className="text-2xl font-extrabold text-amber-600 mt-1">{stats.expired}</h3>
                        </div>
                        <div className="w-12 h-12 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
                            <AlertTriangle className="w-6 h-6" />
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-slate-200 bg-white">
                    <CardContent className="p-4 flex items-center justify-between">
                        <div>
                            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Cancelled</p>
                            <h3 className="text-2xl font-extrabold text-rose-600 mt-1">{stats.cancelled}</h3>
                        </div>
                        <div className="w-12 h-12 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center">
                            <XCircle className="w-6 h-6" />
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Filter & Realtime Search Controls */}
            <Card className="mb-6 border-slate-200 shadow-xs">
                <CardContent className="p-4">
                    <div className="flex flex-col lg:flex-row gap-4 items-center justify-between">
                        {/* Real-time Search Input */}
                        <div className="relative w-full lg:w-96">
                            <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
                            <input
                                type="text"
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                                placeholder="Search by restaurant name, email, plan..."
                                className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
                            />
                            {searchTerm && (
                                <button 
                                    onClick={() => setSearchTerm('')}
                                    className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
                                >
                                    <X className="w-4 h-4" />
                                </button>
                            )}
                        </div>

                        {/* Filters */}
                        <div className="flex flex-wrap items-center gap-3 w-full lg:w-auto">
                            <div className="flex items-center gap-2">
                                <Filter className="w-4 h-4 text-slate-400" />
                                <span className="text-xs font-medium text-slate-500 uppercase">Filters:</span>
                            </div>

                            {/* Status Filter */}
                            <select
                                value={statusFilter}
                                onChange={(e) => setStatusFilter(e.target.value)}
                                className="bg-slate-50 border border-slate-200 text-slate-700 text-sm rounded-xl px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                            >
                                <option value="all">All Statuses</option>
                                <option value="active">Active</option>
                                <option value="expired">Expired</option>
                                <option value="cancelled">Cancelled</option>
                            </select>

                            {/* Plan Filter */}
                            <select
                                value={planFilter}
                                onChange={(e) => setPlanFilter(e.target.value)}
                                className="bg-slate-50 border border-slate-200 text-slate-700 text-sm rounded-xl px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                            >
                                <option value="all">All Plans</option>
                                {plans.map(p => (
                                    <option key={p.id} value={p.id}>{p.name}</option>
                                ))}
                            </select>

                            {/* Clear Filters Button */}
                            {(searchTerm || statusFilter !== 'all' || planFilter !== 'all') && (
                                <Button 
                                    variant="ghost" 
                                    size="sm"
                                    onClick={clearFilters}
                                    className="text-slate-500 hover:text-slate-800 text-xs"
                                >
                                    Clear Filters
                                </Button>
                            )}
                        </div>
                    </div>
                </CardContent>
            </Card>

            {/* Subscriptions Table */}
            <Card className="border-slate-200 shadow-sm overflow-hidden">
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-slate-50/80 border-b border-slate-200">
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Restaurant</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Plan & Price</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Start Date</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">End Date</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Status</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {filteredSubscriptions.length === 0 ? (
                                    <tr>
                                        <td colSpan="6" className="py-12 text-center text-slate-500">
                                            <div className="flex flex-col items-center justify-center">
                                                <AlertTriangle className="w-8 h-8 text-slate-300 mb-2" />
                                                <p className="font-medium text-slate-600">No subscriptions found matching your filters.</p>
                                                <p className="text-xs text-slate-400 mt-1">Try clearing your search term or status filter.</p>
                                            </div>
                                        </td>
                                    </tr>
                                ) : filteredSubscriptions.map(sub => {
                                    const isExpired = sub.ends_at && new Date(sub.ends_at) < new Date();
                                    const currentStatus = sub.status === 'cancelled' 
                                        ? 'cancelled' 
                                        : (isExpired ? 'expired' : (sub.status || 'active'));

                                    return (
                                        <tr key={sub.id} className="hover:bg-slate-50/50 transition-colors">
                                            {/* Restaurant Column */}
                                            <td className="py-4 px-6">
                                                <div className="font-bold text-slate-900">{sub.restaurant?.name || 'N/A'}</div>
                                                <div className="text-xs text-slate-500">{sub.restaurant?.email || 'No Email'}</div>
                                            </td>

                                            {/* Plan & Price Column */}
                                            <td className="py-4 px-6">
                                                <div className="font-semibold text-slate-800">{sub.plan?.name || 'Standard'}</div>
                                                <div className="text-xs text-slate-500">${sub.plan?.price || '0.00'} / {sub.plan?.billing_cycle || 'month'}</div>
                                            </td>

                                            {/* Start Date */}
                                            <td className="py-4 px-6 text-sm text-slate-600">
                                                {sub.starts_at ? new Date(sub.starts_at).toLocaleDateString() : 'N/A'}
                                            </td>

                                            {/* End Date */}
                                            <td className="py-4 px-6 text-sm font-medium text-slate-700">
                                                {sub.ends_at ? new Date(sub.ends_at).toLocaleDateString() : 'N/A'}
                                            </td>

                                            {/* Status Badge */}
                                            <td className="py-4 px-6">
                                                {currentStatus === 'active' && (
                                                    <Badge className="bg-emerald-50 text-emerald-700 border border-emerald-200">Active</Badge>
                                                )}
                                                {currentStatus === 'expired' && (
                                                    <Badge className="bg-amber-50 text-amber-700 border border-amber-200">Expired</Badge>
                                                )}
                                                {currentStatus === 'cancelled' && (
                                                    <Badge className="bg-rose-50 text-rose-700 border border-rose-200">Cancelled</Badge>
                                                )}
                                            </td>

                                            {/* Action Buttons */}
                                            <td className="py-4 px-6 text-right">
                                                <div className="flex items-center justify-end gap-2">
                                                    {/* Renew Button */}
                                                    <button
                                                        onClick={() => handleRenew(sub.id)}
                                                        title="Renew subscription for 1 month"
                                                        className="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-semibold bg-emerald-50 text-emerald-700 hover:bg-emerald-100 transition-colors border border-emerald-200"
                                                    >
                                                        <RefreshCw className="w-3.5 h-3.5" />
                                                        Renew
                                                    </button>

                                                    {/* Extend Button */}
                                                    <button
                                                        onClick={() => openExtendModal(sub)}
                                                        title="Extend subscription duration"
                                                        className="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-semibold bg-blue-50 text-blue-700 hover:bg-blue-100 transition-colors border border-blue-200"
                                                    >
                                                        <Clock className="w-3.5 h-3.5" />
                                                        Extend
                                                    </button>

                                                    {/* Cancel Button (if active or expired) */}
                                                    {currentStatus !== 'cancelled' && (
                                                        <button
                                                            onClick={() => handleCancel(sub.id)}
                                                            title="Cancel subscription"
                                                            className="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 text-slate-600 hover:bg-rose-50 hover:text-rose-600 transition-colors border border-slate-200"
                                                        >
                                                            <XCircle className="w-3.5 h-3.5" />
                                                            Cancel
                                                        </button>
                                                    )}
                                                </div>
                                            </td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>

            {/* Extend Subscription Modal */}
            <Dialog open={isExtendModalOpen} onClose={() => setIsExtendModalOpen(false)} className="relative z-50">
                <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs" aria-hidden="true" />
                <div className="fixed inset-0 flex items-center justify-center p-4">
                    <Dialog.Panel className="mx-auto max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden">
                        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <Dialog.Title className="text-lg font-bold text-slate-800">
                                Extend Subscription
                            </Dialog.Title>
                            <button onClick={() => setIsExtendModalOpen(false)} className="text-slate-400 hover:text-slate-600">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleExtendSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-xs font-semibold text-slate-500 uppercase tracking-wider mb-1">
                                    Restaurant
                                </label>
                                <div className="text-slate-900 font-bold">
                                    {selectedSubForExtend?.restaurant?.name || 'N/A'}
                                </div>
                                <div className="text-xs text-slate-500">
                                    Current Expiry: {selectedSubForExtend?.ends_at ? new Date(selectedSubForExtend.ends_at).toLocaleDateString() : 'None'}
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">
                                    Extend Duration (Months)
                                </label>
                                <select 
                                    value={extendMonths} 
                                    onChange={(e) => setExtendMonths(e.target.value)}
                                    className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 text-slate-800 font-medium focus:ring-2 focus:ring-blue-500"
                                >
                                    <option value={1}>+1 Month</option>
                                    <option value={3}>+3 Months</option>
                                    <option value={6}>+6 Months</option>
                                    <option value={12}>+1 Year (12 Months)</option>
                                    <option value={24}>+2 Years (24 Months)</option>
                                </select>
                            </div>

                            <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                                <Button type="button" variant="ghost" onClick={() => setIsExtendModalOpen(false)}>
                                    Cancel
                                </Button>
                                <Button type="submit" className="bg-blue-600 hover:bg-blue-700 text-white">
                                    Extend Subscription
                                </Button>
                            </div>
                        </form>
                    </Dialog.Panel>
                </div>
            </Dialog>
        </SuperAdminLayout>
    );
}
