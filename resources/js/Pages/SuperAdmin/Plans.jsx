import React, { useState } from 'react';
import SuperAdminLayout from '../../Layouts/SuperAdminLayout';
import { Card, CardContent, CardHeader, CardTitle } from '../../Components/ui/Card';
import { Button } from '../../Components/ui/Button';
import { Check, Plus, X } from 'lucide-react';
import { useForm } from '@inertiajs/react';
import { Dialog } from '@headlessui/react';

export default function Plans({ plans }) {
    const [isOpen, setIsOpen] = useState(false);
    
    const { data, setData, post, processing, errors, reset, transform } = useForm({
        name: '',
        price: '',
        billing_cycle: 'monthly',
        features: '',
    });

    const submit = (e) => {
        e.preventDefault();
        
        transform((data) => ({
            ...data,
            features: typeof data.features === 'string' 
                ? data.features.split(',').map(f => f.trim()).filter(Boolean) 
                : data.features,
        }));
        
        post('/admin/plans', {
            onSuccess: () => {
                setIsOpen(false);
                reset();
            },
        });
    };

    return (
        <SuperAdminLayout>
            <div className="mb-8 flex justify-between items-end">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900 mb-1">Subscription Plans</h1>
                    <p className="text-slate-500">Manage pricing plans for your SaaS tenants.</p>
                </div>
                <Button onClick={() => setIsOpen(true)} className="bg-blue-600 hover:bg-blue-700 text-white shadow-lg shadow-blue-500/20">
                    <Plus className="w-5 h-5 mr-2" />
                    Create New Plan
                </Button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                {plans.length === 0 ? (
                    <div className="col-span-3 text-center py-12 text-slate-500 bg-white rounded-xl shadow-sm border border-slate-100">
                        No plans available yet. Create one to get started!
                    </div>
                ) : plans.map(plan => (
                    <Card key={plan.id} className="relative overflow-hidden border-slate-200">
                        <CardHeader className="p-6 pb-0 border-0">
                            <CardTitle className="text-xl text-slate-800">{plan.name}</CardTitle>
                        </CardHeader>
                        <CardContent className="p-6">
                            <div className="mb-6 flex items-baseline">
                                <span className="text-4xl font-extrabold text-slate-900">${plan.price}</span>
                                <span className="text-slate-500 ml-1 font-medium">/{plan.billing_cycle === 'monthly' ? 'mo' : 'yr'}</span>
                            </div>
                            <div className="space-y-3">
                                {plan.features && plan.features.map((feature, idx) => (
                                    <div key={idx} className="flex items-center gap-3">
                                        <div className="w-5 h-5 rounded-full bg-emerald-100 flex items-center justify-center flex-shrink-0">
                                            <Check className="w-3 h-3 text-emerald-600" />
                                        </div>
                                        <span className="text-sm text-slate-700 font-medium">{feature}</span>
                                    </div>
                                ))}
                            </div>
                        </CardContent>
                    </Card>
                ))}
            </div>

            {/* Create Plan Modal */}
            <Dialog open={isOpen} onClose={() => setIsOpen(false)} className="relative z-50">
                <div className="fixed inset-0 bg-black/30" aria-hidden="true" />
                <div className="fixed inset-0 flex items-center justify-center p-4">
                    <Dialog.Panel className="mx-auto max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden">
                        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <Dialog.Title className="text-lg font-bold text-slate-800">Create Subscription Plan</Dialog.Title>
                            <button onClick={() => setIsOpen(false)} className="text-slate-400 hover:text-slate-600">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={submit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Plan Name</label>
                                <input type="text" value={data.name} onChange={e => setData('name', e.target.value)} className="w-full border-slate-200 rounded-lg shadow-sm" required />
                                {errors.name && <span className="text-red-500 text-xs">{errors.name}</span>}
                            </div>
                            
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Price</label>
                                    <input type="number" step="0.01" value={data.price} onChange={e => setData('price', e.target.value)} className="w-full border-slate-200 rounded-lg shadow-sm" required />
                                    {errors.price && <span className="text-red-500 text-xs">{errors.price}</span>}
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Billing Cycle</label>
                                    <select value={data.billing_cycle} onChange={e => setData('billing_cycle', e.target.value)} className="w-full border-slate-200 rounded-lg shadow-sm">
                                        <option value="monthly">Monthly</option>
                                        <option value="yearly">Yearly</option>
                                    </select>
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Features (comma separated)</label>
                                <textarea value={data.features} onChange={e => setData('features', e.target.value)} className="w-full border-slate-200 rounded-lg shadow-sm" rows="3" placeholder="e.g. 5 Users, Standard Support, Analytics"></textarea>
                                {errors.features && <span className="text-red-500 text-xs">{errors.features}</span>}
                            </div>

                            <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                                <Button type="button" variant="ghost" onClick={() => setIsOpen(false)}>Cancel</Button>
                                <Button type="submit" disabled={processing} className="bg-blue-600 hover:bg-blue-700 text-white">Save Plan</Button>
                            </div>
                        </form>
                    </Dialog.Panel>
                </div>
            </Dialog>
        </SuperAdminLayout>
    );
}
