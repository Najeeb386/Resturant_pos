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
    Edit, 
    Trash2, 
    TrendingDown, 
    Calendar, 
    DollarSign,
    FileText,
    AlertTriangle,
    Tag
} from 'lucide-react';
import { useForm, router, usePage } from '@inertiajs/react';
import { Dialog } from '@headlessui/react';

const EXPENSE_CATEGORIES = [
    'Server / Hosting',
    'Marketing & Ads',
    'Software Licenses',
    'Salaries & Staff',
    'Office & Operations',
    'Legal & Accounting',
    'Other'
];

export default function Expenses({ expenses = [] }) {
    const { currencySymbol = '$' } = usePage().props;

    const [searchTerm, setSearchTerm] = useState('');
    const [categoryFilter, setCategoryFilter] = useState('all');

    const [isCreateOpen, setIsCreateOpen] = useState(false);
    const [isEditOpen, setIsEditOpen] = useState(false);
    const [selectedExpenseForEdit, setSelectedExpenseForEdit] = useState(null);

    // Create Form
    const createForm = useForm({
        title: '',
        amount: '',
        category: 'Server / Hosting',
        date: new Date().toISOString().split('T')[0],
        notes: '',
    });

    // Edit Form
    const editForm = useForm({
        title: '',
        amount: '',
        category: 'Server / Hosting',
        date: '',
        notes: '',
    });

    // Metrics calculation
    const stats = useMemo(() => {
        const totalAmount = expenses.reduce((acc, exp) => acc + parseFloat(exp.amount || 0), 0);
        
        const now = new Date();
        const currentMonthExpenses = expenses
            .filter(exp => {
                const expDate = new Date(exp.date);
                return expDate.getMonth() === now.getMonth() && expDate.getFullYear() === now.getFullYear();
            })
            .reduce((acc, exp) => acc + parseFloat(exp.amount || 0), 0);

        return {
            totalAmount: totalAmount.toFixed(2),
            currentMonthAmount: currentMonthExpenses.toFixed(2),
            count: expenses.length,
        };
    }, [expenses]);

    // Real-time Search and Category Filter
    const filteredExpenses = useMemo(() => {
        return expenses.filter(exp => {
            const searchLower = searchTerm.toLowerCase();
            const titleMatch = exp.title?.toLowerCase().includes(searchLower);
            const notesMatch = exp.notes?.toLowerCase().includes(searchLower);
            const catMatch = exp.category?.toLowerCase().includes(searchLower);
            const matchesSearch = !searchTerm || titleMatch || notesMatch || catMatch;

            const matchesCategory = categoryFilter === 'all' || exp.category === categoryFilter;

            return matchesSearch && matchesCategory;
        });
    }, [expenses, searchTerm, categoryFilter]);

    const submitCreate = (e) => {
        e.preventDefault();
        createForm.post('/admin/expenses', {
            onSuccess: () => {
                setIsCreateOpen(false);
                createForm.reset();
            },
        });
    };

    const openEditModal = (exp) => {
        setSelectedExpenseForEdit(exp);
        editForm.setData({
            title: exp.title || '',
            amount: exp.amount || '',
            category: exp.category || 'Server / Hosting',
            date: exp.date ? exp.date.split('T')[0] : '',
            notes: exp.notes || '',
        });
        setIsEditOpen(true);
    };

    const submitEdit = (e) => {
        e.preventDefault();
        if (!selectedExpenseForEdit) return;

        editForm.put(`/admin/expenses/${selectedExpenseForEdit.id}`, {
            onSuccess: () => {
                setIsEditOpen(false);
                setSelectedExpenseForEdit(null);
            },
        });
    };

    const handleDelete = (exp) => {
        if (confirm(`Are you sure you want to delete expense "${exp.title}"?`)) {
            router.delete(`/admin/expenses/${exp.id}`);
        }
    };

    const clearFilters = () => {
        setSearchTerm('');
        setCategoryFilter('all');
    };

    return (
        <SuperAdminLayout>
            {/* Page Header */}
            <div className="mb-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900 mb-1">SaaS Platform Expenses</h1>
                    <p className="text-slate-500 text-sm">Track, filter, and manage operational costs for your SaaS infrastructure.</p>
                </div>
                <Button 
                    onClick={() => setIsCreateOpen(true)} 
                    className="bg-rose-600 hover:bg-rose-700 text-white shadow-lg shadow-rose-500/20"
                >
                    <Plus className="w-5 h-5 mr-2" />
                    Record New Expense
                </Button>
            </div>

            {/* Metrics Overview */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
                <Card className="border-slate-200 bg-white">
                    <CardContent className="p-4 flex items-center justify-between">
                        <div>
                            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Total Platform Costs</p>
                            <h3 className="text-2xl font-extrabold text-rose-600 mt-1">{currencySymbol}{stats.totalAmount}</h3>
                        </div>
                        <div className="w-12 h-12 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center">
                            <TrendingDown className="w-6 h-6" />
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-slate-200 bg-white">
                    <CardContent className="p-4 flex items-center justify-between">
                        <div>
                            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Current Month Expenses</p>
                            <h3 className="text-2xl font-extrabold text-amber-600 mt-1">{currencySymbol}{stats.currentMonthAmount}</h3>
                        </div>
                        <div className="w-12 h-12 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
                            <Calendar className="w-6 h-6" />
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-slate-200 bg-white">
                    <CardContent className="p-4 flex items-center justify-between">
                        <div>
                            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Expense Records</p>
                            <h3 className="text-2xl font-extrabold text-slate-900 mt-1">{stats.count}</h3>
                        </div>
                        <div className="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
                            <FileText className="w-6 h-6" />
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Filter & Search Bar */}
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
                                placeholder="Search expense by title, category, notes..."
                                className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-rose-500 focus:bg-white transition-all"
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
                                <span className="text-xs font-medium text-slate-500 uppercase">Category:</span>
                            </div>

                            <select
                                value={categoryFilter}
                                onChange={(e) => setCategoryFilter(e.target.value)}
                                className="bg-slate-50 border border-slate-200 text-slate-700 text-sm rounded-xl px-3 py-2 focus:outline-none focus:ring-2 focus:ring-rose-500"
                            >
                                <option value="all">All Categories</option>
                                {EXPENSE_CATEGORIES.map(cat => (
                                    <option key={cat} value={cat}>{cat}</option>
                                ))}
                            </select>

                            {(searchTerm || categoryFilter !== 'all') && (
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

            {/* Expenses Table */}
            <Card className="border-slate-200 shadow-sm overflow-hidden">
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-slate-50/80 border-b border-slate-200">
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Expense Title</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Category</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Date</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Amount</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Notes</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {filteredExpenses.length === 0 ? (
                                    <tr>
                                        <td colSpan="6" className="py-12 text-center text-slate-500">
                                            <div className="flex flex-col items-center justify-center">
                                                <TrendingDown className="w-8 h-8 text-slate-300 mb-2" />
                                                <p className="font-medium text-slate-600">No platform expenses recorded yet.</p>
                                                <p className="text-xs text-slate-400 mt-1">Click "Record New Expense" to add your server, domain, or operational costs.</p>
                                            </div>
                                        </td>
                                    </tr>
                                ) : filteredExpenses.map(exp => (
                                    <tr key={exp.id} className="hover:bg-slate-50/50 transition-colors">
                                        <td className="py-4 px-6 font-bold text-slate-900">{exp.title}</td>
                                        <td className="py-4 px-6">
                                            <Badge className="bg-slate-100 text-slate-700 border border-slate-200">
                                                {exp.category}
                                            </Badge>
                                        </td>
                                        <td className="py-4 px-6 text-sm text-slate-600">{new Date(exp.date).toLocaleDateString()}</td>
                                        <td className="py-4 px-6 font-extrabold text-rose-600">{currencySymbol}{parseFloat(exp.amount).toFixed(2)}</td>
                                        <td className="py-4 px-6 text-xs text-slate-500 max-w-xs truncate">{exp.notes || '—'}</td>
                                        <td className="py-4 px-6 text-right">
                                            <div className="flex items-center justify-end gap-1.5">
                                                <button
                                                    onClick={() => openEditModal(exp)}
                                                    title="Edit Expense"
                                                    className="p-1.5 rounded-lg text-slate-400 hover:text-amber-600 hover:bg-amber-50 transition-colors"
                                                >
                                                    <Edit className="w-4 h-4" />
                                                </button>
                                                <button
                                                    onClick={() => handleDelete(exp)}
                                                    title="Delete Expense"
                                                    className="p-1.5 rounded-lg text-slate-400 hover:text-rose-600 hover:bg-rose-50 transition-colors"
                                                >
                                                    <Trash2 className="w-4 h-4" />
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>

            {/* Create Expense Modal */}
            <Dialog open={isCreateOpen} onClose={() => setIsCreateOpen(false)} className="relative z-50">
                <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs" aria-hidden="true" />
                <div className="fixed inset-0 flex items-center justify-center p-4">
                    <Dialog.Panel className="mx-auto max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden">
                        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <Dialog.Title className="text-lg font-bold text-slate-800">Record Platform Expense</Dialog.Title>
                            <button onClick={() => setIsCreateOpen(false)} className="text-slate-400 hover:text-slate-600">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={submitCreate} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Expense Title</label>
                                <input type="text" value={createForm.data.title} onChange={e => createForm.setData('title', e.target.value)} placeholder="e.g. AWS Cloud Server Hosting" className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-rose-500" required />
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Amount ({currencySymbol})</label>
                                    <input type="number" step="0.01" value={createForm.data.amount} onChange={e => createForm.setData('amount', e.target.value)} placeholder="0.00" className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-rose-500" required />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Category</label>
                                    <select value={createForm.data.category} onChange={e => createForm.setData('category', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-rose-500">
                                        {EXPENSE_CATEGORIES.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                                    </select>
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Expense Date</label>
                                <input type="date" value={createForm.data.date} onChange={e => createForm.setData('date', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-rose-500" required />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Notes / Invoice Ref</label>
                                <textarea value={createForm.data.notes} onChange={e => createForm.setData('notes', e.target.value)} rows="2" placeholder="Optional notes or reference ID..." className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-rose-500" />
                            </div>

                            <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                                <Button type="button" variant="ghost" onClick={() => setIsCreateOpen(false)}>Cancel</Button>
                                <Button type="submit" disabled={createForm.processing} className="bg-rose-600 hover:bg-rose-700 text-white">Save Expense</Button>
                            </div>
                        </form>
                    </Dialog.Panel>
                </div>
            </Dialog>

            {/* Edit Expense Modal */}
            <Dialog open={isEditOpen} onClose={() => setIsEditOpen(false)} className="relative z-50">
                <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs" aria-hidden="true" />
                <div className="fixed inset-0 flex items-center justify-center p-4">
                    <Dialog.Panel className="mx-auto max-w-md w-full bg-white rounded-2xl shadow-xl overflow-hidden">
                        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <Dialog.Title className="text-lg font-bold text-slate-800">Edit Platform Expense</Dialog.Title>
                            <button onClick={() => setIsEditOpen(false)} className="text-slate-400 hover:text-slate-600">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={submitEdit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Expense Title</label>
                                <input type="text" value={editForm.data.title} onChange={e => editForm.setData('title', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-rose-500" required />
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Amount ({currencySymbol})</label>
                                    <input type="number" step="0.01" value={editForm.data.amount} onChange={e => editForm.setData('amount', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-rose-500" required />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Category</label>
                                    <select value={editForm.data.category} onChange={e => editForm.setData('category', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-rose-500">
                                        {EXPENSE_CATEGORIES.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                                    </select>
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Expense Date</label>
                                <input type="date" value={editForm.data.date} onChange={e => editForm.setData('date', e.target.value)} className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-rose-500" required />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Notes</label>
                                <textarea value={editForm.data.notes} onChange={e => editForm.setData('notes', e.target.value)} rows="2" className="w-full border-slate-200 rounded-xl shadow-xs py-2 px-3 focus:ring-2 focus:ring-rose-500" />
                            </div>

                            <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
                                <Button type="button" variant="ghost" onClick={() => setIsEditOpen(false)}>Cancel</Button>
                                <Button type="submit" disabled={editForm.processing} className="bg-rose-600 hover:bg-rose-700 text-white">Save Changes</Button>
                            </div>
                        </form>
                    </Dialog.Panel>
                </div>
            </Dialog>
        </SuperAdminLayout>
    );
}
