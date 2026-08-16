import React, { useState } from 'react';
import SuperAdminLayout from '../../Layouts/SuperAdminLayout';
import { Card, CardContent, CardHeader, CardTitle } from '../../Components/ui/Card';
import { Button } from '../../Components/ui/Button';
import { Check, Plus, X, Edit, Trash2, ShieldCheck, CheckSquare, Square } from 'lucide-react';
import { useForm, router, usePage } from '@inertiajs/react';
import { Dialog } from '@headlessui/react';

const AVAILABLE_FEATURES = [
    { id: 'pos_billing', label: 'POS Billing & Checkout', description: 'Access to POS terminal and quick order creation' },
    { id: 'tables', label: 'Table Management', description: 'Floor plans, table creation, and live status tracking' },
    { id: 'qr_ordering', label: 'QR Table Digital Self-Ordering', description: 'Table QR code generation & customer mobile self-ordering' },
    { id: 'kitchen', label: 'Kitchen Display System (KDS)', description: 'Real-time kitchen order screen for chefs' },
    { id: 'orders', label: 'Order History & KOT Receipts', description: 'Order history, payment status, and printing' },
    { id: 'menu', label: 'Menu & Category Management', description: 'Manage food items, prices, and categories' },
    { id: 'inventory', label: 'Inventory & Stock Control', description: 'Stock levels, low stock alerts, and restock logs' },
    { id: 'expenses', label: 'Expense Tracking', description: 'Track operating expenses and expense categories' },
    { id: 'reports', label: 'Analytics & Sales Reports', description: 'Sales metrics, revenue trends, and performance reports' },
    { id: 'staff', label: 'Staff Management', description: 'Manage waitstaff, cashiers, and kitchen staff accounts' },
];

export default function Plans({ plans = [] }) {
    const { currencySymbol = '$' } = usePage().props;
    const [isCreateOpen, setIsCreateOpen] = useState(false);
    const [isEditOpen, setIsEditOpen] = useState(false);
    const [selectedPlanForEdit, setSelectedPlanForEdit] = useState(null);

    // Create Form
    const createForm = useForm({
        name: '',
        price: '',
        billing_cycle: 'monthly',
        features: AVAILABLE_FEATURES.map(f => f.id), // Default all checked
        max_users: '',
        max_branches: '',
    });

    // Edit Form
    const editForm = useForm({
        name: '',
        price: '',
        billing_cycle: 'monthly',
        features: [],
        max_users: '',
        max_branches: '',
    });

    // Submit Create Plan
    const submitCreate = (e) => {
        e.preventDefault();
        createForm.post('/admin/plans', {
            onSuccess: () => {
                setIsCreateOpen(false);
                createForm.reset();
            },
        });
    };

    // Open Edit Modal
    const openEditModal = (plan) => {
        setSelectedPlanForEdit(plan);
        const existingFeatures = Array.isArray(plan.features) ? plan.features : [];
        editForm.setData({
            name: plan.name || '',
            price: plan.price || '',
            billing_cycle: plan.billing_cycle || 'monthly',
            features: existingFeatures,
            max_users: plan.max_users || '',
            max_branches: plan.max_branches || '',
        });
        setIsEditOpen(true);
    };

    // Submit Edit Plan
    const submitEdit = (e) => {
        e.preventDefault();
        if (!selectedPlanForEdit) return;

        editForm.put(`/admin/plans/${selectedPlanForEdit.id}`, {
            onSuccess: () => {
                setIsEditOpen(false);
                setSelectedPlanForEdit(null);
            },
        });
    };

    // Delete Plan
    const handleDelete = (plan) => {
        if (confirm(`Are you sure you want to delete the plan "${plan.name}"?`)) {
            router.delete(`/admin/plans/${plan.id}`);
        }
    };

    // Toggle feature in Create form
    const toggleCreateFeature = (featureId) => {
        const current = createForm.data.features;
        if (current.includes(featureId)) {
            createForm.setData('features', current.filter(id => id !== featureId));
        } else {
            createForm.setData('features', [...current, featureId]);
        }
    };

    // Toggle feature in Edit form
    const toggleEditFeature = (featureId) => {
        const current = editForm.data.features;
        if (current.includes(featureId)) {
            editForm.setData('features', current.filter(id => id !== featureId));
        } else {
            editForm.setData('features', [...current, featureId]);
        }
    };

    const setAllCreateFeatures = (selectAll) => {
        createForm.setData('features', selectAll ? AVAILABLE_FEATURES.map(f => f.id) : []);
    };

    const setAllEditFeatures = (selectAll) => {
        editForm.setData('features', selectAll ? AVAILABLE_FEATURES.map(f => f.id) : []);
    };

    return (
        <SuperAdminLayout>
            {/* Header */}
            <div className="mb-8 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900 mb-1">Subscription Plans</h1>
                    <p className="text-slate-500 text-sm">Define pricing tiers and enabled feature modules for SaaS tenants.</p>
                </div>
                <Button 
                    onClick={() => setIsCreateOpen(true)} 
                    className="bg-blue-600 hover:bg-blue-700 text-white shadow-lg shadow-blue-500/20"
                >
                    <Plus className="w-5 h-5 mr-2" />
                    Create New Plan
                </Button>
            </div>

            {/* Plans Grid */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                {plans.length === 0 ? (
                    <div className="col-span-3 text-center py-12 text-slate-500 bg-white rounded-2xl shadow-xs border border-slate-200">
                        No subscription plans available yet. Click "Create New Plan" to set up your first tier!
                    </div>
                ) : plans.map(plan => {
                    const planFeatures = Array.isArray(plan.features) ? plan.features : [];

                    return (
                        <Card key={plan.id} className="relative overflow-hidden border-slate-200 shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow">
                            <div>
                                <CardHeader className="p-6 pb-4 border-b border-slate-100 flex flex-row items-center justify-between">
                                    <div>
                                        <CardTitle className="text-xl font-bold text-slate-900">{plan.name}</CardTitle>
                                        <div className="text-xs text-slate-400 font-medium uppercase mt-0.5">{plan.billing_cycle} billing</div>
                                    </div>
                                    <div className="flex items-center gap-1">
                                        <button
                                            onClick={() => openEditModal(plan)}
                                            title="Edit Plan"
                                            className="p-1.5 rounded-lg text-slate-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"
                                        >
                                            <Edit className="w-4 h-4" />
                                        </button>
                                        <button
                                            onClick={() => handleDelete(plan)}
                                            title="Delete Plan"
                                            className="p-1.5 rounded-lg text-slate-400 hover:text-rose-600 hover:bg-rose-50 transition-colors"
                                        >
                                            <Trash2 className="w-4 h-4" />
                                        </button>
                                    </div>
                                </CardHeader>
                                
                                <CardContent className="p-6">
                                    <div className="mb-6 flex items-baseline">
                                        <span className="text-4xl font-extrabold text-slate-900">{currencySymbol}{plan.price}</span>
                                        <span className="text-slate-500 ml-1 font-medium text-sm">/{plan.billing_cycle === 'monthly' ? 'month' : 'year'}</span>
                                    </div>

                                    <div className="mb-4 text-xs font-semibold text-slate-400 uppercase tracking-wider">
                                        Included Features ({planFeatures.length} Enabled)
                                    </div>

                                    <div className="space-y-2.5">
                                        {AVAILABLE_FEATURES.map(featureObj => {
                                            const isEnabled = planFeatures.includes(featureObj.id) || planFeatures.includes(featureObj.label);

                                            return (
                                                <div key={featureObj.id} className="flex items-center gap-2.5">
                                                    <div className={`w-4 h-4 rounded-full flex items-center justify-center flex-shrink-0 ${
                                                        isEnabled ? 'bg-emerald-100 text-emerald-600' : 'bg-slate-100 text-slate-300'
                                                    }`}>
                                                        {isEnabled ? <Check className="w-3 h-3" /> : <X className="w-3 h-3" />}
                                                    </div>
                                                    <span className={`text-xs font-medium ${isEnabled ? 'text-slate-700' : 'text-slate-400 line-through'}`}>
                                                        {featureObj.label}
                                                    </span>
                                                </div>
                                            );
                                        })}
                                    </div>
                                </CardContent>
                            </div>

                            <div className="p-4 bg-slate-50 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
                                <span>Plan ID: #{plan.id}</span>
                                <Button 
                                    variant="ghost" 
                                    size="sm" 
                                    onClick={() => openEditModal(plan)}
                                    className="text-blue-600 hover:text-blue-700 text-xs font-semibold"
                                >
                                    Edit Features →
                                </Button>
                            </div>
                        </Card>
                    );
                })}
            </div>

            {/* Create Plan Modal */}
            <Dialog open={isCreateOpen} onClose={() => setIsCreateOpen(false)} className="relative z-50">
                <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs" aria-hidden="true" />
                <div className="fixed inset-0 flex items-center justify-center p-4">
                    <Dialog.Panel className="mx-auto max-w-lg w-full bg-white rounded-2xl shadow-xl overflow-hidden max-h-[90vh] flex flex-col">
                        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <Dialog.Title className="text-lg font-bold text-slate-800">Create Subscription Plan</Dialog.Title>
                            <button onClick={() => setIsCreateOpen(false)} className="text-slate-400 hover:text-slate-600">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        
                        <form onSubmit={submitCreate} className="p-6 space-y-4 overflow-y-auto flex-1">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Plan Name</label>
                                <input type="text" value={createForm.data.name} onChange={e => createForm.setData('name', e.target.value)} placeholder="e.g. Pro Business Tier" className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500" required />
                                {createForm.errors.name && <span className="text-red-500 text-xs">{createForm.errors.name}</span>}
                            </div>
                            
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Price ({currencySymbol})</label>
                                    <input type="number" step="0.01" value={createForm.data.price} onChange={e => createForm.setData('price', e.target.value)} placeholder="e.g. 49.00" className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500" required />
                                    {createForm.errors.price && <span className="text-red-500 text-xs">{createForm.errors.price}</span>}
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Billing Cycle</label>
                                    <select value={createForm.data.billing_cycle} onChange={e => createForm.setData('billing_cycle', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500">
                                        <option value="monthly">Monthly</option>
                                        <option value="yearly">Yearly</option>
                                    </select>
                                </div>
                            </div>

                            {/* Features Checkboxes Section */}
                            <div>
                                <div className="flex items-center justify-between mb-2">
                                    <label className="block text-sm font-bold text-slate-800">
                                        Module Features Allowed in this Plan
                                    </label>
                                    <div className="flex items-center gap-2">
                                        <button type="button" onClick={() => setAllCreateFeatures(true)} className="text-xs text-blue-600 hover:underline">Select All</button>
                                        <span className="text-slate-300">|</span>
                                        <button type="button" onClick={() => setAllCreateFeatures(false)} className="text-xs text-slate-500 hover:underline">Deselect All</button>
                                    </div>
                                </div>

                                <div className="space-y-2 border border-slate-200 rounded-xl p-3 bg-slate-50 max-h-56 overflow-y-auto">
                                    {AVAILABLE_FEATURES.map(feat => {
                                        const isChecked = createForm.data.features.includes(feat.id);
                                        return (
                                            <label 
                                                key={feat.id} 
                                                onClick={() => toggleCreateFeature(feat.id)}
                                                className={`flex items-start gap-3 p-2.5 rounded-lg border transition-all cursor-pointer ${
                                                    isChecked 
                                                        ? 'bg-blue-50/80 border-blue-200 text-blue-900' 
                                                        : 'bg-white border-slate-200 text-slate-600 hover:bg-slate-100/50'
                                                }`}
                                            >
                                                <input 
                                                    type="checkbox" 
                                                    checked={isChecked} 
                                                    onChange={() => {}} // Handled by parent label click
                                                    className="mt-0.5 rounded border-slate-300 text-blue-600 focus:ring-blue-500" 
                                                />
                                                <div>
                                                    <div className="text-xs font-bold">{feat.label}</div>
                                                    <div className="text-[11px] text-slate-500">{feat.description}</div>
                                                </div>
                                            </label>
                                        );
                                    })}
                                </div>
                            </div>

                            <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                                <Button type="button" variant="ghost" onClick={() => setIsCreateOpen(false)}>Cancel</Button>
                                <Button type="submit" disabled={createForm.processing} className="bg-blue-600 hover:bg-blue-700 text-white">Create Plan</Button>
                            </div>
                        </form>
                    </Dialog.Panel>
                </div>
            </Dialog>

            {/* Edit Plan Modal */}
            <Dialog open={isEditOpen} onClose={() => setIsEditOpen(false)} className="relative z-50">
                <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs" aria-hidden="true" />
                <div className="fixed inset-0 flex items-center justify-center p-4">
                    <Dialog.Panel className="mx-auto max-w-lg w-full bg-white rounded-2xl shadow-xl overflow-hidden max-h-[90vh] flex flex-col">
                        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <Dialog.Title className="text-lg font-bold text-slate-800">Edit Subscription Plan</Dialog.Title>
                            <button onClick={() => setIsEditOpen(false)} className="text-slate-400 hover:text-slate-600">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        
                        <form onSubmit={submitEdit} className="p-6 space-y-4 overflow-y-auto flex-1">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Plan Name</label>
                                <input type="text" value={editForm.data.name} onChange={e => editForm.setData('name', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500" required />
                                {editForm.errors.name && <span className="text-red-500 text-xs">{editForm.errors.name}</span>}
                            </div>
                            
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Price ({currencySymbol})</label>
                                    <input type="number" step="0.01" value={editForm.data.price} onChange={e => editForm.setData('price', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500" required />
                                    {editForm.errors.price && <span className="text-red-500 text-xs">{editForm.errors.price}</span>}
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Billing Cycle</label>
                                    <select value={editForm.data.billing_cycle} onChange={e => editForm.setData('billing_cycle', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-blue-500">
                                        <option value="monthly">Monthly</option>
                                        <option value="yearly">Yearly</option>
                                    </select>
                                </div>
                            </div>

                            {/* Features Checkboxes Section */}
                            <div>
                                <div className="flex items-center justify-between mb-2">
                                    <label className="block text-sm font-bold text-slate-800">
                                        Module Features Allowed in this Plan
                                    </label>
                                    <div className="flex items-center gap-2">
                                        <button type="button" onClick={() => setAllEditFeatures(true)} className="text-xs text-blue-600 hover:underline">Select All</button>
                                        <span className="text-slate-300">|</span>
                                        <button type="button" onClick={() => setAllEditFeatures(false)} className="text-xs text-slate-500 hover:underline">Deselect All</button>
                                    </div>
                                </div>

                                <div className="space-y-2 border border-slate-200 rounded-xl p-3 bg-slate-50 max-h-56 overflow-y-auto">
                                    {AVAILABLE_FEATURES.map(feat => {
                                        const isChecked = editForm.data.features.includes(feat.id);
                                        return (
                                            <label 
                                                key={feat.id} 
                                                onClick={() => toggleEditFeature(feat.id)}
                                                className={`flex items-start gap-3 p-2.5 rounded-lg border transition-all cursor-pointer ${
                                                    isChecked 
                                                        ? 'bg-blue-50/80 border-blue-200 text-blue-900' 
                                                        : 'bg-white border-slate-200 text-slate-600 hover:bg-slate-100/50'
                                                }`}
                                            >
                                                <input 
                                                    type="checkbox" 
                                                    checked={isChecked} 
                                                    onChange={() => {}} 
                                                    className="mt-0.5 rounded border-slate-300 text-blue-600 focus:ring-blue-500" 
                                                />
                                                <div>
                                                    <div className="text-xs font-bold">{feat.label}</div>
                                                    <div className="text-[11px] text-slate-500">{feat.description}</div>
                                                </div>
                                            </label>
                                        );
                                    })}
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
        </SuperAdminLayout>
    );
}
