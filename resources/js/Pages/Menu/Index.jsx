import React from 'react';
import AdminLayout from '../../Layouts/AdminLayout';
import { Card, CardContent } from '../../Components/ui/Card';
import { Badge } from '../../Components/ui/Badge';
import { Button } from '../../Components/ui/Button';
import { Plus, Edit, Trash2 } from 'lucide-react';

const menuItems = [
    { id: 1, name: 'Classic Beef Burger', price: 8.99, category: 'Burgers', status: 'available' },
    { id: 2, name: 'Double Cheese Burger', price: 10.99, category: 'Burgers', status: 'available' },
    { id: 3, name: 'Margherita Pizza', price: 12.50, category: 'Pizzas', status: 'out_of_stock' },
    { id: 5, name: 'Coca Cola', price: 2.50, category: 'Drinks', status: 'available' },
    { id: 7, name: 'Chocolate Sundae', price: 5.50, category: 'Desserts', status: 'available' },
];

export default function Menu() {
    return (
        <AdminLayout>
            <div className="mb-6 flex justify-between items-end">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 mb-1">Menu Management</h1>
                    <p className="text-gray-500">Manage your menu items, categories, and pricing.</p>
                </div>
                <Button className="shadow-lg shadow-primary/20">
                    <Plus className="w-5 h-5 mr-2" />
                    Add New Item
                </Button>
            </div>

            <Card>
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-gray-50 border-b border-gray-100">
                                    <th className="py-4 px-6 font-semibold text-gray-600 text-sm uppercase tracking-wider">Item Name</th>
                                    <th className="py-4 px-6 font-semibold text-gray-600 text-sm uppercase tracking-wider">Category</th>
                                    <th className="py-4 px-6 font-semibold text-gray-600 text-sm uppercase tracking-wider">Price</th>
                                    <th className="py-4 px-6 font-semibold text-gray-600 text-sm uppercase tracking-wider">Status</th>
                                    <th className="py-4 px-6 font-semibold text-gray-600 text-sm uppercase tracking-wider text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-50">
                                {menuItems.map(item => (
                                    <tr key={item.id} className="hover:bg-gray-50/50 transition-colors">
                                        <td className="py-4 px-6 font-medium text-gray-900">{item.name}</td>
                                        <td className="py-4 px-6 text-gray-500">{item.category}</td>
                                        <td className="py-4 px-6 font-bold text-primary">${item.price.toFixed(2)}</td>
                                        <td className="py-4 px-6">
                                            <Badge variant={item.status === 'available' ? 'success' : 'danger'}>
                                                {item.status.replace('_', ' ')}
                                            </Badge>
                                        </td>
                                        <td className="py-4 px-6 text-right">
                                            <div className="flex justify-end gap-2">
                                                <Button variant="ghost" size="icon" className="text-blue-500 hover:bg-blue-50 hover:text-blue-600">
                                                    <Edit className="w-4 h-4" />
                                                </Button>
                                                <Button variant="ghost" size="icon" className="text-red-500 hover:bg-red-50 hover:text-red-600">
                                                    <Trash2 className="w-4 h-4" />
                                                </Button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>
        </AdminLayout>
    );
}
