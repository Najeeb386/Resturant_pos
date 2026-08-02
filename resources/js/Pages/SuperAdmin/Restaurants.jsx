import React, { useState, useMemo } from 'react';
import SuperAdminLayout from '../../Layouts/SuperAdminLayout';
import { Card, CardContent } from '../../Components/ui/Card';
import { Badge } from '../../Components/ui/Badge';
import { Button } from '../../Components/ui/Button';
import { 
    Plus, 
    X, 
    Search, 
    Filter, 
    Eye, 
    Edit, 
    Trash2, 
    Store, 
    AlertTriangle,
    CheckCircle2,
    Calendar,
    Phone,
    Mail
} from 'lucide-react';
import { useForm, router } from '@inertiajs/react';
import { Dialog } from '@headlessui/react';

export default function Restaurants({ tenants = [], plans = [] }) {
    const [isCreateOpen, setIsCreateOpen] = useState(false);
    const [isViewOpen, setIsViewOpen] = useState(false);
    const [selectedTenantForView, setSelectedTenantForView] = useState(null);

    const [isEditOpen, setIsEditOpen] = useState(false);
    const [selectedTenantForEdit, setSelectedTenantForEdit] = useState(null);

    // Filters & Search
    const [searchTerm, setSearchTerm] = useState('');
    const [statusFilter, setStatusFilter] = useState('all');
    const [planFilter, setPlanFilter] = useState('all');

    // Create Form
    const createForm = useForm({
        restaurant_name: '',
        email: '',
        phone: '',
        plan_id: plans.length > 0 ? plans[0].id : '',
        duration_months: 1,
    });

    // Edit Form
    const editForm = useForm({
        name: '',
        email: '',
        phone: '',
        plan_id: '',
        status: 'active',
    });

    const submitCreate = (e) => {
        e.preventDefault();
        createForm.post('/admin/restaurants', {
            onSuccess: () => {
                setIsCreateOpen(false);
                createForm.reset();
            },
        });
    };

    const openEditModal = (tenant) => {
        setSelectedTenantForEdit(tenant);
        editForm.setData({
            name: tenant.name || '',
            email: tenant.email || '',
            phone: tenant.phone || '',
            plan_id: tenant.subscription?.plan?.id || (plans.length > 0 ? plans[0].id : ''),
            status: tenant.subscription?.status || 'active',
        });
        setIsEditOpen(true);
    };

    const submitEdit = (e) => {
        e.preventDefault();
        if (!selectedTenantForEdit) return;

        editForm.put(`/admin/restaurants/${selectedTenantForEdit.id}`, {
            onSuccess: () => {
                setIsEditOpen(false);
                setSelectedTenantForEdit(null);
            },
        });
    };

    const handleDelete = (tenant) => {
        if (confirm(`Are you sure you want to delete "${tenant.name}"? This action will permanently remove all associated users and data.`)) {
            router.delete(`/admin/restaurants/${tenant.id}`);
        }
    };

    const openViewModal = (tenant) => {
        setSelectedTenantForView(tenant);
        setIsViewOpen(true);
    };

    // Filter & Search Logic
    const filteredTenants = useMemo(() => {
        return tenants.filter(t => {
            const subStatus = t.subscription?.status || 'no_sub';
            const isExpired = t.subscription?.ends_at && new Date(t.subscription.ends_at) < new Date();
            const currentStatus = subStatus === 'active' && isExpired ? 'expired' : subStatus;

            // Search query match
            const searchLower = searchTerm.toLowerCase();
            const nameMatch = t.name?.toLowerCase().includes(searchLower);
            const emailMatch = t.email?.toLowerCase().includes(searchLower);
            const phoneMatch = t.phone?.toLowerCase().includes(searchLower);
            const matchesSearch = !searchTerm || nameMatch || emailMatch || phoneMatch;

            // Status filter match
            const matchesStatus = statusFilter === 'all' || currentStatus === statusFilter;

            // Plan filter match
            const matchesPlan = planFilter === 'all' || (t.subscription?.plan?.id?.toString() === planFilter.toString());

            return matchesSearch && matchesStatus && matchesPlan;
        });
    }, [tenants, searchTerm, statusFilter, planFilter]);

    const clearFilters = () => {
        setSearchTerm('');
        setStatusFilter('all');
        setPlanFilter('all');
    };

    return (
        <SuperAdminLayout>
            {/* Header */}
            <div className="mb-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900 mb-1">Tenants & Restaurants</h1>
                    <p className="text-slate-500 text-sm">Manage all registered restaurant tenants on your platform.</p>
                </div>
                <Button 
                    onClick={() => setIsCreateOpen(true)} 
                    className="bg-blue-600 hover:bg-blue-700 text-white shadow-lg shadow-blue-500/20"
                >
                    <Plus className="w-5 h-5 mr-2" />
                    Register New Tenant
                </Button>
            </div>

            {/* Filter & Search Bar */}
            <Card className="mb-6 border-slate-200 shadow-xs">
                <CardContent className="p-4">
                    <div className="flex flex-col lg:flex-row gap-4 items-center justify-between">
                        {/* Realtime Search Input */}
                        <div className="relative w-full lg:w-96">
                            <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
                            <input
                                type="text"
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                                placeholder="Search by restaurant name, email, phone..."
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
                                <option value="no_sub">No Subscription</option>
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

            {/* Restaurants Table */}
            <Card className="border-slate-200 shadow-sm overflow-hidden">
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-slate-50/80 border-b border-slate-200">
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Restaurant Name</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Owner Contact</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Plan</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">MRR</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Joined Date</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Status</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {filteredTenants.length === 0 ? (
                                    <tr>
                                        <td colSpan="7" className="py-12 text-center text-slate-500">
                                            <div className="flex flex-col items-center justify-center">
                                                <Store className="w-8 h-8 text-slate-300 mb-2" />
                                                <p className="font-medium text-slate-600">No restaurants found matching your criteria.</p>
                                            </div>
                                        </td>
                                    </tr>
                                ) : filteredTenants.map(tenant => {
                                    const subStatus = tenant.subscription?.status || 'no_sub';
                                    const isExpired = tenant.subscription?.ends_at && new Date(tenant.subscription.ends_at) < new Date();
                                    const currentStatus = subStatus === 'active' && isExpired ? 'expired' : subStatus;

                                    return (
                                        <tr key={tenant.id} className="hover:bg-slate-50/50 transition-colors">
                                            <td className="py-4 px-6 font-bold text-slate-900">{tenant.name}</td>
                                            <td className="py-4 px-6">
                                                <div className="text-sm font-medium text-slate-700">{tenant.email || 'N/A'}</div>
                                                <div className="text-xs text-slate-400">{tenant.phone || ''}</div>
                                            </td>
                                            <td className="py-4 px-6 text-slate-700 font-medium">{tenant.subscription?.plan?.name || 'None'}</td>
                                            <td className="py-4 px-6 font-bold text-slate-800">${tenant.subscription?.plan?.price || '0.00'}</td>
                                            <td className="py-4 px-6 text-sm text-slate-500">{new Date(tenant.created_at).toLocaleDateString()}</td>
                                            <td className="py-4 px-6">
                                                {currentStatus === 'active' && <Badge className="bg-emerald-50 text-emerald-700 border border-emerald-200">Active</Badge>}
                                                {currentStatus === 'expired' && <Badge className="bg-amber-50 text-amber-700 border border-amber-200">Expired</Badge>}
                                                {currentStatus === 'cancelled' && <Badge className="bg-rose-50 text-rose-700 border border-rose-200">Cancelled</Badge>}
                                                {currentStatus === 'no_sub' && <Badge className="bg-slate-100 text-slate-600 border border-slate-200">No Sub</Badge>}
                                            </td>
                                            <td className="py-4 px-6 text-right">
                                                <div className="flex items-center justify-end gap-1.5">
                                                    {/* View Details */}
                                                    <button
                                                        onClick={() => openViewModal(tenant)}
                                                        title="View Details"
                                                        className="p-1.5 rounded-lg text-slate-500 hover:text-blue-600 hover:bg-blue-50 transition-colors"
                                                    >
                                                        <Eye className="w-4 h-4" />
                                                    </button>

                                                    {/* Edit Tenant */}
                                                    <button
                                                        onClick={() => openEditModal(tenant)}
                                                        title="Edit Tenant"
                                                        className="p-1.5 rounded-lg text-slate-500 hover:text-amber-600 hover:bg-amber-50 transition-colors"
                                                    >
                                                        <Edit className="w-4 h-4" />
                                                    </button>

                                                    {/* Delete Tenant */}
                                                    <button
                                                        onClick={() => handleDelete(tenant)}
                                                        title="Delete Tenant"
                                                        className="p-1.5 rounded-lg text-slate-500 hover:text-rose-600 hover:bg-rose-50 transition-colors"
                                                    >
                                                        <Trash2 className="w-4 h-4" />
                                                    </button>
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

            {/* Create Restaurant Modal */}
            <Dialog open={isCreateOpen} onClose={() => setIsCreateOpen(false)} className="relative z-50">
                <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs" aria-hidden="true" />
                <div className="fixed inset-0 flex items-center justify-center p-4">
                    <Dialog.Panel className="mx-auto max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden">
                        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <Dialog.Title className="text-lg font-bold text-slate-800">Register New Restaurant Tenant</Dialog.Title>
                            <button onClick={() => setIsCreateOpen(false)} className="text-slate-400 hover:text-slate-600">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={submitCreate} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Restaurant Name</label>
                                <input type="text" value={createForm.data.restaurant_name} onChange={e => createForm.setData('restaurant_name', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500" required />
                                {createForm.errors.restaurant_name && <span className="text-red-500 text-xs">{createForm.errors.restaurant_name}</span>}
                            </div>
                            
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Owner Email (Login ID)</label>
                                <input type="email" value={createForm.data.email} onChange={e => createForm.setData('email', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500" required />
                                {createForm.errors.email && <span className="text-red-500 text-xs">{createForm.errors.email}</span>}
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Phone Number</label>
                                <input type="text" value={createForm.data.phone} onChange={e => createForm.setData('phone', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500" />
                                {createForm.errors.phone && <span className="text-red-500 text-xs">{createForm.errors.phone}</span>}
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Subscription Plan</label>
                                    <select value={createForm.data.plan_id} onChange={e => createForm.setData('plan_id', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500" required>
                                        <option value="" disabled>Select Plan</option>
                                        {plans.map(p => <option key={p.id} value={p.id}>{p.name} (${p.price})</option>)}
                                    </select>
                                    {createForm.errors.plan_id && <span className="text-red-500 text-xs">{createForm.errors.plan_id}</span>}
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Duration (Months)</label>
                                    <input type="number" min="1" value={createForm.data.duration_months} onChange={e => createForm.setData('duration_months', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500" required />
                                    {createForm.errors.duration_months && <span className="text-red-500 text-xs">{createForm.errors.duration_months}</span>}
                                </div>
                            </div>

                            <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                                <Button type="button" variant="ghost" onClick={() => setIsCreateOpen(false)}>Cancel</Button>
                                <Button type="submit" disabled={createForm.processing} className="bg-blue-600 hover:bg-blue-700 text-white">Register Tenant</Button>
                            </div>
                        </form>
                    </Dialog.Panel>
                </div>
            </Dialog>

            {/* Edit Restaurant Modal */}
            <Dialog open={isEditOpen} onClose={() => setIsEditOpen(false)} className="relative z-50">
                <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs" aria-hidden="true" />
                <div className="fixed inset-0 flex items-center justify-center p-4">
                    <Dialog.Panel className="mx-auto max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden">
                        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <Dialog.Title className="text-lg font-bold text-slate-800">Edit Restaurant Tenant</Dialog.Title>
                            <button onClick={() => setIsEditOpen(false)} className="text-slate-400 hover:text-slate-600">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={submitEdit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Restaurant Name</label>
                                <input type="text" value={editForm.data.name} onChange={e => editForm.setData('name', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500" required />
                            </div>
                            
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Email Address</label>
                                <input type="email" value={editForm.data.email} onChange={e => editForm.setData('email', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500" required />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Phone Number</label>
                                <input type="text" value={editForm.data.phone} onChange={e => editForm.setData('phone', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500" />
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Plan</label>
                                    <select value={editForm.data.plan_id} onChange={e => editForm.setData('plan_id', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500">
                                        {plans.map(p => <option key={p.id} value={p.id}>{p.name} (${p.price})</option>)}
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Sub Status</label>
                                    <select value={editForm.data.status} onChange={e => editForm.setData('status', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500">
                                        <option value="active">Active</option>
                                        <option value="expired">Expired</option>
                                        <option value="cancelled">Cancelled</option>
                                    </select>
                                </div>
                            </div>

                            <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                                <Button type="button" variant="ghost" onClick={() => setIsEditOpen(false)}>Cancel</Button>
                                <Button type="submit" disabled={editForm.processing} className="bg-blue-600 hover:bg-blue-700 text-white">Save Changes</Button>
                            </div>
                        </form>
                    </Dialog.Panel>
                </div>
            </Dialog>

            {/* View Details Modal */}
            <Dialog open={isViewOpen} onClose={() => setIsViewOpen(false)} className="relative z-50">
                <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs" aria-hidden="true" />
                <div className="fixed inset-0 flex items-center justify-center p-4">
                    <Dialog.Panel className="mx-auto max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden">
                        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <Dialog.Title className="text-lg font-bold text-slate-800">Tenant Details</Dialog.Title>
                            <button onClick={() => setIsViewOpen(false)} className="text-slate-400 hover:text-slate-600">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        {selectedTenantForView && (
                            <div className="p-6 space-y-4">
                                <div>
                                    <h3 className="text-xl font-bold text-slate-900">{selectedTenantForView.name}</h3>
                                    <p className="text-xs text-slate-400">Registered ID: #{selectedTenantForView.id}</p>
                                </div>

                                <div className="space-y-2 bg-slate-50 p-4 rounded-xl border border-slate-100">
                                    <div className="flex items-center gap-2 text-sm text-slate-700">
                                        <Mail className="w-4 h-4 text-slate-400" />
                                        <span>{selectedTenantForView.email || 'No email provided'}</span>
                                    </div>
                                    <div className="flex items-center gap-2 text-sm text-slate-700">
                                        <Phone className="w-4 h-4 text-slate-400" />
                                        <span>{selectedTenantForView.phone || 'No phone provided'}</span>
                                    </div>
                                    <div className="flex items-center gap-2 text-sm text-slate-700">
                                        <Calendar className="w-4 h-4 text-slate-400" />
                                        <span>Joined: {new Date(selectedTenantForView.created_at).toLocaleDateString()}</span>
                                    </div>
                                </div>

                                <div>
                                    <h4 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Subscription Info</h4>
                                    <div className="bg-blue-50/50 p-4 rounded-xl border border-blue-100 space-y-1">
                                        <div className="flex justify-between text-sm">
                                            <span className="text-slate-500">Plan:</span>
                                            <span className="font-bold text-slate-800">{selectedTenantForView.subscription?.plan?.name || 'None'}</span>
                                        </div>
                                        <div className="flex justify-between text-sm">
                                            <span className="text-slate-500">Price:</span>
                                            <span className="font-bold text-slate-800">${selectedTenantForView.subscription?.plan?.price || '0.00'}</span>
                                        </div>
                                        <div className="flex justify-between text-sm">
                                            <span className="text-slate-500">Starts:</span>
                                            <span className="text-slate-700">{selectedTenantForView.subscription?.starts_at ? new Date(selectedTenantForView.subscription.starts_at).toLocaleDateString() : 'N/A'}</span>
                                        </div>
                                        <div className="flex justify-between text-sm">
                                            <span className="text-slate-500">Expires:</span>
                                            <span className="text-slate-700">{selectedTenantForView.subscription?.ends_at ? new Date(selectedTenantForView.subscription.ends_at).toLocaleDateString() : 'N/A'}</span>
                                        </div>
                                    </div>
                                </div>

                                <div className="pt-2 flex justify-end">
                                    <Button variant="ghost" onClick={() => setIsViewOpen(false)}>Close</Button>
                                </div>
                            </div>
                        )}
                    </Dialog.Panel>
                </div>
            </Dialog>
        </SuperAdminLayout>
    );
}
