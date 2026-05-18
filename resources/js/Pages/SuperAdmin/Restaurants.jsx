import React, { useState } from 'react';
import SuperAdminLayout from '../../Layouts/SuperAdminLayout';
import { Card, CardContent } from '../../Components/ui/Card';
import { Badge } from '../../Components/ui/Badge';
import { Button } from '../../Components/ui/Button';
import { MoreVertical, Plus, X } from 'lucide-react';
import { useForm } from '@inertiajs/react';
import { Dialog } from '@headlessui/react';

export default function Restaurants({ tenants, plans }) {
    const [isOpen, setIsOpen] = useState(false);

    const { data, setData, post, processing, errors, reset } = useForm({
        restaurant_name: '',
        email: '',
        phone: '',
        plan_id: plans.length > 0 ? plans[0].id : '',
        duration_months: 1,
    });

    const submit = (e) => {
        e.preventDefault();
        post('/admin/restaurants', {
            onSuccess: () => {
                setIsOpen(false);
                reset();
            },
        });
    };

    return (
        <SuperAdminLayout>
            <div className="mb-6 flex justify-between items-end">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900 mb-1">Tenants & Restaurants</h1>
                    <p className="text-slate-500">Manage all registered restaurants on the platform.</p>
                </div>
                <Button onClick={() => setIsOpen(true)} className="bg-blue-600 hover:bg-blue-700 text-white shadow-lg shadow-blue-500/20">
                    <Plus className="w-5 h-5 mr-2" />
                    Add Restaurant
                </Button>
            </div>

            <Card>
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-slate-50 border-b border-slate-200">
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-sm uppercase tracking-wider">Restaurant Name</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-sm uppercase tracking-wider">Plan</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-sm uppercase tracking-wider">MRR</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-sm uppercase tracking-wider">Joined Date</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-sm uppercase tracking-wider">Status</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-sm uppercase tracking-wider text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {tenants.length === 0 ? (
                                    <tr>
                                        <td colSpan="6" className="py-8 text-center text-slate-500">No restaurants registered yet.</td>
                                    </tr>
                                ) : tenants.map(tenant => (
                                    <tr key={tenant.id} className="hover:bg-slate-50/50 transition-colors">
                                        <td className="py-4 px-6 font-medium text-slate-900">{tenant.name}</td>
                                        <td className="py-4 px-6 text-slate-600">{tenant.subscription?.plan?.name || 'None'}</td>
                                        <td className="py-4 px-6 font-bold text-slate-700">${tenant.subscription?.plan?.price || '0.00'}</td>
                                        <td className="py-4 px-6 text-slate-500">{new Date(tenant.created_at).toLocaleDateString()}</td>
                                        <td className="py-4 px-6">
                                            <Badge variant={tenant.subscription?.status === 'active' ? 'success' : 'warning'}>
                                                {tenant.subscription?.status || 'No Sub'}
                                            </Badge>
                                        </td>
                                        <td className="py-4 px-6 text-right">
                                            <Button variant="ghost" size="icon" className="text-slate-500 hover:bg-slate-100">
                                                <MoreVertical className="w-4 h-4" />
                                            </Button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>

            {/* Create Restaurant Modal */}
            <Dialog open={isOpen} onClose={() => setIsOpen(false)} className="relative z-50">
                <div className="fixed inset-0 bg-black/30" aria-hidden="true" />
                <div className="fixed inset-0 flex items-center justify-center p-4">
                    <Dialog.Panel className="mx-auto max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden">
                        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <Dialog.Title className="text-lg font-bold text-slate-800">Register New Restaurant</Dialog.Title>
                            <button onClick={() => setIsOpen(false)} className="text-slate-400 hover:text-slate-600">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={submit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Restaurant Name</label>
                                <input type="text" value={data.restaurant_name} onChange={e => setData('restaurant_name', e.target.value)} className="w-full border-slate-200 rounded-lg shadow-sm" required />
                                {errors.restaurant_name && <span className="text-red-500 text-xs">{errors.restaurant_name}</span>}
                            </div>
                            
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Owner Email (Login ID)</label>
                                <input type="email" value={data.email} onChange={e => setData('email', e.target.value)} className="w-full border-slate-200 rounded-lg shadow-sm" required />
                                {errors.email && <span className="text-red-500 text-xs">{errors.email}</span>}
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Phone Number</label>
                                <input type="text" value={data.phone} onChange={e => setData('phone', e.target.value)} className="w-full border-slate-200 rounded-lg shadow-sm" />
                                {errors.phone && <span className="text-red-500 text-xs">{errors.phone}</span>}
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Subscription Plan</label>
                                    <select value={data.plan_id} onChange={e => setData('plan_id', e.target.value)} className="w-full border-slate-200 rounded-lg shadow-sm" required>
                                        <option value="" disabled>Select Plan</option>
                                        {plans.map(p => <option key={p.id} value={p.id}>{p.name} (${p.price})</option>)}
                                    </select>
                                    {errors.plan_id && <span className="text-red-500 text-xs">{errors.plan_id}</span>}
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Duration (Months)</label>
                                    <input type="number" min="1" value={data.duration_months} onChange={e => setData('duration_months', e.target.value)} className="w-full border-slate-200 rounded-lg shadow-sm" required />
                                    {errors.duration_months && <span className="text-red-500 text-xs">{errors.duration_months}</span>}
                                </div>
                            </div>

                            <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                                <Button type="button" variant="ghost" onClick={() => setIsOpen(false)}>Cancel</Button>
                                <Button type="submit" disabled={processing} className="bg-blue-600 hover:bg-blue-700 text-white">Register Tenant</Button>
                            </div>
                        </form>
                    </Dialog.Panel>
                </div>
            </Dialog>
        </SuperAdminLayout>
    );
}
