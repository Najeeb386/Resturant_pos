import React, { useState } from 'react';
import AdminLayout from '../Layouts/AdminLayout';
import { Card, CardContent } from '../Components/ui/Card';
import { Badge } from '../Components/ui/Badge';
import { Button } from '../Components/ui/Button';
import { Check, X, Search, MapPin, Phone, Banknote, Loader2 } from 'lucide-react';
import { useForm, router } from '@inertiajs/react';

export default function Orders({ orders = { data: [] } }) {
    const [filter, setFilter] = useState('all'); // all | pending_cod | completed | cancelled
    const [processingId, setProcessingId] = useState(null);

    const updatePayment = (id, newStatus) => {
        if (!confirm('Are you sure you want to mark this order as ' + newStatus + '?')) return;
        setProcessingId(`payment-${id}`);
        router.post(`/orders/${id}/payment-status`, { payment_status: newStatus }, {
            preserveScroll: true,
            onFinish: () => setProcessingId(null)
        });
    };

    const updateStatus = (id, newStatus) => {
        if (!confirm('Are you sure you want to mark this order as ' + newStatus + '?')) return;
        setProcessingId(`status-${id}`);
        router.post(`/orders/${id}/status`, { status: newStatus }, {
            preserveScroll: true,
            onFinish: () => setProcessingId(null)
        });
    };

    const filteredOrders = orders.data.filter(order => {
        if (filter === 'all') return true;
        if (filter === 'pending_cod') return order.order_type === 'delivery' && order.payment_status === 'unpaid' && order.status !== 'cancelled';
        if (filter === 'completed') return order.status === 'completed';
        if (filter === 'cancelled') return order.status === 'cancelled';
        return true;
    });

    return (
        <AdminLayout>
            <div className="mb-6 flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 mb-1">Orders & Deliveries</h1>
                    <p className="text-gray-500">Track order history, manage deliveries, and update COD payment status.</p>
                </div>
                
                <div className="flex bg-white rounded-xl shadow-sm border border-gray-100 p-1">
                    <button 
                        className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${filter === 'all' ? 'bg-primary text-white shadow-sm' : 'text-gray-600 hover:bg-gray-50'}`}
                        onClick={() => setFilter('all')}
                    >
                        All Orders
                    </button>
                    <button 
                        className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${filter === 'pending_cod' ? 'bg-amber-500 text-white shadow-sm' : 'text-gray-600 hover:bg-gray-50'}`}
                        onClick={() => setFilter('pending_cod')}
                    >
                        Pending COD Deliveries
                    </button>
                    <button 
                        className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${filter === 'completed' ? 'bg-emerald-500 text-white shadow-sm' : 'text-gray-600 hover:bg-gray-50'}`}
                        onClick={() => setFilter('completed')}
                    >
                        Completed
                    </button>
                    <button 
                        className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${filter === 'cancelled' ? 'bg-red-500 text-white shadow-sm' : 'text-gray-600 hover:bg-gray-50'}`}
                        onClick={() => setFilter('cancelled')}
                    >
                        Cancelled
                    </button>
                </div>
            </div>

            <Card>
                <CardContent className="p-0 overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-gray-50 border-b border-gray-100">
                                <th className="p-4 font-semibold text-gray-600 text-sm">Order ID & Date</th>
                                <th className="p-4 font-semibold text-gray-600 text-sm">Customer Details</th>
                                <th className="p-4 font-semibold text-gray-600 text-sm">Type & Items</th>
                                <th className="p-4 font-semibold text-gray-600 text-sm">Status</th>
                                <th className="p-4 font-semibold text-gray-600 text-sm text-right">Total</th>
                                <th className="p-4 font-semibold text-gray-600 text-sm text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {filteredOrders.length === 0 ? (
                                <tr>
                                    <td colSpan="6" className="p-8 text-center text-gray-500">
                                        No orders found for this filter.
                                    </td>
                                </tr>
                            ) : filteredOrders.map(order => (
                                <tr key={order.id} className="hover:bg-gray-50/50 transition-colors">
                                    <td className="p-4 align-top">
                                        <div className="font-bold text-gray-900">#{order.id}</div>
                                        <div className="text-xs text-gray-500 mt-1">{order.created_at}</div>
                                    </td>
                                    <td className="p-4 align-top">
                                        <div className="font-medium text-gray-800">{order.customer_name || 'Walk-in'}</div>
                                        {order.order_type === 'delivery' && (
                                            <div className="mt-1 space-y-1">
                                                {order.customer_phone && (
                                                    <div className="flex items-center gap-1.5 text-xs text-gray-600">
                                                        <Phone className="w-3 h-3" /> {order.customer_phone}
                                                    </div>
                                                )}
                                                {order.delivery_address && (
                                                    <div className="flex items-start gap-1.5 text-xs text-gray-600 max-w-[200px]">
                                                        <MapPin className="w-3 h-3 mt-0.5 shrink-0" /> 
                                                        <span className="line-clamp-2">{order.delivery_address}</span>
                                                    </div>
                                                )}
                                            </div>
                                        )}
                                        {order.order_type === 'dine_in' && (
                                            <div className="mt-1 text-xs text-gray-600 font-medium">
                                                Table {order.table_number}
                                            </div>
                                        )}
                                    </td>
                                    <td className="p-4 align-top">
                                        <Badge variant="outline" className="mb-2 capitalize text-xs">
                                            {order.order_type.replace('_', ' ')}
                                        </Badge>
                                        <div className="text-xs text-gray-500 space-y-0.5 max-h-24 overflow-y-auto">
                                            {order.items.map((item, idx) => (
                                                <div key={idx}>{item.qty}x {item.name}</div>
                                            ))}
                                        </div>
                                    </td>
                                    <td className="p-4 align-top space-y-2">
                                        <div>
                                            <span className="block text-[10px] uppercase font-bold text-gray-400 mb-0.5">Order</span>
                                            <Badge variant={order.status === 'pending' ? 'danger' : order.status === 'preparing' ? 'warning' : order.status === 'completed' ? 'success' : 'secondary'}>
                                                {order.status}
                                            </Badge>
                                        </div>
                                        <div>
                                            <span className="block text-[10px] uppercase font-bold text-gray-400 mb-0.5">Payment</span>
                                            <Badge variant={order.payment_status === 'paid' ? 'success' : 'danger'}>
                                                {order.payment_status}
                                            </Badge>
                                        </div>
                                    </td>
                                    <td className="p-4 align-top text-right">
                                        <div className="font-bold text-lg text-gray-900">${order.total.toFixed(2)}</div>
                                        {order.delivery_fee > 0 && (
                                            <div className="text-[10px] text-gray-500">Includes ${order.delivery_fee.toFixed(2)} fee</div>
                                        )}
                                    </td>
                                    <td className="p-4 align-top">
                                        <div className="flex flex-col gap-2 items-center">
                                            {order.payment_status === 'unpaid' && order.status !== 'cancelled' && (
                                                <Button 
                                                    size="sm" 
                                                    className="w-28 bg-emerald-500 hover:bg-emerald-600 text-white flex items-center justify-center gap-1.5"
                                                    onClick={() => updatePayment(order.id, 'paid')}
                                                    disabled={processingId === `payment-${order.id}`}
                                                >
                                                    {processingId === `payment-${order.id}` ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Banknote className="w-3.5 h-3.5" />}
                                                    Mark Paid
                                                </Button>
                                            )}
                                            
                                            {order.status !== 'cancelled' && order.status !== 'completed' && (
                                                <Button 
                                                    size="sm" 
                                                    variant="outline"
                                                    className="w-28 text-red-600 hover:text-red-700 hover:bg-red-50 border-red-200"
                                                    onClick={() => updateStatus(order.id, 'cancelled')}
                                                    disabled={processingId === `status-${order.id}`}
                                                >
                                                    {processingId === `status-${order.id}` ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <X className="w-3.5 h-3.5" />}
                                                    Cancel
                                                </Button>
                                            )}
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </CardContent>
            </Card>

            {/* Pagination placeholder if needed */}
            {orders.links && orders.links.length > 3 && (
                <div className="mt-6 flex justify-center gap-1">
                    {orders.links.map((link, i) => (
                        <button
                            key={i}
                            onClick={() => link.url && router.visit(link.url, { preserveScroll: true })}
                            disabled={!link.url}
                            className={`px-3 py-1 rounded-md text-sm ${link.active ? 'bg-primary text-white' : 'bg-white border text-gray-600 hover:bg-gray-50'} ${!link.url ? 'opacity-50 cursor-not-allowed' : ''}`}
                            dangerouslySetInnerHTML={{ __html: link.label }}
                        />
                    ))}
                </div>
            )}
        </AdminLayout>
    );
}
