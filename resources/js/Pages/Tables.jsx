import React, { useState } from 'react';
import AdminLayout from '../Layouts/AdminLayout';
import { Card, CardContent } from '../Components/ui/Card';
import { Badge } from '../Components/ui/Badge';
import { Button } from '../Components/ui/Button';
import { Plus, Trash2, X } from 'lucide-react';
import { useForm } from '@inertiajs/react';

export default function Tables({ tables = [] }) {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingId, setEditingId] = useState(null);

    const { data, setData, post, put, delete: destroy, reset, errors, clearErrors } = useForm({
        table_number: '',
        capacity: 4,
        status: 'available'
    });

    const openModal = (table = null) => {
        clearErrors();
        if (table) {
            setEditingId(table.id);
            setData({
                table_number: table.table_number,
                capacity: table.capacity,
                status: table.status
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
            put(`/tables/${editingId}`, {
                onSuccess: () => closeModal(),
            });
        } else {
            post('/tables', {
                onSuccess: () => closeModal(),
            });
        }
    };

    const handleDelete = (id, e) => {
        e.stopPropagation();
        if (confirm('Are you sure you want to delete this table?')) {
            destroy(`/tables/${id}`);
        }
    };

    return (
        <AdminLayout>
            <div className="mb-6 flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 mb-1">Table Management</h1>
                    <p className="text-gray-500">Overview of all restaurant tables and their current status.</p>
                </div>
                <div className="flex flex-wrap gap-4 items-center">
                    <div className="flex items-center gap-2">
                        <div className="w-3 h-3 rounded-full bg-green-500"></div>
                        <span className="text-sm text-gray-600">Available</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className="w-3 h-3 rounded-full bg-red-500"></div>
                        <span className="text-sm text-gray-600">Occupied</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className="w-3 h-3 rounded-full bg-blue-500"></div>
                        <span className="text-sm text-gray-600">Reserved</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
                        <span className="text-sm text-gray-600">Cleaning</span>
                    </div>
                    <Button onClick={() => openModal()} className="sm:ml-4 flex items-center gap-2">
                        <Plus className="w-4 h-4" /> Add Table
                    </Button>
                </div>
            </div>

            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                {tables.map(table => (
                    <Card key={table.id} onClick={() => openModal(table)} className={`cursor-pointer transition-all hover:-translate-y-1 hover:shadow-lg relative group ${
                        table.status === 'occupied' ? 'border-red-200 bg-red-50/10' :
                        table.status === 'reserved' ? 'border-blue-200 bg-blue-50/10' :
                        table.status === 'cleaning' ? 'border-yellow-200 bg-yellow-50/10' :
                        'border-green-200 bg-green-50/10'
                    }`}>
                        <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
                            <button onClick={(e) => handleDelete(table.id, e)} className="p-1.5 bg-white text-red-500 hover:bg-red-50 rounded-lg shadow-sm">
                                <Trash2 className="w-4 h-4" />
                            </button>
                        </div>
                        <CardContent className="p-6">
                            <div className="flex justify-between items-start mb-4">
                                <h3 className="text-xl font-bold text-gray-800">Table {table.table_number}</h3>
                                <Badge 
                                    variant={
                                        table.status === 'available' ? 'success' :
                                        table.status === 'occupied' ? 'danger' :
                                        table.status === 'reserved' ? 'primary' : 'warning'
                                    }
                                >
                                    {table.status}
                                </Badge>
                            </div>
                            <div className="text-gray-500 text-sm mb-4">
                                {table.capacity} Seats
                            </div>
                        </CardContent>
                    </Card>
                ))}
                
                {tables.length === 0 && (
                    <div className="col-span-full py-12 text-center text-gray-500 bg-white rounded-2xl border border-dashed border-gray-300">
                        No tables found. Click "Add Table" to create one.
                    </div>
                )}
            </div>

            {/* Modal */}
            {isModalOpen && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl w-full max-w-md shadow-xl overflow-hidden">
                        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
                            <h2 className="text-lg font-bold text-gray-900">
                                {editingId ? 'Edit Table' : 'Add New Table'}
                            </h2>
                            <button onClick={closeModal} className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-full transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Table Number/Name</label>
                                <input
                                    type="text"
                                    value={data.table_number}
                                    onChange={e => setData('table_number', e.target.value)}
                                    className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    placeholder="e.g. 12 or Window 1"
                                    required
                                />
                                {errors.table_number && <p className="text-red-500 text-xs mt-1">{errors.table_number}</p>}
                            </div>
                            
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Capacity (Seats)</label>
                                <input
                                    type="number"
                                    min="1"
                                    value={data.capacity}
                                    onChange={e => setData('capacity', e.target.value)}
                                    className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    required
                                />
                                {errors.capacity && <p className="text-red-500 text-xs mt-1">{errors.capacity}</p>}
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
                                <select
                                    value={data.status}
                                    onChange={e => setData('status', e.target.value)}
                                    className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all bg-white"
                                >
                                    <option value="available">Available</option>
                                    <option value="occupied">Occupied</option>
                                    <option value="reserved">Reserved</option>
                                    <option value="cleaning">Cleaning</option>
                                </select>
                                {errors.status && <p className="text-red-500 text-xs mt-1">{errors.status}</p>}
                            </div>

                            <div className="pt-4 flex gap-3">
                                <Button type="button" variant="outline" className="flex-1" onClick={closeModal}>
                                    Cancel
                                </Button>
                                <Button type="submit" className="flex-1">
                                    {editingId ? 'Update Table' : 'Save Table'}
                                </Button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </AdminLayout>
    );
}
