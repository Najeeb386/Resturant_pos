import React, { useState } from 'react';
import AdminLayout from '../../Layouts/AdminLayout';
import { Card, CardContent, CardHeader, CardTitle } from '../../Components/ui/Card';
import { useForm } from '@inertiajs/react';
import { Plus, Edit2, Trash2, Receipt } from 'lucide-react';

export default function ExpensesIndex({ expenses, currencySymbol }) {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingId, setEditingId] = useState(null);

    const { data, setData, post, put, delete: destroy, reset, errors, clearErrors } = useForm({
        amount: '',
        category: '',
        date: new Date().toISOString().split('T')[0],
        notes: ''
    });

    const openModal = (expense = null) => {
        clearErrors();
        if (expense) {
            setEditingId(expense.id);
            setData({
                amount: expense.amount,
                category: expense.category,
                date: expense.date,
                notes: expense.notes || ''
            });
        } else {
            setEditingId(null);
            reset();
        }
        setIsModalOpen(true);
    };

    const closeModal = () => {
        setIsModalOpen(false);
        reset();
        setEditingId(null);
        clearErrors();
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        if (editingId) {
            put(`/expenses/${editingId}`, {
                onSuccess: () => closeModal()
            });
        } else {
            post('/expenses', {
                onSuccess: () => closeModal()
            });
        }
    };

    const handleDelete = (id) => {
        if (confirm('Are you sure you want to delete this expense?')) {
            destroy(`/expenses/${id}`);
        }
    };

    const categories = ['Rent', 'Utilities', 'Payroll', 'Ingredients', 'Marketing', 'Maintenance', 'Other'];

    return (
        <AdminLayout>
            <div className="flex justify-between items-center mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Expenses</h1>
                    <p className="text-sm text-gray-500">Track and manage your restaurant's operational costs.</p>
                </div>
                <button 
                    onClick={() => openModal()}
                    className="bg-primary text-white px-4 py-2 rounded-xl flex items-center gap-2 hover:bg-orange-600 transition-colors shadow-sm"
                >
                    <Plus className="w-5 h-5" />
                    Log Expense
                </button>
            </div>

            <Card>
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead className="bg-gray-50">
                                <tr>
                                    <th className="py-4 px-6 text-left font-semibold text-gray-600 text-sm">Date</th>
                                    <th className="py-4 px-6 text-left font-semibold text-gray-600 text-sm">Category</th>
                                    <th className="py-4 px-6 text-left font-semibold text-gray-600 text-sm">Amount</th>
                                    <th className="py-4 px-6 text-left font-semibold text-gray-600 text-sm">Notes</th>
                                    <th className="py-4 px-6 text-right font-semibold text-gray-600 text-sm">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-100">
                                {expenses.data.map((expense) => (
                                    <tr key={expense.id} className="hover:bg-orange-50/30 transition-colors">
                                        <td className="py-4 px-6 text-gray-700 whitespace-nowrap">{expense.date}</td>
                                        <td className="py-4 px-6">
                                            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                                                {expense.category}
                                            </span>
                                        </td>
                                        <td className="py-4 px-6 font-bold text-red-600 whitespace-nowrap">
                                            {currencySymbol}{Number(expense.amount).toFixed(2)}
                                        </td>
                                        <td className="py-4 px-6 text-gray-500 text-sm truncate max-w-xs">{expense.notes || '-'}</td>
                                        <td className="py-4 px-6 text-right">
                                            <div className="flex justify-end gap-2">
                                                <button onClick={() => openModal(expense)} className="p-2 text-gray-400 hover:text-blue-600 bg-white rounded-lg border border-gray-100 shadow-sm transition-colors">
                                                    <Edit2 className="w-4 h-4" />
                                                </button>
                                                <button onClick={() => handleDelete(expense.id)} className="p-2 text-gray-400 hover:text-red-600 bg-white rounded-lg border border-gray-100 shadow-sm transition-colors">
                                                    <Trash2 className="w-4 h-4" />
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {expenses.data.length === 0 && (
                                    <tr>
                                        <td colSpan="5" className="py-12 text-center text-gray-500">
                                            <Receipt className="w-12 h-12 mx-auto mb-3 text-gray-300" />
                                            No expenses logged yet. Add one to track your costs!
                                        </td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>

            {/* Modal */}
            {isModalOpen && (
                <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl w-full max-w-md shadow-2xl overflow-hidden">
                        <div className="p-6 border-b border-gray-100 flex justify-between items-center">
                            <h2 className="text-xl font-bold text-gray-800">
                                {editingId ? 'Edit Expense' : 'Log New Expense'}
                            </h2>
                            <button onClick={closeModal} className="text-gray-400 hover:text-gray-600">
                                <span className="absolute top-6 right-6 font-bold text-xl cursor-pointer" onClick={closeModal}>&times;</span>
                            </button>
                        </div>
                        <div className="p-6">
                            <form onSubmit={handleSubmit} className="space-y-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Amount ({currencySymbol})</label>
                                    <input
                                        type="number"
                                        step="0.01"
                                        min="0"
                                        value={data.amount}
                                        onChange={e => setData('amount', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        required
                                    />
                                    {errors.amount && <p className="text-red-500 text-xs mt-1">{errors.amount}</p>}
                                </div>
                                
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
                                    <select
                                        value={data.category}
                                        onChange={e => setData('category', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all bg-white"
                                        required
                                    >
                                        <option value="">Select Category</option>
                                        {categories.map(c => (
                                            <option key={c} value={c}>{c}</option>
                                        ))}
                                    </select>
                                    {errors.category && <p className="text-red-500 text-xs mt-1">{errors.category}</p>}
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Date</label>
                                    <input
                                        type="date"
                                        value={data.date}
                                        onChange={e => setData('date', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        required
                                    />
                                    {errors.date && <p className="text-red-500 text-xs mt-1">{errors.date}</p>}
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Notes (Optional)</label>
                                    <textarea
                                        value={data.notes}
                                        onChange={e => setData('notes', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        rows="3"
                                    ></textarea>
                                    {errors.notes && <p className="text-red-500 text-xs mt-1">{errors.notes}</p>}
                                </div>

                                <div className="pt-4 flex justify-end gap-3">
                                    <button
                                        type="button"
                                        onClick={closeModal}
                                        className="px-5 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-xl font-medium transition-colors"
                                    >
                                        Cancel
                                    </button>
                                    <button
                                        type="submit"
                                        className="px-5 py-2 bg-primary text-white rounded-xl font-medium hover:bg-orange-600 transition-colors shadow-sm"
                                    >
                                        Save Expense
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
