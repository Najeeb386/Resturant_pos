import React, { useState, useRef } from 'react';
import AdminLayout from '../../Layouts/AdminLayout';
import { Card, CardContent } from '../../Components/ui/Card';
import { Badge } from '../../Components/ui/Badge';
import { Button } from '../../Components/ui/Button';
import { Plus, Edit2, Trash2, X, Loader2, Image as ImageIcon } from 'lucide-react';
import { useForm, usePage } from '@inertiajs/react';

export default function Menu({ categories = [], menuItems = [], inventory = [] }) {
    const { auth, flash } = usePage().props;
    const isOwner = auth?.user?.role_id === 2;
    const [activeTab, setActiveTab] = useState('items'); // 'items' or 'categories'
    
    // Items Modal
    const [isItemModalOpen, setIsItemModalOpen] = useState(false);
    const [editingItemId, setEditingItemId] = useState(null);
    const fileInputRef = useRef(null);

    const itemForm = useForm({
        name: '',
        category_id: '',
        price: '',
        cost_price: '',
        stock_quantity: 0,
        description: '',
        is_deal: false,
        ingredients: [],
        dealItems: [],
        image: null,
        _method: 'post'
    });

    const { data, setData, post, delete: destroy, reset, clearErrors, errors, processing, progress } = itemForm;

    // Categories Modal
    const [isCategoryModalOpen, setIsCategoryModalOpen] = useState(false);
    const categoryForm = useForm({
        name: '',
        description: ''
    });

    // Handlers for Items
    const openItemModal = (item = null) => {
        clearErrors();
        if (item) {
            setEditingItemId(item.id);
            setData({
                name: item.name,
                category_id: item.category_id,
                price: item.price,
                cost_price: item.cost_price,
                stock_quantity: item.stock_quantity,
                description: item.description || '',
                is_deal: Boolean(item.is_deal),
                ingredients: item.ingredients ? item.ingredients.map(ing => ({ id: String(ing.id), quantity: ing.pivot.quantity })) : [],
                dealItems: item.deal_items ? item.deal_items.map(di => ({ id: String(di.id), quantity: di.pivot.quantity })) : [],
                image: null,
                _method: 'post' // We use POST for file uploads even on update
            });
        } else {
            setEditingItemId(null);
            reset();
            setData('_method', 'post');
        }
        setIsItemModalOpen(true);
    };

    const closeItemModal = () => {
        setIsItemModalOpen(false);
        reset();
        setEditingItemId(null);
        clearErrors();
    };

    const handleItemSubmit = (e) => {
        e.preventDefault();
        if (editingItemId) {
            post(`/menu/item/${editingItemId}`, {
                onSuccess: () => closeItemModal()
            });
        } else {
            post('/menu/item', {
                onSuccess: () => closeItemModal()
            });
        }
    };

    const handleDeleteItem = (id) => {
        if (confirm('Are you sure you want to delete this menu item?')) {
            destroy(`/menu/item/${id}`);
        }
    };

    const addIngredient = () => {
        setData('ingredients', [...data.ingredients, { id: '', quantity: '' }]);
    };

    const removeIngredient = (index) => {
        const newIngredients = [...data.ingredients];
        newIngredients.splice(index, 1);
        setData('ingredients', newIngredients);
    };

    const updateIngredient = (index, field, value) => {
        const newIngredients = [...data.ingredients];
        newIngredients[index][field] = value;
        setData('ingredients', newIngredients);
    };

    const addDealItem = () => {
        setData('dealItems', [...data.dealItems, { id: '', quantity: 1 }]);
    };

    const removeDealItem = (index) => {
        const newDealItems = [...data.dealItems];
        newDealItems.splice(index, 1);
        setData('dealItems', newDealItems);
    };

    const updateDealItem = (index, field, value) => {
        const newDealItems = [...data.dealItems];
        newDealItems[index][field] = value;
        setData('dealItems', newDealItems);
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
                {isOwner && (
                    <div className="flex gap-2 w-full sm:w-auto">
                        <Button onClick={openCategoryModal} variant="outline" className="flex-1 sm:flex-none whitespace-nowrap">
                            <Plus className="w-4 h-4 mr-2" /> Category
                        </Button>
                        <Button onClick={() => openItemModal()} className="flex-1 sm:flex-none whitespace-nowrap shadow-lg shadow-primary/20">
                            <Plus className="w-4 h-4 mr-2" /> Menu Item
                        </Button>
                    </div>
                )}
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
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Sale Price</th>
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Cost Price</th>
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Stock</th>
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Status</th>
                                        </>
                                    ) : (
                                        <>
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Category Name</th>
                                            <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Description</th>
                                        </>
                                    )}
                                    {isOwner && <th className="py-4 px-6 font-semibold text-gray-600 text-sm text-right">Actions</th>}
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
                                        <td className="py-4 px-6 font-bold text-orange-600">${Number(item.cost_price || 0).toFixed(2)}</td>
                                        <td className="py-4 px-6 font-medium text-gray-700">{item.stock_quantity}</td>
                                        <td className="py-4 px-6">
                                            {item.stock_quantity > 0 ? (
                                                <Badge variant="success">Available</Badge>
                                            ) : (
                                                <Badge variant="danger">Out of Stock</Badge>
                                            )}
                                        </td>
                                        {isOwner && (
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
                                        )}
                                    </tr>
                                ))}
                                
                                {activeTab === 'categories' && categories.map(cat => (
                                    <tr key={cat.id} className="hover:bg-gray-50/50 transition-colors">
                                        <td className="py-4 px-6 font-medium text-gray-900">{cat.name}</td>
                                        <td className="py-4 px-6 text-gray-500">{cat.description || '-'}</td>
                                        {isOwner && (
                                            <td className="py-4 px-6 text-right">
                                                <Button variant="outline" size="sm" className="p-2 border-red-200 hover:bg-red-50" onClick={() => handleDeleteCategory(cat.id)}>
                                                    <Trash2 className="w-4 h-4 text-red-500" />
                                                </Button>
                                            </td>
                                        )}
                                    </tr>
                                ))}

                                {(activeTab === 'items' && menuItems.length === 0) && (
                                    <tr><td colSpan="7" className="py-12 text-center text-gray-500">No menu items found. Add one to get started.</td></tr>
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
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Item/Deal Name</label>
                                    <input
                                        type="text"
                                        value={data.name}
                                        onChange={e => setData('name', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        required
                                    />
                                    {errors.name && <p className="text-red-500 text-xs mt-1">{errors.name}</p>}
                                </div>

                                <div className="col-span-2">
                                    <label className="flex items-center space-x-2 cursor-pointer bg-blue-50 p-3 rounded-xl border border-blue-100">
                                        <input
                                            type="checkbox"
                                            checked={data.is_deal}
                                            onChange={e => setData('is_deal', e.target.checked)}
                                            className="w-4 h-4 text-primary rounded focus:ring-primary"
                                        />
                                        <span className="text-sm font-medium text-blue-900">This is a Combo / Deal</span>
                                    </label>
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
                                    <select
                                        value={data.category_id}
                                        onChange={e => setData('category_id', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all bg-white"
                                        required
                                    >
                                        <option value="">Select Category</option>
                                        {categories.map(c => (
                                            <option key={c.id} value={c.id}>{c.name}</option>
                                        ))}
                                    </select>
                                    {errors.category_id && <p className="text-red-500 text-xs mt-1">{errors.category_id}</p>}
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Sale Price ($)</label>
                                    <input
                                        type="number"
                                        step="0.01"
                                        min="0"
                                        value={data.price}
                                        onChange={e => setData('price', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        required
                                    />
                                    {errors.price && <p className="text-red-500 text-xs mt-1">{errors.price}</p>}
                                </div>

                                {!data.is_deal && (
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-1">Cost Price ($)</label>
                                        <input
                                            type="number"
                                            step="0.01"
                                            min="0"
                                            value={data.cost_price}
                                            onChange={e => setData('cost_price', e.target.value)}
                                            className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500 outline-none transition-all"
                                            required={!data.is_deal}
                                        />
                                        {errors.cost_price && <p className="text-red-500 text-xs mt-1">{errors.cost_price}</p>}
                                    </div>
                                )}

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Initial Stock</label>
                                    <input
                                        type="number"
                                        min="0"
                                        value={data.stock_quantity}
                                        onChange={e => setData('stock_quantity', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        required
                                    />
                                    {errors.stock_quantity && <p className="text-red-500 text-xs mt-1">{errors.stock_quantity}</p>}
                                </div>

                                <div className="col-span-2">
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Description (Optional)</label>
                                    <textarea
                                        value={data.description}
                                        onChange={e => setData('description', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        rows="2"
                                    ></textarea>
                                </div>

                                {data.is_deal ? (
                                    <div className="col-span-2 border-t border-gray-100 pt-4 mt-2">
                                        <div className="flex justify-between items-center mb-2">
                                            <label className="block text-sm font-medium text-gray-700">Deal Builder / Included Items</label>
                                            <button type="button" onClick={addDealItem} className="text-xs bg-purple-50 text-purple-600 px-2 py-1 rounded-md hover:bg-purple-100 flex items-center gap-1 font-medium">
                                                <Plus className="w-3 h-3" /> Add Item
                                            </button>
                                        </div>
                                        <p className="text-xs text-gray-500 mb-3">Select the menu items included in this deal. The system will automatically calculate the total cost price.</p>
                                        
                                        <div className="space-y-2">
                                            {data.dealItems.map((di, index) => (
                                                <div key={index} className="flex gap-2 items-center bg-gray-50 p-2 rounded-lg border border-gray-100">
                                                    <select
                                                        value={di.id}
                                                        onChange={e => updateDealItem(index, 'id', e.target.value)}
                                                        className="flex-1 px-3 py-1.5 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500/20 outline-none"
                                                        required
                                                    >
                                                        <option value="">Select Menu Item</option>
                                                        {menuItems.filter(m => !m.is_deal && m.id !== editingItemId).map(m => (
                                                            <option key={m.id} value={m.id}>{m.name} (${m.price})</option>
                                                        ))}
                                                    </select>
                                                    <input
                                                        type="number"
                                                        min="1"
                                                        value={di.quantity}
                                                        onChange={e => updateDealItem(index, 'quantity', e.target.value)}
                                                        className="w-24 px-3 py-1.5 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500/20 outline-none"
                                                        placeholder="Qty"
                                                        required
                                                    />
                                                    <button type="button" onClick={() => removeDealItem(index)} className="p-1.5 text-red-500 hover:bg-red-50 rounded-md">
                                                        <X className="w-4 h-4" />
                                                    </button>
                                                </div>
                                            ))}
                                            {data.dealItems.length === 0 && (
                                                <div className="text-center py-4 bg-gray-50 border border-dashed border-gray-200 rounded-xl text-sm text-gray-500">
                                                    No items added to deal.
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                ) : (
                                    <div className="col-span-2 border-t border-gray-100 pt-4 mt-2">
                                        <div className="flex justify-between items-center mb-2">
                                            <label className="block text-sm font-medium text-gray-700">Recipe / Ingredients (Optional)</label>
                                            <button type="button" onClick={addIngredient} className="text-xs bg-blue-50 text-blue-600 px-2 py-1 rounded-md hover:bg-blue-100 flex items-center gap-1 font-medium">
                                                <Plus className="w-3 h-3" /> Add Ingredient
                                            </button>
                                        </div>
                                        <p className="text-xs text-gray-500 mb-3">If added, raw materials will automatically deduct from Inventory when this item is sold.</p>
                                        
                                        <div className="space-y-2">
                                            {data.ingredients.map((ing, index) => (
                                                <div key={index} className="flex gap-2 items-center bg-gray-50 p-2 rounded-lg border border-gray-100">
                                                    <select
                                                        value={ing.id}
                                                        onChange={e => updateIngredient(index, 'id', e.target.value)}
                                                        className="flex-1 px-3 py-1.5 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary/20 outline-none"
                                                        required
                                                    >
                                                        <option value="">Select Material</option>
                                                        {inventory.map(inv => (
                                                            <option key={inv.id} value={inv.id}>{inv.name} ({inv.unit})</option>
                                                        ))}
                                                    </select>
                                                    <input
                                                        type="number"
                                                        step="0.0001"
                                                        min="0.0001"
                                                        value={ing.quantity}
                                                        onChange={e => updateIngredient(index, 'quantity', e.target.value)}
                                                        className="w-24 px-3 py-1.5 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary/20 outline-none"
                                                        placeholder="Qty"
                                                        required
                                                    />
                                                    <span className="text-xs text-gray-500 w-10">
                                                        {ing.id ? inventory.find(i => i.id == ing.id)?.unit : ''}
                                                    </span>
                                                    <button type="button" onClick={() => removeIngredient(index)} className="p-1.5 text-red-500 hover:bg-red-50 rounded-md">
                                                        <X className="w-4 h-4" />
                                                    </button>
                                                </div>
                                            ))}
                                            {data.ingredients.length === 0 && (
                                                <div className="text-center py-4 bg-gray-50 border border-dashed border-gray-200 rounded-xl text-sm text-gray-500">
                                                    No recipe defined.
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                )}

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
