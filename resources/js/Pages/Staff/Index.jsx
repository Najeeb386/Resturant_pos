import React, { useState } from 'react';
import AdminLayout from '../../Layouts/AdminLayout';
import { Card, CardContent } from '../../Components/ui/Card';
import { Badge } from '../../Components/ui/Badge';
import { Button } from '../../Components/ui/Button';
import { Plus, Trash2, X, Loader2, Edit2, UserCircle } from 'lucide-react';
import { useForm, usePage } from '@inertiajs/react';

export default function StaffIndex({ staff = [], roles = [] }) {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingId, setEditingId] = useState(null);
    const { auth, flash } = usePage().props;

    const { data, setData, post, put, delete: destroy, reset, errors, clearErrors, processing } = useForm({
        name: '',
        email: '',
        password: '',
        role_id: ''
    });

    const openModal = (user = null) => {
        clearErrors();
        if (user) {
            setEditingId(user.id);
            setData({
                name: user.name,
                email: user.email,
                password: '',
                role_id: user.role_id
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
            put(`/staff/${editingId}`, {
                onSuccess: () => closeModal(),
            });
        } else {
            post('/staff', {
                onSuccess: () => closeModal(),
            });
        }
    };

    const handleDelete = (id) => {
        if (confirm('Are you sure you want to remove this staff member?')) {
            destroy(`/staff/${id}`);
        }
    };

    return (
        <AdminLayout>
            <div className="mb-6 flex justify-between items-end">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 mb-1">Staff Management</h1>
                    <p className="text-gray-500">Manage accounts for your cashiers, wait staff, and kitchen team.</p>
                </div>
                <Button onClick={() => openModal()} className="flex items-center gap-2">
                    <Plus className="w-4 h-4" /> Add Staff
                </Button>
            </div>

            {flash?.message && (
                <div className="mb-6 p-4 bg-green-50 text-green-600 rounded-xl border border-green-200 font-medium">
                    {flash.message}
                </div>
            )}

            <Card>
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-gray-50 border-b border-gray-100">
                                    <th className="px-6 py-4 font-semibold text-gray-700 text-sm">Name</th>
                                    <th className="px-6 py-4 font-semibold text-gray-700 text-sm">Email</th>
                                    <th className="px-6 py-4 font-semibold text-gray-700 text-sm">Role</th>
                                    <th className="px-6 py-4 font-semibold text-gray-700 text-sm text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-100">
                                {staff.map(user => (
                                    <tr key={user.id} className="hover:bg-gray-50/50 transition-colors">
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-3">
                                                <div className="w-10 h-10 rounded-full bg-primary/10 text-primary flex items-center justify-center">
                                                    <UserCircle className="w-6 h-6" />
                                                </div>
                                                <span className="font-medium text-gray-900">{user.name}</span>
                                                {user.id === auth.user.id && (
                                                    <Badge variant="primary" className="ml-2 text-xs">You</Badge>
                                                )}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 text-gray-600">{user.email}</td>
                                        <td className="px-6 py-4">
                                            <Badge variant={user.role?.name === 'Restaurant Owner' ? 'warning' : 'success'}>
                                                {user.role?.name || 'Staff'}
                                            </Badge>
                                        </td>
                                        <td className="px-6 py-4 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <Button variant="outline" size="sm" onClick={() => openModal(user)} className="p-2">
                                                    <Edit2 className="w-4 h-4 text-gray-600" />
                                                </Button>
                                                {user.id !== auth.user.id && (
                                                    <Button variant="outline" size="sm" onClick={() => handleDelete(user.id)} className="p-2 border-red-200 hover:bg-red-50">
                                                        <Trash2 className="w-4 h-4 text-red-500" />
                                                    </Button>
                                                )}
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {staff.length === 0 && (
                                    <tr>
                                        <td colSpan="4" className="px-6 py-12 text-center text-gray-500">
                                            No staff members found.
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
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl w-full max-w-md shadow-xl overflow-hidden">
                        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
                            <h2 className="text-lg font-bold text-gray-900">
                                {editingId ? 'Edit Staff Member' : 'Add New Staff'}
                            </h2>
                            <button onClick={closeModal} className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-full transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
                                <input
                                    type="text"
                                    value={data.name}
                                    onChange={e => setData('name', e.target.value)}
                                    className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    required
                                />
                                {errors.name && <p className="text-red-500 text-xs mt-1">{errors.name}</p>}
                            </div>
                            
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Email Address</label>
                                <input
                                    type="email"
                                    value={data.email}
                                    onChange={e => setData('email', e.target.value)}
                                    className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    required
                                />
                                {errors.email && <p className="text-red-500 text-xs mt-1">{errors.email}</p>}
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Role</label>
                                <select
                                    value={data.role_id}
                                    onChange={e => setData('role_id', e.target.value)}
                                    className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all bg-white"
                                    required
                                >
                                    <option value="">Select a role</option>
                                    {roles.map(role => (
                                        <option key={role.id} value={role.id}>{role.name}</option>
                                    ))}
                                </select>
                                {errors.role_id && <p className="text-red-500 text-xs mt-1">{errors.role_id}</p>}
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">
                                    Password {editingId && <span className="text-gray-400 font-normal">(Leave blank to keep current)</span>}
                                </label>
                                <input
                                    type="password"
                                    value={data.password}
                                    onChange={e => setData('password', e.target.value)}
                                    className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    required={!editingId}
                                />
                                {errors.password && <p className="text-red-500 text-xs mt-1">{errors.password}</p>}
                            </div>

                            <div className="pt-4 flex gap-3">
                                <Button type="button" variant="outline" className="flex-1" onClick={closeModal} disabled={processing}>
                                    Cancel
                                </Button>
                                <Button type="submit" className="flex-1 flex items-center justify-center gap-2" disabled={processing}>
                                    {processing && <Loader2 className="w-4 h-4 animate-spin" />}
                                    {editingId ? 'Update Staff' : 'Save Staff'}
                                </Button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </AdminLayout>
    );
}
