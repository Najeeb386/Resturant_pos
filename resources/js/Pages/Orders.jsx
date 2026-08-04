import React, { useState, useRef, useEffect } from 'react';
import AdminLayout from '../Layouts/AdminLayout';
import { Card, CardContent } from '../Components/ui/Card';
import { Badge } from '../Components/ui/Badge';
import { Button } from '../Components/ui/Button';
import { 
    Check, X, Search, MapPin, Phone, Banknote, Loader2, 
    Eye, Pencil, XCircle, Printer, FileText, ChevronDown,
    Plus, Minus, Trash2, ShoppingBag 
} from 'lucide-react';
import { useForm, router } from '@inertiajs/react';
import { SwalConfirm, SwalToast } from '../Utils/swal';

export default function Orders({ 
    orders = { data: [] }, 
    menu_items = [], 
    tax_percentage = 0,
    kitchen_bypass = false, 
    currency_symbol = '$' 
}) {
    const [filter, setFilter] = useState('all'); // all | pending_cod | completed | cancelled
    const [processingId, setProcessingId] = useState(null);
    const [viewOrder, setViewOrder] = useState(null);
    const [editOrder, setEditOrder] = useState(null);
    const [editItems, setEditItems] = useState([]);
    const [searchQuery, setSearchQuery] = useState('');
    const [isDropdownOpen, setIsDropdownOpen] = useState(false);
    const [isSaving, setIsSaving] = useState(false);
    const [printMenuId, setPrintMenuId] = useState(null);

    const dropdownRef = useRef(null);

    // Close searchable dropdown on outside click
    useEffect(() => {
        const handleClickOutside = (e) => {
            if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
                setIsDropdownOpen(false);
            }
        };
        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
    }, []);

    const { data, setData, put, processing, errors, reset } = useForm({
        customer_name: '',
        customer_phone: '',
        delivery_address: '',
        status: 'pending',
        payment_status: 'unpaid',
        notes: '',
        items: [],
    });

    const openEditModal = (order) => {
        setEditOrder(order);
        const itemsCopy = (order.items || []).map(item => ({
            menu_item_id: item.menu_item_id,
            name: item.name,
            price: Number(item.price),
            qty: Number(item.qty)
        }));
        setEditItems(itemsCopy);
        setSearchQuery('');
        setIsDropdownOpen(false);
        setIsSaving(false);
        setData({
            customer_name: order.customer_name || '',
            customer_phone: order.customer_phone || '',
            delivery_address: order.delivery_address || '',
            status: order.status || 'pending',
            payment_status: order.payment_status || 'unpaid',
            notes: order.notes || '',
            items: itemsCopy,
        });
    };

    const updateItemQty = (index, delta) => {
        const updated = [...editItems];
        const newQty = updated[index].qty + delta;
        if (newQty <= 0) {
            updated.splice(index, 1);
        } else {
            updated[index].qty = newQty;
        }
        setEditItems(updated);
    };

    const removeItem = (index) => {
        const updated = editItems.filter((_, i) => i !== index);
        setEditItems(updated);
    };

    const handleSelectMenuItem = (menuItem) => {
        const existingIndex = editItems.findIndex(i => i.menu_item_id === menuItem.id);
        if (existingIndex > -1) {
            const updated = [...editItems];
            updated[existingIndex].qty += 1;
            setEditItems(updated);
        } else {
            setEditItems([
                ...editItems,
                {
                    menu_item_id: menuItem.id,
                    name: menuItem.name,
                    price: Number(menuItem.price),
                    qty: 1
                }
            ]);
        }
        setSearchQuery('');
        setIsDropdownOpen(false);
    };

    const filteredMenuItems = menu_items.filter(item => 
        item.name.toLowerCase().includes(searchQuery.toLowerCase())
    );

    // Recalculate summary in real-time
    const calculatedSubtotal = editItems.reduce((sum, item) => sum + (item.price * item.qty), 0);
    const calculatedTax = (calculatedSubtotal * tax_percentage) / 100;
    const deliveryFee = Number(editOrder?.delivery_fee || 0);
    const discount = Number(editOrder?.discount || 0);
    const calculatedTotal = Math.max(0, calculatedSubtotal + calculatedTax + deliveryFee - discount);

    const handleEditSubmit = (e) => {
        e.preventDefault();
        if (!editOrder || isSaving) return;

        if (editItems.length === 0) {
            alert('An order must contain at least 1 item.');
            return;
        }

        setIsSaving(true);
        router.put(`/orders/${editOrder.id}`, {
            customer_name: data.customer_name,
            customer_phone: data.customer_phone,
            delivery_address: data.delivery_address,
            status: data.status,
            payment_status: data.payment_status,
            notes: data.notes,
            items: editItems,
        }, {
            preserveScroll: true,
            onSuccess: () => {
                setEditOrder(null);
                reset();
            },
            onFinish: () => {
                setIsSaving(false);
            }
        });
    };

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
                
                <div className="flex flex-wrap sm:flex-nowrap bg-white rounded-xl shadow-sm border border-gray-100 p-1 w-full sm:w-auto gap-1">
                    <button 
                        className={`flex-1 sm:flex-initial px-3 sm:px-4 py-2 rounded-lg text-xs sm:text-sm font-medium transition-colors text-center ${filter === 'all' ? 'bg-primary text-white shadow-sm' : 'text-gray-600 hover:bg-gray-50'}`}
                        onClick={() => setFilter('all')}
                    >
                        All Orders
                    </button>
                    <button 
                        className={`flex-1 sm:flex-initial px-3 sm:px-4 py-2 rounded-lg text-xs sm:text-sm font-medium transition-colors text-center ${filter === 'pending_cod' ? 'bg-amber-500 text-white shadow-sm' : 'text-gray-600 hover:bg-gray-50'}`}
                        onClick={() => setFilter('pending_cod')}
                    >
                        Pending COD
                    </button>
                    <button 
                        className={`flex-1 sm:flex-initial px-3 sm:px-4 py-2 rounded-lg text-xs sm:text-sm font-medium transition-colors text-center ${filter === 'completed' ? 'bg-emerald-500 text-white shadow-sm' : 'text-gray-600 hover:bg-gray-50'}`}
                        onClick={() => setFilter('completed')}
                    >
                        Completed
                    </button>
                    <button 
                        className={`flex-1 sm:flex-initial px-3 sm:px-4 py-2 rounded-lg text-xs sm:text-sm font-medium transition-colors text-center ${filter === 'cancelled' ? 'bg-red-500 text-white shadow-sm' : 'text-gray-600 hover:bg-gray-50'}`}
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
                                        <div className="font-bold text-lg text-gray-900">{currency_symbol}{order.total.toFixed(2)}</div>
                                        {order.delivery_fee > 0 && (
                                            <div className="text-[10px] text-gray-500">Includes {currency_symbol}{order.delivery_fee.toFixed(2)} fee</div>
                                        )}
                                    </td>
                                    <td className="p-4 align-top">
                                        <div className="flex flex-col gap-2 items-center min-w-[140px]">
                                            {/* Action Buttons Row */}
                                            <div className="flex items-center gap-1.5">
                                                <button
                                                    onClick={() => setViewOrder(order)}
                                                    title="View Details"
                                                    className="p-2 rounded-lg bg-gray-100 hover:bg-gray-200 text-gray-700 transition-colors"
                                                >
                                                    <Eye className="w-4 h-4" />
                                                </button>
                                                
                                                <button
                                                    onClick={() => openEditModal(order)}
                                                    title="Edit Order"
                                                    className="p-2 rounded-lg bg-blue-50 hover:bg-blue-100 text-blue-600 transition-colors"
                                                >
                                                    <Pencil className="w-4 h-4" />
                                                </button>

                                                {order.status !== 'cancelled' && (
                                                    <button
                                                        onClick={() => updateStatus(order.id, 'cancelled')}
                                                        disabled={processingId === `status-${order.id}`}
                                                        title="Cancel Order"
                                                        className="p-2 rounded-lg bg-red-50 hover:bg-red-100 text-red-600 transition-colors disabled:opacity-50"
                                                    >
                                                        {processingId === `status-${order.id}` ? (
                                                            <Loader2 className="w-4 h-4 animate-spin" />
                                                        ) : (
                                                            <XCircle className="w-4 h-4" />
                                                        )}
                                                    </button>
                                                )}

                                                <div className="relative">
                                                    <button
                                                        onClick={() => setPrintMenuId(printMenuId === order.id ? null : order.id)}
                                                        title="Print Options"
                                                        className="p-2 rounded-lg bg-emerald-50 hover:bg-emerald-100 text-emerald-600 transition-colors flex items-center gap-0.5"
                                                    >
                                                        <Printer className="w-4 h-4" />
                                                        <ChevronDown className="w-3 h-3" />
                                                    </button>

                                                    {printMenuId === order.id && (
                                                        <div className="absolute right-0 mt-1 w-36 bg-white border border-gray-100 rounded-xl shadow-lg z-20 py-1 text-xs">
                                                            <a
                                                                href={`/orders/${order.id}/receipt`}
                                                                target="_blank"
                                                                rel="noopener noreferrer"
                                                                className="flex items-center gap-2 px-3 py-2 hover:bg-gray-50 text-gray-700"
                                                                onClick={() => setPrintMenuId(null)}
                                                            >
                                                                <FileText className="w-3.5 h-3.5 text-blue-500" /> Receipt
                                                            </a>
                                                            <a
                                                                href={`/orders/${order.id}/kot`}
                                                                target="_blank"
                                                                rel="noopener noreferrer"
                                                                className="flex items-center gap-2 px-3 py-2 hover:bg-gray-50 text-gray-700"
                                                                onClick={() => setPrintMenuId(null)}
                                                            >
                                                                <FileText className="w-3.5 h-3.5 text-orange-500" /> KOT
                                                            </a>
                                                            <a
                                                                href={`/orders/${order.id}/both`}
                                                                target="_blank"
                                                                rel="noopener noreferrer"
                                                                className="flex items-center gap-2 px-3 py-2 hover:bg-gray-50 text-gray-700"
                                                                onClick={() => setPrintMenuId(null)}
                                                            >
                                                                <FileText className="w-3.5 h-3.5 text-emerald-500" /> Both
                                                            </a>
                                                        </div>
                                                    )}
                                                </div>
                                            </div>

                                            {/* Status / Quick Action Buttons */}
                                            {order.payment_status === 'unpaid' && order.status !== 'cancelled' && (
                                                <Button 
                                                    size="sm" 
                                                    className="w-full bg-emerald-500 hover:bg-emerald-600 text-white flex items-center justify-center gap-1 text-xs py-1"
                                                    onClick={() => updatePayment(order.id, 'paid')}
                                                    disabled={processingId === `payment-${order.id}`}
                                                >
                                                    {processingId === `payment-${order.id}` ? <Loader2 className="w-3 h-3 animate-spin" /> : <Banknote className="w-3 h-3" />}
                                                    Mark Paid
                                                </Button>
                                            )}

                                            {kitchen_bypass && order.status === 'pending' && (
                                                <Button 
                                                    size="sm" 
                                                    className="w-full bg-orange-500 hover:bg-orange-600 text-white flex items-center justify-center gap-1 text-xs py-1"
                                                    onClick={() => updateStatus(order.id, 'preparing')}
                                                    disabled={processingId === `status-${order.id}`}
                                                >
                                                    {processingId === `status-${order.id}` ? <Loader2 className="w-3 h-3 animate-spin" /> : <Check className="w-3 h-3" />}
                                                    Prepare
                                                </Button>
                                            )}

                                            {kitchen_bypass && order.status === 'preparing' && (
                                                <Button 
                                                    size="sm" 
                                                    className="w-full bg-blue-500 hover:bg-blue-600 text-white flex items-center justify-center gap-1 text-xs py-1"
                                                    onClick={() => updateStatus(order.id, 'completed')}
                                                    disabled={processingId === `status-${order.id}`}
                                                >
                                                    {processingId === `status-${order.id}` ? <Loader2 className="w-3 h-3 animate-spin" /> : <Check className="w-3 h-3" />}
                                                    Complete
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

            {/* View Details Modal */}
            {viewOrder && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl relative max-h-[90vh] overflow-y-auto">
                        <button 
                            onClick={() => setViewOrder(null)}
                            className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 p-1"
                        >
                            <X className="w-5 h-5" />
                        </button>

                        <div className="flex items-center justify-between mb-4 pb-3 border-b border-gray-100">
                            <div>
                                <h2 className="text-xl font-bold text-gray-900">Order #{viewOrder.id}</h2>
                                <p className="text-xs text-gray-500">{viewOrder.created_at}</p>
                            </div>
                            <Badge variant="outline" className="capitalize text-xs">
                                {viewOrder.order_type.replace('_', ' ')}
                            </Badge>
                        </div>

                        {/* Customer Details */}
                        <div className="bg-gray-50 rounded-xl p-3 mb-4 space-y-1 text-sm">
                            <div className="font-semibold text-gray-800">{viewOrder.customer_name || 'Walk-in Customer'}</div>
                            {viewOrder.customer_phone && <div className="text-xs text-gray-600">Phone: {viewOrder.customer_phone}</div>}
                            {viewOrder.delivery_address && <div className="text-xs text-gray-600">Address: {viewOrder.delivery_address}</div>}
                            {viewOrder.table_number && <div className="text-xs text-gray-600">Table: #{viewOrder.table_number}</div>}
                        </div>

                        {/* Order Items */}
                        <div className="mb-4">
                            <h3 className="text-xs font-bold uppercase text-gray-400 mb-2">Order Items</h3>
                            <div className="divide-y divide-gray-100 border border-gray-100 rounded-xl overflow-hidden">
                                {viewOrder.items.map((item, i) => (
                                    <div key={i} className="p-3 flex justify-between items-center text-sm">
                                        <div>
                                            <span className="font-medium text-gray-800">{item.name}</span>
                                            <span className="text-xs text-gray-500 block">Qty: {item.qty} × {currency_symbol}{item.price.toFixed(2)}</span>
                                        </div>
                                        <div className="font-bold text-gray-900">
                                            {currency_symbol}{(item.qty * item.price).toFixed(2)}
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>

                        {/* Summary breakdown */}
                        <div className="space-y-1.5 text-sm mb-4 bg-gray-50 p-3 rounded-xl">
                            <div className="flex justify-between text-gray-600">
                                <span>Subtotal</span>
                                <span>{currency_symbol}{viewOrder.subtotal?.toFixed(2) || '0.00'}</span>
                            </div>
                            {viewOrder.tax > 0 && (
                                <div className="flex justify-between text-gray-600">
                                    <span>Tax</span>
                                    <span>{currency_symbol}{viewOrder.tax.toFixed(2)}</span>
                                </div>
                            )}
                            {viewOrder.discount > 0 && (
                                <div className="flex justify-between text-emerald-600">
                                    <span>Discount</span>
                                    <span>-{currency_symbol}{viewOrder.discount.toFixed(2)}</span>
                                </div>
                            )}
                            {viewOrder.delivery_fee > 0 && (
                                <div className="flex justify-between text-gray-600">
                                    <span>Delivery Fee</span>
                                    <span>{currency_symbol}{viewOrder.delivery_fee.toFixed(2)}</span>
                                </div>
                            )}
                            <div className="flex justify-between font-bold text-base text-gray-900 pt-2 border-t border-gray-200">
                                <span>Total</span>
                                <span>{currency_symbol}{viewOrder.total.toFixed(2)}</span>
                            </div>
                        </div>

                        {viewOrder.notes && (
                            <div className="mb-4 text-xs bg-amber-50 text-amber-800 p-2.5 rounded-lg">
                                <strong>Notes:</strong> {viewOrder.notes}
                            </div>
                        )}

                        {/* Footer Buttons */}
                        <div className="flex flex-wrap gap-2 pt-2 border-t border-gray-100 justify-end">
                            <a
                                href={`/orders/${viewOrder.id}/receipt`}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="px-3 py-1.5 rounded-lg bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-medium flex items-center gap-1"
                            >
                                <Printer className="w-3.5 h-3.5" /> Receipt
                            </a>
                            <a
                                href={`/orders/${viewOrder.id}/kot`}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="px-3 py-1.5 rounded-lg bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-medium flex items-center gap-1"
                            >
                                <Printer className="w-3.5 h-3.5" /> KOT
                            </a>
                            <Button
                                size="sm"
                                variant="outline"
                                onClick={() => setViewOrder(null)}
                            >
                                Close
                            </Button>
                        </div>
                    </div>
                </div>
            )}

            {/* Edit Order Modal */}
            {editOrder && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl relative max-h-[90vh] overflow-y-auto">
                        <button 
                            onClick={() => setEditOrder(null)}
                            className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 p-1"
                        >
                            <X className="w-5 h-5" />
                        </button>

                        <h2 className="text-xl font-bold text-gray-900 mb-4">Edit Order #{editOrder.id}</h2>

                        <form onSubmit={handleEditSubmit} className="space-y-4">
                            {/* Customer Details */}
                            <div className="grid grid-cols-2 gap-3">
                                <div>
                                    <label className="block text-xs font-semibold text-gray-700 mb-1">Customer Name</label>
                                    <input
                                        type="text"
                                        value={data.customer_name}
                                        onChange={(e) => setData('customer_name', e.target.value)}
                                        className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                                    />
                                </div>

                                <div>
                                    <label className="block text-xs font-semibold text-gray-700 mb-1">Customer Phone</label>
                                    <input
                                        type="text"
                                        value={data.customer_phone}
                                        onChange={(e) => setData('customer_phone', e.target.value)}
                                        className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                                    />
                                </div>
                            </div>

                            {editOrder.order_type === 'delivery' && (
                                <div>
                                    <label className="block text-xs font-semibold text-gray-700 mb-1">Delivery Address</label>
                                    <textarea
                                        rows="2"
                                        value={data.delivery_address}
                                        onChange={(e) => setData('delivery_address', e.target.value)}
                                        className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                                    />
                                </div>
                            )}

                            <div className="grid grid-cols-2 gap-3">
                                <div>
                                    <label className="block text-xs font-semibold text-gray-700 mb-1">Order Status</label>
                                    <select
                                        value={data.status}
                                        onChange={(e) => setData('status', e.target.value)}
                                        className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                                    >
                                        <option value="pending">Pending</option>
                                        <option value="preparing">Preparing</option>
                                        <option value="completed">Completed</option>
                                        <option value="cancelled">Cancelled</option>
                                    </select>
                                </div>

                                <div>
                                    <label className="block text-xs font-semibold text-gray-700 mb-1">Payment Status</label>
                                    <select
                                        value={data.payment_status}
                                        onChange={(e) => setData('payment_status', e.target.value)}
                                        className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                                    >
                                        <option value="unpaid">Unpaid</option>
                                        <option value="paid">Paid</option>
                                    </select>
                                </div>
                            </div>

                            {/* Order Items Editor */}
                            <div className="pt-2 border-t border-gray-100">
                                <div className="flex justify-between items-center mb-2">
                                    <label className="block text-xs font-bold uppercase tracking-wider text-gray-500">
                                        Order Items ({editItems.length})
                                    </label>
                                </div>

                                {/* Item List */}
                                <div className="space-y-2 mb-3 max-h-48 overflow-y-auto border border-gray-100 rounded-xl p-2 bg-gray-50/50">
                                    {editItems.length === 0 ? (
                                        <div className="text-center py-4 text-xs text-gray-400">
                                            No items in order. Add items below.
                                        </div>
                                    ) : editItems.map((item, idx) => (
                                        <div key={idx} className="flex items-center justify-between bg-white p-2.5 rounded-lg border border-gray-100 shadow-2xs">
                                            <div className="flex-1 min-w-0 pr-2">
                                                <div className="text-sm font-semibold text-gray-800 truncate">{item.name}</div>
                                                <div className="text-xs text-gray-500">{currency_symbol}{item.price.toFixed(2)} each</div>
                                            </div>

                                            {/* Qty Stepper */}
                                            <div className="flex items-center gap-1 bg-gray-50 rounded-lg p-1 mr-3 border border-gray-200">
                                                <button
                                                    type="button"
                                                    onClick={() => updateItemQty(idx, -1)}
                                                    className="w-6 h-6 rounded bg-white hover:bg-gray-100 text-gray-600 flex items-center justify-center font-bold text-xs shadow-2xs"
                                                >
                                                    <Minus className="w-3 h-3" />
                                                </button>
                                                <span className="w-6 text-center font-bold text-xs text-gray-800">{item.qty}</span>
                                                <button
                                                    type="button"
                                                    onClick={() => updateItemQty(idx, 1)}
                                                    className="w-6 h-6 rounded bg-white hover:bg-gray-100 text-gray-600 flex items-center justify-center font-bold text-xs shadow-2xs"
                                                >
                                                    <Plus className="w-3 h-3" />
                                                </button>
                                            </div>

                                            {/* Item Line Total */}
                                            <div className="text-sm font-bold text-gray-900 mr-2 min-w-[60px] text-right">
                                                {currency_symbol}{(item.price * item.qty).toFixed(2)}
                                            </div>

                                            {/* Remove Button */}
                                            <button
                                                type="button"
                                                onClick={() => removeItem(idx)}
                                                className="p-1 rounded text-red-500 hover:text-red-700 hover:bg-red-50 transition-colors"
                                                title="Remove Item"
                                            >
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                        </div>
                                    ))}
                                </div>

                                {/* Searchable Add New Item Input & Dropdown */}
                                <div className="relative" ref={dropdownRef}>
                                    <div className="relative flex items-center">
                                        <Search className="w-4 h-4 absolute left-3 text-gray-400 pointer-events-none" />
                                        <input
                                            type="text"
                                            value={searchQuery}
                                            onChange={(e) => {
                                                setSearchQuery(e.target.value);
                                                setIsDropdownOpen(true);
                                            }}
                                            onFocus={() => setIsDropdownOpen(true)}
                                            placeholder="Search & click to add menu item..."
                                            className="w-full pl-9 pr-8 py-2 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary bg-white"
                                        />
                                        {searchQuery && (
                                            <button
                                                type="button"
                                                onClick={() => setSearchQuery('')}
                                                className="absolute right-2 text-gray-400 hover:text-gray-600 p-0.5"
                                            >
                                                <X className="w-3.5 h-3.5" />
                                            </button>
                                        )}
                                    </div>

                                    {isDropdownOpen && (
                                        <div className="absolute left-0 right-0 mt-1 max-h-52 overflow-y-auto bg-white border border-gray-200 rounded-xl shadow-xl z-30 divide-y divide-gray-50">
                                            {filteredMenuItems.length === 0 ? (
                                                <div className="p-3 text-xs text-gray-400 text-center">
                                                    No menu items match "{searchQuery}"
                                                </div>
                                            ) : (
                                                filteredMenuItems.map(item => (
                                                    <button
                                                        key={item.id}
                                                        type="button"
                                                        onClick={() => handleSelectMenuItem(item)}
                                                        className="w-full px-3.5 py-2.5 text-left hover:bg-emerald-50/80 flex justify-between items-center text-xs transition-colors group"
                                                    >
                                                        <span className="font-medium text-gray-800 group-hover:text-emerald-900">{item.name}</span>
                                                        <div className="flex items-center gap-1.5">
                                                            <span className="font-semibold text-emerald-600">{currency_symbol}{Number(item.price).toFixed(2)}</span>
                                                            <Plus className="w-3.5 h-3.5 text-emerald-500 opacity-0 group-hover:opacity-100 transition-opacity" />
                                                        </div>
                                                    </button>
                                                ))
                                            )}
                                        </div>
                                    )}
                                </div>
                            </div>

                            {/* Live Summary Calculation */}
                            <div className="bg-gray-50 p-3 rounded-xl space-y-1 text-xs">
                                <div className="flex justify-between text-gray-600">
                                    <span>Subtotal</span>
                                    <span>{currency_symbol}{calculatedSubtotal.toFixed(2)}</span>
                                </div>
                                {tax_percentage > 0 && (
                                    <div className="flex justify-between text-gray-600">
                                        <span>Tax ({tax_percentage}%)</span>
                                        <span>{currency_symbol}{calculatedTax.toFixed(2)}</span>
                                    </div>
                                )}
                                {deliveryFee > 0 && (
                                    <div className="flex justify-between text-gray-600">
                                        <span>Delivery Fee</span>
                                        <span>{currency_symbol}{deliveryFee.toFixed(2)}</span>
                                    </div>
                                )}
                                {discount > 0 && (
                                    <div className="flex justify-between text-emerald-600">
                                        <span>Discount</span>
                                        <span>-{currency_symbol}{discount.toFixed(2)}</span>
                                    </div>
                                )}
                                <div className="flex justify-between font-bold text-sm text-gray-900 pt-1.5 border-t border-gray-200">
                                    <span>Updated Total</span>
                                    <span className="text-primary">{currency_symbol}{calculatedTotal.toFixed(2)}</span>
                                </div>
                            </div>

                            <div>
                                <label className="block text-xs font-semibold text-gray-700 mb-1">Order Notes</label>
                                <textarea
                                    rows="2"
                                    value={data.notes}
                                    onChange={(e) => setData('notes', e.target.value)}
                                    placeholder="Add any internal order notes..."
                                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                                />
                            </div>

                            <div className="flex justify-end gap-2 pt-2 border-t border-gray-100">
                                <Button
                                    type="button"
                                    variant="outline"
                                    disabled={isSaving}
                                    onClick={() => setEditOrder(null)}
                                >
                                    Cancel
                                </Button>
                                <Button
                                    type="submit"
                                    disabled={isSaving}
                                    className="bg-primary hover:bg-primary/90 text-white min-w-[130px] flex items-center justify-center gap-1.5"
                                >
                                    {isSaving ? (
                                        <>
                                            <Loader2 className="w-4 h-4 animate-spin" />
                                            <span>Saving...</span>
                                        </>
                                    ) : (
                                        <span>Save Changes</span>
                                    )}
                                </Button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Pagination placeholder */}
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
