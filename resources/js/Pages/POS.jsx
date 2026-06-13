import React, { useState, useEffect } from 'react';
import AdminLayout from '../Layouts/AdminLayout';
import { Card, CardContent } from '../Components/ui/Card';
import { Button } from '../Components/ui/Button';
import { Search, ShoppingCart, Trash2, Plus, Minus, CreditCard, Banknote, QrCode, Printer, X, Loader2 } from 'lucide-react';
import { useForm, router, usePage } from '@inertiajs/react';

export default function POS({ categories = [], menuItems = [], tables = [], restaurant = {}, openBills = {}, flash = {}, allDrafts = [] }) {
    const { auth } = usePage().props;
    const isWaiter = auth?.user?.role_id === 4;

    const [activeCategory, setActiveCategory] = useState('All');
    const [cart, setCart] = useState([]);
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedTable, setSelectedTable] = useState('');
    const [orderType, setOrderType] = useState(isWaiter ? 'dine_in' : 'takeaway'); // takeaway | dine_in | delivery
    const [customerName, setCustomerName] = useState('');
    const [customerPhone, setCustomerPhone] = useState('');
    const [deliveryAddress, setDeliveryAddress] = useState('');
    const [deliveryFee, setDeliveryFee] = useState('');
    const [showReceipt, setShowReceipt] = useState(false);
    const [lastOrder, setLastOrder] = useState(null);
    const [currentOrderId, setCurrentOrderId] = useState(null);
    const [showDraftsModal, setShowDraftsModal] = useState(false);

    const { data, setData, post, processing, reset } = useForm({
        order_id: null,
        table_id: '',
        order_type: 'takeaway',
        customer_name: '',
        customer_phone: '',
        delivery_address: '',
        cart: [],
        subtotal: 0,
        tax: 0,
        delivery_fee: 0,
        total: 0,
        payment_method: 'Cash'
    });

    // Extract unique categories from menu items if no categories provided explicitly
    const displayCategories = ['All', ...categories.map(c => c.name)];

    const filteredMenu = menuItems.filter(item => {
        const categoryMatch = activeCategory === 'All' || item.category_id === categories.find(c => c.name === activeCategory)?.id;
        const searchMatch = item.name.toLowerCase().includes(searchQuery.toLowerCase());
        return categoryMatch && searchMatch;
    });

    const addToCart = (item) => {
        const existing = cart.find(c => c.id === item.id);
        if (existing) {
            setCart(cart.map(c => c.id === item.id ? { ...c, qty: c.qty + 1 } : c));
        } else {
            setCart([...cart, { ...item, qty: 1 }]);
        }
    };

    const updateQty = (id, delta) => {
        setCart(cart.map(c => {
            if (c.id === id) {
                const newQty = c.qty + delta;
                return newQty > 0 ? { ...c, qty: newQty } : null;
            }
            return c;
        }).filter(Boolean));
    };

    const subtotal = cart.reduce((sum, item) => sum + (item.price * item.qty), 0);
    const taxRate = restaurant.tax_percentage ? parseFloat(restaurant.tax_percentage) / 100 : 0.10;
    const tax = subtotal * taxRate;
    const parsedDeliveryFee = orderType === 'delivery' ? (parseFloat(deliveryFee) || 0) : 0;
    const total = subtotal + tax + parsedDeliveryFee;
    const currency = restaurant.currency_symbol || '$';

    // Sync cart to form data
    useEffect(() => {
        setData(currentData => ({
            ...currentData,
            cart: cart,
            subtotal: subtotal,
            tax: tax,
            delivery_fee: parsedDeliveryFee,
            total: total,
            table_id: selectedTable || null,
            order_type: orderType,
            customer_name: customerName,
            customer_phone: customerPhone,
            delivery_address: deliveryAddress,
            order_id: currentOrderId
        }));
    }, [cart, subtotal, tax, total, selectedTable, orderType, customerName, customerPhone, deliveryAddress, parsedDeliveryFee, currentOrderId]);

    const handleCheckout = () => {
        post('/pos/checkout', {
            onSuccess: (page) => {
                setLastOrder({
                    items: [...cart],
                    subtotal,
                    tax,
                    total,
                    method: data.payment_method,
                    table: tables.find(t => t.id == selectedTable)?.table_number || (orderType === 'delivery' ? 'Delivery' : 'Takeaway'),
                    customer: customerName || 'Walk-in',
                    phone: customerPhone,
                    address: deliveryAddress,
                    delivery_fee: parsedDeliveryFee,
                    order_id: page.props?.flash?.order_id || 'N/A',
                    date: new Date().toLocaleString()
                });
                setCart([]);
                setSelectedTable('');
                setCustomerName('');
                setCustomerPhone('');
                setDeliveryAddress('');
                setDeliveryFee('');
                setOrderType('takeaway');
                setCurrentOrderId(null);
                setShowReceipt(true);
                reset();
            },
            onError: (errors) => {
                console.error("Checkout Validation Errors:", errors);
                alert("Validation failed: " + Object.values(errors).join(', '));
            }
        });
    };

    const handleSaveDraft = () => {
        post('/pos/draft', {
            onSuccess: () => {
                // Clear cart after saving draft
                setCart([]);
                setSelectedTable('');
                setCustomerName('');
                setCustomerPhone('');
                setDeliveryAddress('');
                setDeliveryFee('');
                setOrderType('takeaway');
                setCurrentOrderId(null);
                reset();
            },
            onError: (errors) => {
                console.error("Draft Validation Errors:", errors);
                alert("Validation failed: " + Object.values(errors).join(', '));
            }
        });
    };

    // Load an existing open draft bill into the cart (so user can add more items)
    const loadOpenBill = (tableId) => {
        const bill = openBills[tableId];
        if (!bill) return;

        setSelectedTable(tableId);
        setCustomerName(bill.customer_name || '');
        setCurrentOrderId(bill.order_id);

        // Convert saved items to cart format
        const loadedCart = bill.items.map(item => ({
            id: item.id,
            name: item.name,
            price: item.price,
            qty: item.qty,
        }));

        setCart(loadedCart);
    };

    // Load a draft from the all drafts modal
    const loadDraft = (draft) => {
        setSelectedTable(draft.table_id || '');
        setOrderType(draft.order_type || 'takeaway');
        setCustomerName(draft.customer_name || '');
        setCustomerPhone(draft.customer_phone || '');
        setDeliveryAddress(draft.delivery_address || '');
        setDeliveryFee(draft.delivery_fee > 0 ? draft.delivery_fee.toString() : '');
        setCurrentOrderId(draft.id);

        const loadedCart = draft.items.map(item => ({
            id: item.id,
            name: item.name,
            price: item.price,
            qty: item.qty,
        }));

        setCart(loadedCart);
        setShowDraftsModal(false);
    };

    const printReceipt = () => {
        if (lastOrder && lastOrder.order_id !== 'N/A') {
            window.open(`/orders/${lastOrder.order_id}/receipt`, '_blank', 'width=400,height=600');
        } else {
            alert('Order ID not available for printing.');
        }
    };

    const printKOT = () => {
        if (lastOrder && lastOrder.order_id !== 'N/A') {
            window.open(`/orders/${lastOrder.order_id}/kot`, '_blank', 'width=400,height=600');
        } else {
            alert('Order ID not available for KOT.');
        }
    };

    return (
        <AdminLayout>
            <div className="flex flex-col lg:flex-row gap-6 h-[calc(100vh-8rem)] print:hidden">
                {/* Left Side: Menu */}
                <div className="flex-1 flex flex-col gap-6">
                    {/* Search and Categories */}
                    <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between bg-white p-4 rounded-2xl shadow-sm border border-gray-100">
                        <div className="relative w-full sm:w-72">
                            <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                            <input 
                                type="text"
                                placeholder="Search menu..."
                                className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                            />
                        </div>
                        <div className="flex gap-2 overflow-x-auto w-full sm:w-auto pb-2 sm:pb-0 scrollbar-hide">
                            {displayCategories.map(cat => (
                                <button
                                    key={cat}
                                    onClick={() => setActiveCategory(cat)}
                                    className={`px-4 py-2 whitespace-nowrap rounded-xl font-medium transition-colors ${
                                        activeCategory === cat 
                                        ? 'bg-primary text-white shadow-md shadow-primary/30' 
                                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                                    }`}
                                >
                                    {cat}
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Menu Items Grid */}
                    <div className="flex-1 overflow-y-auto pr-2 grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-4 gap-4 pb-6">
                        {filteredMenu.map(item => (
                            <button
                                key={item.id}
                                onClick={() => addToCart(item)}
                                className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 hover:border-primary hover:shadow-md transition-all text-left group flex flex-col items-center text-center relative overflow-hidden"
                            >
                                <div className="absolute inset-0 bg-primary/5 opacity-0 group-hover:opacity-100 transition-opacity" />
                                {item.image ? (
                                    <img src={`/storage/${item.image}`} alt={item.name} className="w-16 h-16 object-cover rounded-full mb-3" />
                                ) : (
                                    <div className="text-5xl mb-3">🍽️</div>
                                )}
                                <h3 className="font-semibold text-gray-800 line-clamp-2 min-h-[2.5rem]">{item.name}</h3>
                                <p className="text-primary font-bold mt-2">{currency}{Number(item.price).toFixed(2)}</p>
                            </button>
                        ))}
                        {filteredMenu.length === 0 && (
                            <div className="col-span-full py-12 text-center text-gray-500">
                                No menu items found.
                            </div>
                        )}
                    </div>
                </div>

                {/* Right Side: Cart */}
                <div className="w-full lg:w-96 bg-white rounded-2xl shadow-sm border border-gray-100 flex flex-col overflow-hidden flex-shrink-0">
                    
                    {/* Scrollable Top & Cart Items */}
                    <div className="flex-1 overflow-y-auto flex flex-col">
                        <div className="p-4 border-b border-gray-100 bg-gray-50 space-y-3 flex-shrink-0">
                            <div className="flex items-center justify-between">
                                <h2 className="font-bold text-lg flex items-center gap-2">
                                    <ShoppingCart className="w-5 h-5 text-primary" />
                                    Current Order
                                </h2>
                                <div className="flex items-center gap-2">
                                    <button 
                                        onClick={() => setShowDraftsModal(true)}
                                        className="bg-amber-100 text-amber-700 hover:bg-amber-200 text-xs px-2.5 py-1 rounded-md font-semibold transition-colors flex items-center gap-1 shadow-sm"
                                    >
                                        Drafts
                                        <span className="bg-amber-200 text-amber-800 rounded px-1 text-[10px]">{allDrafts?.length || 0}</span>
                                    </button>
                                    <span className="bg-primary/10 text-primary px-3 py-1 rounded-full text-sm font-bold">
                                        {cart.length} items
                                    </span>
                                </div>
                            </div>

                            {/* Customer Name - Optional */}
                            <div>
                                <label className="text-xs font-medium text-gray-600 block mb-1">Customer Name (Optional)</label>
                                <input
                                    type="text"
                                    value={customerName}
                                    onChange={(e) => setCustomerName(e.target.value)}
                                    placeholder="Walk-in Customer"
                                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20"
                                />
                            </div>

                            {/* Order Type */}
                            <div>
                                <label className="text-xs font-medium text-gray-600 block mb-1">Order Type</label>
                                <select
                                    value={orderType}
                                    onChange={(e) => {
                                        const newType = e.target.value;
                                        setOrderType(newType);
                                        if (newType !== 'dine_in') {
                                            setSelectedTable('');
                                        }
                                    }}
                                    disabled={isWaiter}
                                    className={`w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 ${isWaiter ? 'bg-gray-100 text-gray-500 cursor-not-allowed' : 'bg-white'}`}
                                >
                                    {!isWaiter && <option value="takeaway">Takeaway</option>}
                                    <option value="dine_in">Dine In</option>
                                    {!isWaiter && <option value="delivery">Delivery</option>}
                                </select>
                            </div>

                            {/* Delivery Fields */}
                            {orderType === 'delivery' && (
                                <div className="space-y-3">
                                    <div>
                                        <label className="text-xs font-medium text-gray-600 block mb-1">Customer Phone</label>
                                        <input
                                            type="text"
                                            value={customerPhone}
                                            onChange={(e) => setCustomerPhone(e.target.value)}
                                            placeholder="Enter phone number"
                                            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20"
                                        />
                                    </div>
                                    <div>
                                        <label className="text-xs font-medium text-gray-600 block mb-1">Delivery Address</label>
                                        <textarea
                                            value={deliveryAddress}
                                            onChange={(e) => setDeliveryAddress(e.target.value)}
                                            placeholder="Enter full address"
                                            rows="2"
                                            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 resize-none"
                                        />
                                    </div>
                                    <div>
                                        <label className="text-xs font-medium text-gray-600 block mb-1">Delivery Fee</label>
                                        <input
                                            type="number"
                                            value={deliveryFee}
                                            onChange={(e) => setDeliveryFee(e.target.value)}
                                            placeholder="0.00"
                                            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20"
                                        />
                                    </div>
                                </div>
                            )}

                            {/* Table Selection + Open Bills - Only for Dine In */}
                            {orderType === 'dine_in' && (
                                <div className="space-y-3">
                                    {/* Quick select */}
                                    <div>
                                        <label className="text-xs font-medium text-gray-600 block mb-1">Select Table</label>
                                        <select
                                            value={selectedTable}
                                            onChange={(e) => setSelectedTable(e.target.value)}
                                            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 bg-white"
                                        >
                                            <option value="">Select a table...</option>
                                            {tables.map(t => (
                                                <option key={t.id} value={t.id}>
                                                    Table {t.table_number} {t.status === 'occupied' ? '(Occupied)' : ''}
                                                </option>
                                            ))}
                                        </select>
                                    </div>

                                    {/* Open Bills Grid - See and continue existing table bills */}
                                    <div>
                                        <div className="flex items-center justify-between mb-1">
                                            <label className="text-xs font-medium text-gray-600">Open Bills (Click to Load)</label>
                                            <span className="text-[10px] text-emerald-600 font-medium">Tables with running orders</span>
                                        </div>

                                        <div className="grid grid-cols-3 gap-2">
                                            {tables.map(table => {
                                                const bill = openBills[table.id];
                                                const isOpen = !!bill;
                                                const isSelected = selectedTable == table.id;

                                                return (
                                                    <button
                                                        key={table.id}
                                                        type="button"
                                                        onClick={() => {
                                                            if (isOpen) {
                                                                loadOpenBill(table.id);
                                                            } else {
                                                                setSelectedTable(table.id);
                                                            }
                                                        }}
                                                        className={`p-2 rounded-xl border text-left text-xs transition-all ${
                                                            isSelected 
                                                                ? 'border-primary bg-primary/5 ring-1 ring-primary/30' 
                                                                : isOpen 
                                                                    ? 'border-emerald-300 bg-emerald-50 hover:bg-emerald-100' 
                                                                    : 'border-gray-200 hover:bg-gray-50'
                                                        }`}
                                                    >
                                                        <div className="font-semibold text-gray-800">Table {table.table_number}</div>
                                                        <div className="text-[10px] text-gray-500 mt-0.5">
                                                            {table.status === 'occupied' ? 'Occupied' : 'Free'}
                                                        </div>

                                                        {isOpen ? (
                                                            <div className="mt-1">
                                                                <div className="text-emerald-600 font-bold text-sm">
                                                                    {currency}{bill.total.toFixed(2)}
                                                                </div>
                                                                <div className="text-[10px] text-emerald-700 font-medium">Open Bill • Tap to load</div>
                                                            </div>
                                                        ) : (
                                                            <div className="text-[10px] text-gray-400 mt-1">No open bill</div>
                                                        )}
                                                    </button>
                                                );
                                            })}
                                        </div>
                                    </div>
                                </div>
                            )}
                        </div>

                        {/* Cart Items */}
                        <div className="flex-1 p-4 space-y-4">
                            {cart.length === 0 ? (
                                <div className="h-full flex flex-col items-center justify-center text-gray-400">
                                    <ShoppingCart className="w-12 h-12 mb-2 opacity-50" />
                                    <p>No items in cart yet</p>
                                </div>
                            ) : (
                                cart.map(item => (
                                    <div key={item.id} className="flex items-center justify-between gap-4">
                                        <div className="flex-1">
                                            <h4 className="font-semibold text-gray-800 text-sm">{item.name}</h4>
                                            <p className="text-primary font-bold text-sm">{currency}{(item.price * item.qty).toFixed(2)}</p>
                                        </div>
                                        <div className="flex items-center gap-3 bg-gray-50 rounded-xl p-1 border border-gray-100">
                                            <button onClick={() => updateQty(item.id, -1)} className="p-1 hover:bg-white rounded-lg text-gray-500 transition-colors">
                                                {item.qty === 1 ? <Trash2 className="w-4 h-4 text-red-500" /> : <Minus className="w-4 h-4" />}
                                            </button>
                                            <span className="w-4 text-center font-semibold text-sm">{item.qty}</span>
                                            <button onClick={() => updateQty(item.id, 1)} className="p-1 hover:bg-white rounded-lg text-primary transition-colors">
                                                <Plus className="w-4 h-4" />
                                            </button>
                                        </div>
                                    </div>
                                ))
                            )}
                        </div>
                    </div>

                    {/* Totals & Payment */}
                    <div className="p-4 border-t border-gray-100 bg-gray-50/50 flex-shrink-0">
                        <div className="space-y-2 mb-4">
                            <div className="flex justify-between text-gray-500 text-sm">
                                <span>Subtotal</span>
                                <span>{currency}{subtotal.toFixed(2)}</span>
                            </div>
                            <div className="flex justify-between text-gray-500 text-sm">
                                <span>Tax ({restaurant.tax_percentage || 10}%)</span>
                                <span>{currency}{tax.toFixed(2)}</span>
                            </div>
                            {parsedDeliveryFee > 0 && (
                                <div className="flex justify-between text-gray-500 text-sm">
                                    <span>Delivery Fee</span>
                                    <span>{currency}{parsedDeliveryFee.toFixed(2)}</span>
                                </div>
                            )}
                            <div className="flex justify-between font-bold text-xl pt-2 border-t border-gray-200 text-gray-900">
                                <span>Total</span>
                                <span>{currency}{total.toFixed(2)}</span>
                            </div>
                        </div>

                        {/* Save as Draft Button - for open bills (especially Dine In) */}
                        {(orderType === 'dine_in' || isWaiter) && (
                            <button
                                type="button"
                                className={`w-full mb-4 py-2.5 rounded-xl font-semibold transition-all text-sm ${
                                    isWaiter 
                                    ? 'bg-amber-100 text-amber-700 hover:bg-amber-200 border-2 border-amber-200 shadow-sm' 
                                    : 'border-2 border-dashed border-gray-300 text-gray-500 hover:border-amber-400 hover:text-amber-600 hover:bg-amber-50'
                                }`}
                                onClick={handleSaveDraft}
                                disabled={cart.length === 0 || processing}
                            >
                                {isWaiter ? 'Send to Kitchen (Save Draft)' : 'Save as Draft (Open Bill)'}
                            </button>
                        )}

                        {!isWaiter && (
                            <>
                                <div className="flex gap-1 mb-4 bg-gray-100 p-1.5 rounded-xl">
                                    {['Cash', 'Card', 'QR Pay', ...(orderType === 'delivery' ? ['Cash on Delivery'] : [])].map(method => (
                                        <button
                                            key={method}
                                            type="button"
                                            onClick={() => setData('payment_method', method)}
                                            className={`flex-1 py-2 text-xs font-semibold rounded-lg transition-all flex items-center justify-center gap-1.5 ${
                                                data.payment_method === method 
                                                ? 'bg-white text-gray-800 shadow-sm' 
                                                : 'text-gray-500 hover:text-gray-700'
                                            }`}
                                        >
                                            {method === 'Cash' && <Banknote className="w-4 h-4" />}
                                            {method === 'Card' && <CreditCard className="w-4 h-4" />}
                                            {method === 'QR Pay' && <QrCode className="w-4 h-4" />}
                                            {method === 'Cash on Delivery' && <Banknote className="w-4 h-4" />}
                                            {method === 'Cash on Delivery' ? 'COD' : method}
                                        </button>
                                    ))}
                                </div>

                                <Button 
                                    className="w-full bg-primary hover:bg-primary/90 text-white font-bold py-3.5 text-base rounded-xl transition-all flex justify-between items-center px-5 shadow-md shadow-primary/20"
                                    onClick={handleCheckout}
                                    disabled={cart.length === 0 || processing}
                                >
                                    <span>Pay Now</span>
                                    <span>
                                        {processing ? (
                                            <Loader2 className="w-5 h-5 animate-spin" />
                                        ) : (
                                            `${currency}${total.toFixed(2)}`
                                        )}
                                    </span>
                                </Button>
                            </>
                        )}
                    </div>
                </div>
            </div>

            {/* Receipt Modal */}
            {showReceipt && lastOrder && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4 print:bg-white print:p-0 print:block">
                    <div className="bg-white rounded-2xl w-full max-w-sm shadow-xl overflow-hidden print:shadow-none print:w-full print:max-w-none">
                        <div className="p-6 print:p-4">
                            <div className="text-center mb-6 border-b border-dashed border-gray-300 pb-6">
                                <h2 className="text-2xl font-bold mb-1">RESTAURANT RECEIPT</h2>
                                <p className="text-gray-500 text-sm">{lastOrder.date}</p>
                                <p className="text-gray-500 text-sm">
                                    Order #{lastOrder.order_id} | {lastOrder.table}
                                    {lastOrder.customer && ` | ${lastOrder.customer}`}
                                </p>
                            </div>
                            
                            <div className="space-y-3 mb-6">
                                {lastOrder.items.map(item => (
                                    <div key={item.id} className="flex justify-between text-sm">
                                        <span>{item.qty}x {item.name}</span>
                                        <span>{currency}{(item.price * item.qty).toFixed(2)}</span>
                                    </div>
                                ))}
                            </div>

                            <div className="border-t border-dashed border-gray-300 pt-4 space-y-2 mb-6">
                                <div className="flex justify-between text-sm text-gray-600">
                                    <span>Subtotal</span>
                                    <span>{currency}{lastOrder.subtotal.toFixed(2)}</span>
                                </div>
                                <div className="flex justify-between text-sm text-gray-600">
                                    <span>Tax</span>
                                    <span>{currency}{lastOrder.tax.toFixed(2)}</span>
                                </div>
                                {lastOrder.delivery_fee > 0 && (
                                    <div className="flex justify-between text-sm text-gray-600">
                                        <span>Delivery Fee</span>
                                        <span>{currency}{lastOrder.delivery_fee.toFixed(2)}</span>
                                    </div>
                                )}
                                <div className="flex justify-between font-bold text-lg pt-2">
                                    <span>Total</span>
                                    <span>{currency}{lastOrder.total.toFixed(2)}</span>
                                </div>
                            </div>

                            <div className="text-center text-sm text-gray-500 mb-6">
                                Paid via {lastOrder.method}
                            </div>

                            <div className="flex flex-col sm:flex-row gap-3 print:hidden">
                                <Button className="flex-1 flex justify-center gap-2 bg-slate-800 hover:bg-slate-900" onClick={printReceipt}>
                                    <Printer className="w-4 h-4" /> Print Receipt
                                </Button>
                                <Button className="flex-1 flex justify-center gap-2 bg-orange-600 hover:bg-orange-700 text-white" onClick={printKOT}>
                                    <Printer className="w-4 h-4" /> Print KOT
                                </Button>
                                <Button variant="outline" className="flex-none" onClick={() => setShowReceipt(false)}>
                                    <X className="w-4 h-4" /> Close
                                </Button>
                            </div>
                        </div>
                    </div>
                </div>
            )}

            {/* Open Drafts Modal */}
            {showDraftsModal && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl w-full max-w-4xl shadow-xl overflow-hidden max-h-[90vh] flex flex-col">
                        <div className="p-6 border-b border-gray-100 flex justify-between items-center bg-gray-50">
                            <h2 className="text-xl font-bold text-gray-800">Open Draft Bills</h2>
                            <button onClick={() => setShowDraftsModal(false)} className="p-2 hover:bg-gray-200 rounded-full transition-colors">
                                <X className="w-5 h-5 text-gray-500" />
                            </button>
                        </div>
                        <div className="p-6 overflow-y-auto flex-1 bg-gray-50/50">
                            {allDrafts?.length === 0 ? (
                                <div className="text-center py-12 text-gray-500">
                                    <div className="text-6xl mb-4">📝</div>
                                    <p>No open draft bills found.</p>
                                </div>
                            ) : (
                                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                                    {allDrafts?.map(draft => (
                                        <div key={draft.id} className="bg-white p-5 rounded-2xl border border-gray-200 shadow-sm hover:shadow-md transition-all flex flex-col">
                                            <div className="flex justify-between items-start mb-3">
                                                <div>
                                                    <span className="inline-block px-2 py-1 bg-amber-100 text-amber-800 text-[10px] font-bold rounded-md uppercase tracking-wider mb-2">
                                                        {draft.order_type.replace('_', ' ')}
                                                    </span>
                                                    <h3 className="font-bold text-gray-900 flex items-center gap-2">
                                                        {draft.table_number ? `Table ${draft.table_number}` : (draft.order_type === 'dine_in' ? 'Dine In (No Table)' : 'Walk-in')}
                                                        {draft.customer_name && (
                                                            <span className="text-xs font-normal text-gray-500 bg-gray-100 px-2 py-0.5 rounded-full">
                                                                {draft.customer_name}
                                                            </span>
                                                        )}
                                                    </h3>
                                                    <p className="text-xs text-gray-500 mt-1">{draft.created_at}</p>
                                                </div>
                                                <div className="text-right">
                                                    <div className="font-black text-lg text-emerald-600">{currency}{draft.total.toFixed(2)}</div>
                                                    <div className="text-[10px] text-gray-400">ID: #{draft.id}</div>
                                                </div>
                                            </div>
                                            
                                            <div className="flex-1 bg-gray-50 rounded-xl p-3 mb-4 space-y-1.5 overflow-y-auto max-h-32">
                                                {draft.items.map((item, idx) => (
                                                    <div key={idx} className="flex justify-between text-xs text-gray-600">
                                                        <span className="truncate pr-2">{item.qty}x {item.name}</span>
                                                        <span className="font-medium whitespace-nowrap">{currency}{(item.price * item.qty).toFixed(2)}</span>
                                                    </div>
                                                ))}
                                            </div>
                                            
                                            <Button 
                                                className="w-full bg-primary hover:bg-primary/90 text-white" 
                                                onClick={() => loadDraft(draft)}
                                            >
                                                Load & Complete Order
                                            </Button>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            )}
        </AdminLayout>
    );
}
