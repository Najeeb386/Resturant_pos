import React, { useState, useRef } from 'react';
import AdminLayout from '../../Layouts/AdminLayout';
import { Card, CardContent } from '../../Components/ui/Card';
import { Badge } from '../../Components/ui/Badge';
import { Button } from '../../Components/ui/Button';
import { Plus, Edit2, Trash2, X, Loader2, Image as ImageIcon } from 'lucide-react';
import { useForm, usePage } from '@inertiajs/react';

export default function Menu({ categories = [], menuItems = [] }) {
    const { flash } = usePage().props;
    const [activeTab, setActiveTab] = useState('items'); // 'items' or 'categories'
    
    // Items Modal
    const [isItemModalOpen, setIsItemModalOpen] = useState(false);
    const [editingItemId, setEditingItemId] = useState(null);
    const fileInputRef = useRef(null);

    const itemForm = useForm({
        name: '',
        category_id: '',
        price: '',
        stock_quantity: 0,
        description: '',
        image: null,
        _method: 'post'
    });

    // Categories Modal
    const [isCategoryModalOpen, setIsCategoryModalOpen] = useState(false);
    const categoryForm = useForm({
        name: '',
        description: ''
    });

    // Handlers for Items
    const openItemModal = (item = null) => {
        itemForm.clearErrors();
        if (item) {
            setEditingItemId(item.id);
            itemForm.setData({
                name: item.name,
                category_id: item.category_id,
                price: item.price,
                stock_quantity: item.stock_quantity,
                description: item.description || '',
                image: null,
                _method: 'post' // We use POST for file uploads even on update
            });
        } else {
            setEditingItemId(null);
            itemForm.reset();
            itemForm.setData('_method', 'post');
        }
        setIsItemModalOpen(true);
    };

    const closeItemModal = () => {
        setIsItemModalOpen(false);
        itemForm.reset();
        setEditingItemId(null);
        itemForm.clearErrors();
    };

    const handleItemSubmit = (e) => {
        e.preventDefault();
        if (editingItemId) {
            itemForm.post(`/menu/item/${editingItemId}`, {
                onSuccess: () => closeItemModal()
            });
        } else {
            itemForm.post('/menu/item', {
                onSuccess: () => closeItemModal()
            });
        }
    };

    const handleDeleteItem = (id) => {
        if (confirm('Are you sure you want to delete this menu item?')) {
            itemForm.delete(`/menu/item/${id}`);
        }
    };

    // Handlers for Categories
    const openCategoryModal = () => {
        categoryForm.clearErrors();
        categoryForm.reset();
        setIsCategoryModalOpen(true);
    };

    const closeCategoryModal = () => {
        setIsCategoryModalOpen(false);
        categoryForm.reset();
        categoryForm.clearErrors();
    };

    const handleCategorySubmit = (e) => {
        e.preventDefault();
        categoryForm.post('/menu/category', {
            onSuccess: () => closeCategoryModal()
        });
    };

    const handleDeleteCategory = (id) => {
        if (confirm('Are you sure you want to delete this category? All items in it will also be deleted!')) {
            categoryForm.delete(`/menu/category/${id}`);
        }
    };

    return (
        <AdminLayout>
            <div className="mb-6 flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 mb-1">Menu Management</h1>
                    <p className="text-gray-500">Manage your menu items, categories, and stock quantities.</p>
                </div>
                <div className="flex gap-2 w-full sm:w-auto">
                    <Button onClick={openCategoryModal} variant="outline" className="flex-1 sm:flex-none whitespace-nowrap">
                        <Plus className="w-4 h-4 mr-2" /> Category
                    </Button>
                    <Button onClick={() => openItemModal()} className="flex-1 sm:flex-none whitespace-nowrap shadow-lg shadow-primary/20">
                        <Plus className="w-4 h-4 mr-2" /> Menu Item
                    </Button>
                </div>
            </div>

            {flash?.message && (
                <div className="mb-6 p-4 bg-green-50 text-green-600 rounded-xl border border-green-200 font-medium">
                    {flash.message}
                </div>
            )}

            <div className="mb-6 flex gap-2 border-b border-gray-200 pb-px">
                <button 
                    onClick={() => setActiveTab('items')}
                    className={`px-4 py-2 font-medium text-sm transition-colors relative ${activeTab === 'items' ? 'text-primary' : 'text-gray-500 hover:text-gray-700'}`}
                >
                    Menu Items ({menuItems.length})
                    {activeTab === 'items' && <div className="absolute bottom-0 left-0 w-full h-0.5 bg-primary rounded-t-full"></div>}
                </button>
                <button 
                    onClick={() => setActiveTab('categories')}
                    className={`px-4 py-2 font-medium text-sm transition-colors relative ${activeTab === 'categories' ? 'text-primary' : 'text-gray-500 hover:text-gray-700'}`}
                >
                    Categories ({categories.length})
                    {activeTab === 'categories' && <div className="absolute bottom-0 left-0 w-full h-0.5 bg-primary rounded-t-full"></div>}
                </button>
            </div>

            <Card>
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-gray-50 border-b border-gray-100">
                                    {activeTab === 'items' ? (
                                        <>
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Item Name</th>
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Category</th>
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Price</th>
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Stock</th>
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Status</th>
                                        </>
                                    ) : (
                                        <>
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Category Name</th>
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Description</th>
                                        </>
                                    )}
                                    <th className="py-4 px-6 font-semibold text-gray-600 text-sm text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-50">
                                {activeTab === 'items' && menuItems.map(item => (
                                    <tr key={item.id} className="hover:bg-gray-50/50 transition-colors">
                                        <td className="py-4 px-6">
                                            <div className="flex items-center gap-3">
                                                {item.image ? (
                                                    <img src={`/storage/${item.image}`} alt={item.name} className="w-10 h-10 rounded-lg object-cover border border-gray-100" />
                                                ) : (
                                                    <div className="w-10 h-10 rounded-lg bg-gray-100 flex items-center justify-center text-gray-400">
                                                        <ImageIcon className="w-5 h-5" />
                                                    </div>
                                                )}
                                                <span className="font-medium text-gray-900">{item.name}</span>
                                            </div>
                                        </td>
                                        <td className="py-4 px-6 text-gray-500">{item.category?.name || 'Uncategorized'}</td>
                                        <td className="py-4 px-6 font-bold text-primary">${Number(item.price).toFixed(2)}</td>
                                        <td className="py-4 px-6 font-medium text-gray-700">{item.stock_quantity}</td>
                                        <td className="py-4 px-6">
                                            {item.stock_quantity > 0 ? (
                                                <Badge variant="success">Available</Badge>
                                            ) : (
                                                <Badge variant="danger">Out of Stock</Badge>
                                            )}
                                        </td>
                                        <td className="py-4 px-6 text-right">
                                            <div className="flex justify-end gap-2">
                                                <Button variant="outline" size="sm" className="p-2" onClick={() => openItemModal(item)}>
                                                    <Edit2 className="w-4 h-4 text-gray-600" />
                                                </Button>
                                                <Button variant="outline" size="sm" className="p-2 border-red-200 hover:bg-red-50" onClick={() => handleDeleteItem(item.id)}>
                                                    <Trash2 className="w-4 h-4 text-red-500" />
                                                </Button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                
                                {activeTab === 'categories' && categories.map(cat => (
                                    <tr key={cat.id} className="hover:bg-gray-50/50 transition-colors">
                                        <td className="py-4 px-6 font-medium text-gray-900">{cat.name}</td>
                                        <td className="py-4 px-6 text-gray-500">{cat.description || '-'}</td>
                                        <td className="py-4 px-6 text-right">
                                            <Button variant="outline" size="sm" className="p-2 border-red-200 hover:bg-red-50" onClick={() => handleDeleteCategory(cat.id)}>
                                                <Trash2 className="w-4 h-4 text-red-500" />
                                            </Button>
                                        </td>
                                    </tr>
                                ))}

                                {(activeTab === 'items' && menuItems.length === 0) && (
                                    <tr><td colSpan="6" className="py-12 text-center text-gray-500">No menu items found. Add one to get started.</td></tr>
                                )}
                                {(activeTab === 'categories' && categories.length === 0) && (
                                    <tr><td colSpan="3" className="py-12 text-center text-gray-500">No categories found. Add one to get started.</td></tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>

            {/* Menu Item Modal */}
            {isItemModalOpen && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4 overflow-y-auto">
                    <div className="bg-white rounded-2xl w-full max-w-lg shadow-xl overflow-hidden my-8">
                        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
                            <h2 className="text-lg font-bold text-gray-900">
                                {editingItemId ? 'Edit Menu Item' : 'Add Menu Item'}
                            </h2>
                            <button onClick={closeItemModal} className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-full transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleItemSubmit} className="p-6 space-y-4">
                            <div className="grid grid-cols-2 gap-4">
                                <div className="col-span-2">
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Item Name</label>
                                    <input
                                        type="text"
                                        value={itemForm.data.name}
                                        onChange={e => itemForm.setData('name', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        required
                                    />
                                    {itemForm.errors.name && <p className="text-red-500 text-xs mt-1">{itemForm.errors.name}</p>}
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
                                    <select
                                        value={itemForm.data.category_id}
                                        onChange={e => itemForm.setData('category_id', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all bg-white"
                                        required
                                    >
                                        <option value="">Select Category</option>
                                        {categories.map(c => (
                                            <option key={c.id} value={c.id}>{c.name}</option>
                                        ))}
                                    </select>
                                    {itemForm.errors.category_id && <p className="text-red-500 text-xs mt-1">{itemForm.errors.category_id}</p>}
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Price</label>
                                    <input
                                        type="number"
                                        step="0.01"
                                        min="0"
                                        value={itemForm.data.price}
                                        onChange={e => itemForm.setData('price', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        required
                                    />
                                    {itemForm.errors.price && <p className="text-red-500 text-xs mt-1">{itemForm.errors.price}</p>}
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Initial Stock</label>
                                    <input
                                        type="number"
                                        min="0"
                                        value={itemForm.data.stock_quantity}
                                        onChange={e => itemForm.setData('stock_quantity', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        required
                                    />
                                    {itemForm.errors.stock_quantity && <p className="text-red-500 text-xs mt-1">{itemForm.errors.stock_quantity}</p>}
                                </div>

                                <div className="col-span-2">
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Description (Optional)</label>
                                    <textarea
                                        value={itemForm.data.description}
                                        onChange={e => itemForm.setData('description', e.target.value)}
                                        rows="2"
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    ></textarea>
                                </div>

                                <div className="col-span-2">
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Item Image (Optional)</label>
                                    <input
                                        type="file"
                                        accept="image/*"
                                        onChange={e => itemForm.setData('image', e.target.files[0])}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl text-sm"
                                    />
                                    {itemForm.progress && (
                                        <progress value={itemForm.progress.percentage} max="100" className="w-full mt-2">
                                            {itemForm.progress.percentage}%
                                        </progress>
                                    )}
                                </div>
                            </div>

                            <div className="pt-4 flex gap-3">
                                <Button type="button" variant="outline" className="flex-1" onClick={closeItemModal} disabled={itemForm.processing}>
                                    Cancel
                                </Button>
                                <Button type="submit" className="flex-1 flex justify-center items-center gap-2" disabled={itemForm.processing}>
                                    {itemForm.processing && <Loader2 className="w-4 h-4 animate-spin" />}
                                    {editingItemId ? 'Update Item' : 'Save Item'}
                                </Button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Category Modal */}
            {isCategoryModalOpen && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl w-full max-w-md shadow-xl overflow-hidden">
                        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
                            <h2 className="text-lg font-bold text-gray-900">Add Category</h2>
                            <button onClick={closeCategoryModal} className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-full transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleCategorySubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Category Name</label>
                                <input
                                    type="text"
                                    value={categoryForm.data.name}
                                    onChange={e => categoryForm.setData('name', e.target.value)}
                                    className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    required
                                />
                                {categoryForm.errors.name && <p className="text-red-500 text-xs mt-1">{categoryForm.errors.name}</p>}
                            </div>

                            <div className="pt-4 flex gap-3">
                                <Button type="button" variant="outline" className="flex-1" onClick={closeCategoryModal} disabled={categoryForm.processing}>
                                    Cancel
                                </Button>
                                <Button type="submit" className="flex-1 flex justify-center items-center gap-2" disabled={categoryForm.processing}>
                                    {categoryForm.processing && <Loader2 className="w-4 h-4 animate-spin" />}
                                    Save Category
                                </Button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </AdminLayout>
    );
}
