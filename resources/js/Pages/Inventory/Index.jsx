import React, { useState } from 'react';
import AdminLayout from '../../Layouts/AdminLayout';
import { Card, CardContent, CardHeader, CardTitle } from '../../Components/ui/Card';
import { useForm } from '@inertiajs/react';
import { Plus, Edit2, Trash2, Package, AlertTriangle, ArrowDownToLine } from 'lucide-react';

export default function InventoryIndex({ inventory, currencySymbol }) {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isRestockModalOpen, setIsRestockModalOpen] = useState(false);
    const [editingId, setEditingId] = useState(null);
    const [restockingItem, setRestockingItem] = useState(null);

    const form = useForm({
        name: '',
        unit: 'kg',
        quantity: '',
        min_quantity: '',
        expiry_date: ''
    });

    const restockForm = useForm({
        added_quantity: '',
        total_cost: ''
    });

    const openModal = (item = null) => {
        form.clearErrors();
        if (item) {
            setEditingId(item.id);
            form.setData({
                name: item.name,
                unit: item.unit,
                quantity: item.quantity,
                min_quantity: item.min_quantity,
                expiry_date: item.expiry_date || ''
            });
        } else {
            setEditingId(null);
            form.reset();
        }
        setIsModalOpen(true);
    };

    const closeModal = () => {
        setIsModalOpen(false);
        form.reset();
        setEditingId(null);
        form.clearErrors();
    };

    const openRestockModal = (item) => {
        restockForm.clearErrors();
        setRestockingItem(item);
        restockForm.setData({
            added_quantity: '',
            total_cost: ''
        });
        setIsRestockModalOpen(true);
    };

    const closeRestockModal = () => {
        setIsRestockModalOpen(false);
        restockForm.reset();
        setRestockingItem(null);
        restockForm.clearErrors();
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        if (editingId) {
            form.put(`/inventory/${editingId}`, {
                onSuccess: () => closeModal()
            });
        } else {
            form.post('/inventory', {
                onSuccess: () => closeModal()
            });
        }
    };

    const handleRestockSubmit = (e) => {
        e.preventDefault();
        restockForm.post(`/inventory/${restockingItem.id}/restock`, {
            onSuccess: () => closeRestockModal()
        });
    };

    const handleDelete = (id) => {
        if (confirm('Are you sure you want to delete this ingredient?')) {
            form.delete(`/inventory/${id}`);
        }
    };

    const units = ['kg', 'grams', 'ltr', 'ml', 'pcs', 'dozen', 'box'];

    return (
        <AdminLayout>
            <div className="flex justify-between items-center mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Inventory & Raw Materials</h1>
                    <p className="text-sm text-gray-500">Track stock levels and purchase new ingredients.</p>
                </div>
                <button 
                    onClick={() => openModal()}
                    className="bg-primary text-white px-4 py-2 rounded-xl flex items-center gap-2 hover:bg-orange-600 transition-colors shadow-sm"
                >
                    <Plus className="w-5 h-5" />
                    Add Ingredient
                </button>
            </div>

            <Card>
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead className="bg-gray-50">
                                <tr>
                                    <th className="py-4 px-6 text-left font-semibold text-gray-600 text-sm">Ingredient Name</th>
                                    <th className="py-4 px-6 text-left font-semibold text-gray-600 text-sm">Current Stock</th>
                                    <th className="py-4 px-6 text-left font-semibold text-gray-600 text-sm">Status</th>
                                    <th className="py-4 px-6 text-left font-semibold text-gray-600 text-sm">Expiry Date</th>
                                    <th className="py-4 px-6 text-right font-semibold text-gray-600 text-sm">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-100">
                                {inventory.map((item) => {
                                    const isLowStock = Number(item.quantity) <= Number(item.min_quantity);
                                    
                                    return (
                                        <tr key={item.id} className="hover:bg-gray-50 transition-colors">
                                            <td className="py-4 px-6 font-medium text-gray-900">
                                                {item.name}
                                            </td>
                                            <td className="py-4 px-6">
                                                <span className="font-bold text-lg">{Number(item.quantity)}</span>
                                                <span className="text-gray-500 text-sm ml-1">{item.unit}</span>
                                            </td>
                                            <td className="py-4 px-6">
                                                {isLowStock ? (
                                                    <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-md text-xs font-bold bg-red-100 text-red-800">
                                                        <AlertTriangle className="w-3 h-3" />
                                                        Low Stock
                                                    </span>
                                                ) : (
                                                    <span className="inline-flex items-center px-2.5 py-1 rounded-md text-xs font-bold bg-green-100 text-green-800">
                                                        In Stock
                                                    </span>
                                                )}
                                            </td>
                                            <td className="py-4 px-6 text-gray-500 text-sm">
                                                {item.expiry_date || 'No Expiry'}
                                            </td>
                                            <td className="py-4 px-6 text-right">
                                                <div className="flex justify-end gap-2">
                                                    <button 
                                                        onClick={() => openRestockModal(item)} 
                                                        className="px-3 py-1.5 text-xs font-medium text-blue-700 bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors flex items-center gap-1"
                                                    >
                                                        <ArrowDownToLine className="w-3.5 h-3.5" /> Restock
                                                    </button>
                                                    <button onClick={() => openModal(item)} className="p-1.5 text-gray-400 hover:text-blue-600 bg-white rounded-lg border border-gray-100 shadow-sm transition-colors">
                                                        <Edit2 className="w-4 h-4" />
                                                    </button>
                                                    <button onClick={() => handleDelete(item.id)} className="p-1.5 text-gray-400 hover:text-red-600 bg-white rounded-lg border border-gray-100 shadow-sm transition-colors">
                                                        <Trash2 className="w-4 h-4" />
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    );
                                })}
                                {inventory.length === 0 && (
                                    <tr>
                                        <td colSpan="5" className="py-12 text-center text-gray-500">
                                            <Package className="w-12 h-12 mx-auto mb-3 text-gray-300" />
                                            No ingredients found. Add raw materials to start tracking inventory!
                                        </td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>

            {/* Create/Edit Modal */}
            {isModalOpen && (
                <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl w-full max-w-md shadow-2xl overflow-hidden">
                        <div className="p-6 border-b border-gray-100 flex justify-between items-center">
                            <h2 className="text-xl font-bold text-gray-800">
                                {editingId ? 'Edit Ingredient' : 'Add New Ingredient'}
                            </h2>
                            <button onClick={closeModal} className="text-gray-400 hover:text-gray-600">
                                <span className="text-2xl leading-none">&times;</span>
                            </button>
                        </div>
                        <div className="p-6">
                            <form onSubmit={handleSubmit} className="space-y-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Ingredient Name</label>
                                    <input
                                        type="text"
                                        value={form.data.name}
                                        onChange={e => form.setData('name', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        required
                                        placeholder="e.g., Chicken Breast"
                                    />
                                    {form.errors.name && <p className="text-red-500 text-xs mt-1">{form.errors.name}</p>}
                                </div>
                                
                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-1">Unit of Measure</label>
                                        <select
                                            value={form.data.unit}
                                            onChange={e => form.setData('unit', e.target.value)}
                                            className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all bg-white"
                                            required
                                        >
                                            {units.map(u => (
                                                <option key={u} value={u}>{u}</option>
                                            ))}
                                        </select>
                                        {form.errors.unit && <p className="text-red-500 text-xs mt-1">{form.errors.unit}</p>}
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-1">Current Stock</label>
                                        <input
                                            type="number"
                                            step="0.01"
                                            min="0"
                                            value={form.data.quantity}
                                            onChange={e => form.setData('quantity', e.target.value)}
                                            className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                            required
                                        />
                                        {form.errors.quantity && <p className="text-red-500 text-xs mt-1">{form.errors.quantity}</p>}
                                    </div>
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Low Stock Alert Quantity</label>
                                    <input
                                        type="number"
                                        step="0.01"
                                        min="0"
                                        value={form.data.min_quantity}
                                        onChange={e => form.setData('min_quantity', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-red-500/20 focus:border-red-500 outline-none transition-all"
                                        required
                                        placeholder="Alert me when stock falls below..."
                                    />
                                    {form.errors.min_quantity && <p className="text-red-500 text-xs mt-1">{form.errors.min_quantity}</p>}
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Expiry Date (Optional)</label>
                                    <input
                                        type="date"
                                        value={form.data.expiry_date}
                                        onChange={e => form.setData('expiry_date', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    />
                                    {form.errors.expiry_date && <p className="text-red-500 text-xs mt-1">{form.errors.expiry_date}</p>}
                                </div>

                                <div className="pt-4 flex justify-end gap-3">
                                    <button type="button" onClick={closeModal} className="px-5 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-xl font-medium transition-colors">Cancel</button>
                                    <button type="submit" disabled={form.processing} className="px-5 py-2 bg-primary text-white rounded-xl font-medium hover:bg-orange-600 transition-colors shadow-sm disabled:opacity-50">
                                        {editingId ? 'Save Changes' : 'Add Ingredient'}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            )}

            {/* Restock/Procurement Modal */}
            {isRestockModalOpen && restockingItem && (
                <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl w-full max-w-md shadow-2xl overflow-hidden border-t-4 border-blue-500">
                        <div className="p-6 border-b border-gray-100 flex justify-between items-center bg-blue-50/30">
                            <div>
                                <h2 className="text-xl font-bold text-blue-900">Purchase / Restock</h2>
                                <p className="text-sm text-blue-700">Add to stock & auto-log expense</p>
                            </div>
                            <button onClick={closeRestockModal} className="text-gray-400 hover:text-gray-600">
                                <span className="text-2xl leading-none">&times;</span>
                            </button>
                        </div>
                        <div className="p-6">
                            <form onSubmit={handleRestockSubmit} className="space-y-4">
                                <div className="bg-gray-50 p-3 rounded-lg border border-gray-100 mb-4 flex justify-between items-center">
                                    <span className="font-medium text-gray-700">{restockingItem.name}</span>
                                    <span className="text-sm text-gray-500">Current: <b>{Number(restockingItem.quantity)} {restockingItem.unit}</b></span>
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Quantity Purchased ({restockingItem.unit})</label>
                                    <input
                                        type="number"
                                        step="0.01"
                                        min="0.01"
                                        value={restockForm.data.added_quantity}
                                        onChange={e => restockForm.setData('added_quantity', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none transition-all"
                                        required
                                        placeholder={`e.g., 5`}
                                    />
                                    {restockForm.errors.added_quantity && <p className="text-red-500 text-xs mt-1">{restockForm.errors.added_quantity}</p>}
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Total Cost Paid ({currencySymbol})</label>
                                    <input
                                        type="number"
                                        step="0.01"
                                        min="0"
                                        value={restockForm.data.total_cost}
                                        onChange={e => restockForm.setData('total_cost', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none transition-all"
                                        required
                                        placeholder={`e.g., 25.50`}
                                    />
                                    <p className="text-xs text-gray-500 mt-1">This amount will be automatically logged in Expenses.</p>
                                    {restockForm.errors.total_cost && <p className="text-red-500 text-xs mt-1">{restockForm.errors.total_cost}</p>}
                                </div>

                                <div className="pt-4 flex justify-end gap-3">
                                    <button type="button" onClick={closeRestockModal} className="px-5 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-xl font-medium transition-colors">Cancel</button>
                                    <button type="submit" disabled={restockForm.processing} className="px-5 py-2 bg-blue-600 text-white rounded-xl font-medium hover:bg-blue-700 transition-colors shadow-sm disabled:opacity-50 flex items-center gap-2">
                                        <ArrowDownToLine className="w-4 h-4" /> Restock Items
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            )}
        </AdminLayout>
    );
}
