import React, { useState, useEffect } from 'react';
import AdminLayout from '../Layouts/AdminLayout';
import { Card, CardContent } from '../Components/ui/Card';
import { Button } from '../Components/ui/Button';
import { Search, ShoppingCart, Trash2, Plus, Minus, CreditCard, Banknote, QrCode, Printer, X, Loader2, Layers } from 'lucide-react';
import { useForm, router, usePage } from '@inertiajs/react';
import { SwalAlert, SwalToast } from '../Utils/swal';

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
    const [cashReceived, setCashReceived] = useState('');
    const [showReceipt, setShowReceipt] = useState(false);
    const [lastOrder, setLastOrder] = useState(null);
    const [currentOrderId, setCurrentOrderId] = useState(null);
    const [showDraftsModal, setShowDraftsModal] = useState(false);
    const [showTableModal, setShowTableModal] = useState(false);
    const [mobileTab, setMobileTab] = useState('menu'); // 'menu' | 'cart'

    // Size / Variant Picker Modal State
    const [sizeModalItem, setSizeModalItem] = useState(null);

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

    const displayCategories = ['All', ...categories.map(c => c.name)];

    const filteredMenu = menuItems.filter(item => {
        const categoryMatch = activeCategory === 'All' || item.category_id === categories.find(c => c.name === activeCategory)?.id;
        const searchMatch = item.name.toLowerCase().includes(searchQuery.toLowerCase());
        return categoryMatch && searchMatch;
    });

    const handleProductClick = (item) => {
        if (item.stock_quantity !== null && item.stock_quantity !== undefined && item.stock_quantity <= 0) {
            SwalAlert({ title: 'Out of Stock', text: `${item.name} is currently out of stock!`, icon: 'error' });
            return;
        }

        if (item.variants && item.variants.length > 0) {
            setSizeModalItem(item);
        } else {
            addToCart(item);
        }
    };

    const addToCart = (item) => {
        const existing = cart.find(c => c.id === item.id && !c.variant_id);
        const currentQty = existing ? existing.qty : 0;
        if (item.stock_quantity !== null && item.stock_quantity !== undefined && (currentQty + 1) > item.stock_quantity) {
            SwalAlert({ title: 'Stock Limit Reached', text: `Cannot add more ${item.name}. Maximum available stock is ${item.stock_quantity}.`, icon: 'warning' });
            return;
        }
        if (existing) {
            setCart(cart.map(c => (c.id === item.id && !c.variant_id) ? { ...c, qty: c.qty + 1 } : c));
        } else {
            setCart([...cart, { ...item, qty: 1 }]);
        }
    };

    const addVariantToCart = (item, variant) => {
        const cartKey = `${item.id}-${variant.id}`;
        const variantItemName = `${item.name} (${variant.name})`;
        const variantPrice = Number(variant.price);

        const existing = cart.find(c => c.cart_key === cartKey || (c.id === item.id && c.variant_id === variant.id));
        const currentQty = existing ? existing.qty : 0;

        if (item.stock_quantity !== null && item.stock_quantity !== undefined && (currentQty + 1) > item.stock_quantity) {
            SwalAlert({ title: 'Stock Limit Reached', text: `Cannot add more ${variantItemName}. Maximum available stock is ${item.stock_quantity}.`, icon: 'warning' });
            return;
        }

        if (existing) {
            setCart(cart.map(c => (c.cart_key === cartKey || (c.id === item.id && c.variant_id === variant.id)) ? { ...c, qty: c.qty + 1 } : c));
        } else {
            setCart([...cart, {
                id: item.id,
                variant_id: variant.id,
                cart_key: cartKey,
                name: variantItemName,
                price: variantPrice,
                qty: 1
            }]);
        }
        setSizeModalItem(null);
    };

    const updateQty = (keyOrId, delta) => {
        setCart(cart.map(c => {
            const isMatch = c.cart_key ? (c.cart_key === keyOrId) : (c.id === keyOrId);
            if (isMatch) {
                const menuItem = menuItems.find(m => m.id === c.id);
                const maxStock = menuItem?.stock_quantity;
                const newQty = c.qty + delta;
                if (delta > 0 && maxStock !== null && maxStock !== undefined && newQty > maxStock) {
                    SwalAlert({ title: 'Stock Limit Reached', text: `Cannot increase quantity. Maximum available stock is ${maxStock}.`, icon: 'warning' });
                    return c;
                }
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

    const rawPaymentMethods = restaurant?.payment_methods || 'Cash,Card';
    const configuredMethods = rawPaymentMethods.split(',').map(m => m.trim()).filter(Boolean);
    const availablePaymentMethods = [
        ...(configuredMethods.length > 0 ? configuredMethods : ['Cash', 'Card']),
        ...(orderType === 'delivery' && !configuredMethods.includes('Cash on Delivery') ? ['Cash on Delivery'] : [])
    ];

    const cashReceivedNum = parseFloat(cashReceived) || 0;
    const changeReturnAmount = cashReceivedNum >= total && total > 0 ? (cashReceivedNum - total) : 0;
    const remainingDueAmount = cashReceivedNum > 0 && cashReceivedNum < total ? (total - cashReceivedNum) : 0;

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
            preserveScroll: true,
            preserveState: true,
            only: ['openBills', 'allDrafts', 'tables', 'flash', 'menuItems'],
            onSuccess: (page) => {
                setLastOrder({
                    items: [...cart],
                    subtotal,
                    tax,
                    total,
                    cash_received: cashReceivedNum,
                    change_return: changeReturnAmount,
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
                setCashReceived('');
                setOrderType('takeaway');
                setCurrentOrderId(null);
                setShowReceipt(true);
                reset();
                SwalToast('Order completed successfully!');
            },
            onError: (errors) => {
                console.error("Checkout Validation Errors:", errors);
                SwalAlert({ title: 'Validation Failed', text: Object.values(errors).join(', '), icon: 'error' });
            }
        });
    };

    const handleSaveDraft = () => {
        post('/pos/draft', {
            preserveScroll: true,
            preserveState: true,
            only: ['openBills', 'allDrafts', 'tables', 'flash', 'menuItems'],
            onSuccess: () => {
                setCart([]);
                setSelectedTable('');
                setCustomerName('');
                setCustomerPhone('');
                setDeliveryAddress('');
                setDeliveryFee('');
                setOrderType('takeaway');
                setCurrentOrderId(null);
                reset();
                SwalToast('Draft saved successfully');
            },
            onError: (errors) => {
                console.error("Draft Validation Errors:", errors);
                SwalAlert({ title: 'Validation Failed', text: Object.values(errors).join(', '), icon: 'error' });
            }
        });
    };

    const loadOpenBill = (tableId) => {
        const bill = openBills[tableId];
        if (!bill) return;

        setSelectedTable(tableId);
        setCustomerName(bill.customer_name || '');
        setCurrentOrderId(bill.order_id);

        const loadedCart = bill.items.map((item, idx) => ({
            id: item.id,
            variant_id: item.variant_id || null,
            cart_key: item.variant_id ? `${item.id}-${item.variant_id}` : `item-${item.id}-${idx}`,
            name: item.name,
            price: item.price,
            qty: item.qty,
        }));

        setCart(loadedCart);
        SwalToast(`Loaded bill for Table ${tables.find(t => t.id == tableId)?.table_number || ''}`);
    };

    const loadDraft = (draft) => {
        setSelectedTable(draft.table_id || '');
        setOrderType(draft.order_type || 'takeaway');
        setCustomerName(draft.customer_name || '');
        setCustomerPhone(draft.customer_phone || '');
        setDeliveryAddress(draft.delivery_address || '');
        setDeliveryFee(draft.delivery_fee > 0 ? draft.delivery_fee.toString() : '');
        setCurrentOrderId(draft.id);

        const loadedCart = draft.items.map((item, idx) => ({
            id: item.id,
            variant_id: item.variant_id || null,
            cart_key: item.variant_id ? `${item.id}-${item.variant_id}` : `item-${item.id}-${idx}`,
            name: item.name,
            price: item.price,
            qty: item.qty,
        }));

        setCart(loadedCart);
        setShowDraftsModal(false);
        SwalToast('Draft bill loaded');
    };

    const printReceipt = () => {
        if (lastOrder && lastOrder.order_id !== 'N/A') {
            window.open(`/orders/${lastOrder.order_id}/receipt`, '_blank', 'width=400,height=600');
        } else {
            SwalAlert({ title: 'Print Error', text: 'Order ID not available for printing.', icon: 'warning' });
        }
    };

    const printKOT = () => {
        if (lastOrder && lastOrder.order_id !== 'N/A') {
            window.open(`/orders/${lastOrder.order_id}/kot`, '_blank', 'width=400,height=600');
        } else {
            SwalAlert({ title: 'Print Error', text: 'Order ID not available for KOT.', icon: 'warning' });
        }
    };

    const printBoth = () => {
        if (lastOrder && lastOrder.order_id !== 'N/A') {
            window.open(`/orders/${lastOrder.order_id}/both`, '_blank', 'width=400,height=750');
        } else {
            SwalAlert({ title: 'Print Error', text: 'Order ID not available for printing.', icon: 'warning' });
        }
    };

    return (
        <AdminLayout>
            {/* Mobile / Tablet View Switcher */}
            <div className="lg:hidden flex bg-white p-1.5 rounded-2xl shadow-xs border border-gray-100 mb-4 gap-2">
                <button
                    type="button"
                    onClick={() => setMobileTab('menu')}
                    className={`flex-1 py-2.5 rounded-xl font-bold text-sm flex items-center justify-center gap-2 transition-all ${
                        mobileTab === 'menu' 
                        ? 'bg-primary text-white shadow-md shadow-primary/20' 
                        : 'text-gray-600 hover:bg-gray-100'
                    }`}
                >
                    <span>🍽️ Menu Items</span>
                </button>
                <button
                    type="button"
                    onClick={() => setMobileTab('cart')}
                    className={`flex-1 py-2.5 rounded-xl font-bold text-sm flex items-center justify-center gap-2 transition-all relative ${
                        mobileTab === 'cart' 
                        ? 'bg-primary text-white shadow-md shadow-primary/20' 
                        : 'text-gray-600 hover:bg-gray-100'
                    }`}
                >
                    <ShoppingCart className="w-4 h-4" />
                    <span>Cart & Pay</span>
                    {cart.length > 0 && (
                        <span className={`px-2 py-0.5 rounded-full text-xs font-bold ${
                            mobileTab === 'cart' ? 'bg-white text-primary' : 'bg-primary text-white'
                        }`}>
                            {cart.length}
                        </span>
                    )}
                </button>
            </div>

            <div className="flex flex-col lg:flex-row gap-4 sm:gap-6 min-h-[calc(100vh-8rem)] lg:h-[calc(100vh-7rem)] print:hidden relative pb-16 lg:pb-0 w-full max-w-full min-w-0 overflow-x-hidden">
                {/* Left Side: Menu */}
                <div className={`flex-1 flex flex-col gap-4 sm:gap-6 min-w-0 max-w-full ${mobileTab === 'menu' ? 'flex' : 'hidden lg:flex'}`}>
                    {/* Search and Categories */}
                    <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center justify-between bg-white p-3.5 sm:p-4 rounded-2xl shadow-sm border border-gray-100 min-w-0">
                        <div className="relative w-full sm:w-72 shrink-0">
                            <Search className="w-4 h-4 sm:w-5 sm:h-5 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                            <input 
                                type="text"
                                placeholder="Search menu..."
                                className="w-full pl-9 sm:pl-10 pr-4 py-2 sm:py-2.5 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-xs sm:text-sm"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                            />
                        </div>
                        <div className="flex gap-2 overflow-x-auto w-full sm:w-auto pb-1 sm:pb-0 scrollbar-hide shrink min-w-0">
                            {displayCategories.map(cat => (
                                <button
                                    key={cat}
                                    onClick={() => setActiveCategory(cat)}
                                    className={`px-3.5 py-1.5 sm:px-4 sm:py-2 whitespace-nowrap rounded-xl font-medium text-xs sm:text-sm transition-colors shrink-0 ${
                                        activeCategory === cat 
                                        ? 'bg-primary text-white shadow-md shadow-primary/30 font-bold' 
                                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                                    }`}
                                >
                                    {cat}
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Menu Items Grid */}
                    <div className="flex-1 overflow-y-auto pr-1 grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-3 sm:gap-4 pb-6">
                        {filteredMenu.map(item => {
                            const isOutOfStock = item.stock_quantity !== null && item.stock_quantity !== undefined && item.stock_quantity <= 0;
                            const isLowStock = item.stock_quantity !== null && item.stock_quantity !== undefined && item.stock_quantity > 0 && item.stock_quantity <= 5;
                            const hasVars = item.variants && item.variants.length > 0;
                            const minPrice = hasVars ? Math.min(...item.variants.map(v => Number(v.price))) : Number(item.price);

                            return (
                                <button
                                    key={item.id}
                                    onClick={() => !isOutOfStock && handleProductClick(item)}
                                    disabled={isOutOfStock}
                                    className={`p-3 sm:p-4 rounded-2xl shadow-xs border transition-all text-left group flex flex-col items-center text-center relative overflow-hidden ${
                                        isOutOfStock 
                                            ? 'bg-gray-100/90 border-gray-200 opacity-65 cursor-not-allowed select-none' 
                                            : 'bg-white border-gray-100 hover:border-primary hover:shadow-md cursor-pointer'
                                    }`}
                                >
                                    {/* Out of Stock or Stock Count Badge */}
                                    {isOutOfStock ? (
                                        <span className="absolute top-2 right-2 bg-red-600 text-white text-[9px] sm:text-[10px] font-black px-2 py-0.5 rounded-full uppercase tracking-wider shadow-xs z-10">
                                            Out of Stock
                                        </span>
                                    ) : item.stock_quantity !== null && item.stock_quantity !== undefined && (
                                        <span className={`absolute top-2 right-2 text-[10px] font-extrabold px-2 py-0.5 rounded-full z-10 ${
                                            isLowStock ? 'bg-amber-100 text-amber-800 border border-amber-200' : 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                                        }`}>
                                            Stock: {item.stock_quantity}
                                        </span>
                                    )}

                                    <div className="absolute inset-0 bg-primary/5 opacity-0 group-hover:opacity-100 transition-opacity" />
                                    
                                    {item.image ? (
                                        <img 
                                            src={`/storage/${item.image}`} 
                                            alt={item.name} 
                                            className={`w-14 h-14 sm:w-16 sm:h-16 object-cover rounded-full mb-2 sm:mb-3 ${isOutOfStock ? 'grayscale opacity-50' : ''}`} 
                                        />
                                    ) : (
                                        <div className={`text-3xl sm:text-4xl mb-2 sm:mb-3 ${isOutOfStock ? 'grayscale opacity-50' : ''}`}>🍽️</div>
                                    )}

                                    <h3 className={`font-semibold line-clamp-2 min-h-[2.2rem] text-xs sm:text-sm ${isOutOfStock ? 'text-gray-500' : 'text-gray-800'}`}>
                                        {item.name}
                                    </h3>

                                    <div className={`font-bold mt-1 sm:mt-2 text-xs sm:text-sm ${isOutOfStock ? 'text-gray-400 line-through' : 'text-primary'}`}>
                                        {hasVars ? (
                                            <div className="flex flex-col items-center">
                                                <span>{currency}{minPrice.toFixed(2)}+</span>
                                                <span className="text-[10px] text-purple-600 font-bold uppercase tracking-wider mt-0.5 flex items-center gap-0.5">
                                                    <Layers className="w-3 h-3" /> {item.variants.length} Sizes
                                                </span>
                                            </div>
                                        ) : (
                                            <span>{currency}{Number(item.price).toFixed(2)}</span>
                                        )}
                                    </div>
                                </button>
                            );
                        })}
                        {filteredMenu.length === 0 && (
                            <div className="col-span-full py-12 text-center text-gray-500">
                                No menu items found.
                            </div>
                        )}
                    </div>
                </div>

                {/* Right Side: Cart */}
                <div className={`w-full lg:w-[350px] xl:w-[380px] shrink-0 min-w-0 bg-white rounded-2xl shadow-sm border border-gray-100 flex flex-col overflow-y-auto max-h-full ${mobileTab === 'cart' ? 'flex' : 'hidden lg:flex'}`}>
                    
                    {/* Header & Order Setup */}
                    <div className="p-3.5 sm:p-4 border-b border-gray-100 bg-gray-50 space-y-3 shrink-0">
                        <div className="flex items-center justify-between">
                            <h2 className="font-bold text-base sm:text-lg flex items-center gap-2">
                                <ShoppingCart className="w-4 h-4 sm:w-5 sm:h-5 text-primary" />
                                Current Order
                            </h2>
                            <div className="flex items-center gap-2">
                                <button 
                                    onClick={() => setShowDraftsModal(true)}
                                    className="bg-amber-100 hover:bg-amber-200 text-amber-800 text-xs px-2.5 py-1 rounded-lg font-bold transition-colors flex items-center gap-1 border border-amber-300/60 shadow-2xs"
                                >
                                    Drafts
                                    <span className="bg-amber-300 text-amber-900 rounded px-1.5 py-0.2 text-[10px] font-black">{allDrafts?.length || 0}</span>
                                </button>
                                <span className="bg-primary/10 text-primary px-2.5 py-1 rounded-full text-xs font-extrabold">
                                    {cart.length} items
                                </span>
                            </div>
                        </div>

                        {/* Customer Name */}
                        <div>
                            <label className="text-[11px] font-bold text-gray-500 uppercase tracking-wider block mb-1">Customer Name (Optional)</label>
                            <input
                                type="text"
                                value={customerName}
                                onChange={(e) => setCustomerName(e.target.value)}
                                placeholder="Walk-in Customer"
                                className="w-full px-3 py-1.5 border border-gray-200 rounded-lg text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 bg-white"
                            />
                        </div>

                        {/* Order Type Segmented Toggle */}
                        <div>
                            <label className="text-[11px] font-bold text-gray-500 uppercase tracking-wider block mb-1">Order Type</label>
                            <div className="grid grid-cols-3 gap-1 bg-gray-200/80 p-1 rounded-xl">
                                {[
                                    { key: 'takeaway', label: '🛍️ Takeaway' },
                                    { key: 'dine_in', label: '🍽️ Dine In' },
                                    { key: 'delivery', label: '🚚 Delivery' }
                                ].map(type => (
                                    <button
                                        key={type.key}
                                        type="button"
                                        disabled={isWaiter && type.key !== 'dine_in'}
                                        onClick={() => {
                                            setOrderType(type.key);
                                            if (type.key !== 'dine_in') {
                                                setSelectedTable('');
                                            } else if (!selectedTable && tables.length > 0) {
                                                setShowTableModal(true);
                                            }
                                        }}
                                        className={`py-1.5 px-1 text-[11px] sm:text-xs font-black rounded-lg transition-all text-center whitespace-nowrap ${
                                            orderType === type.key
                                            ? 'bg-white text-gray-900 shadow-sm border border-gray-100'
                                            : 'text-gray-600 hover:text-gray-900'
                                        } ${isWaiter && type.key !== 'dine_in' ? 'opacity-40 cursor-not-allowed' : ''}`}
                                    >
                                        {type.label}
                                    </button>
                                ))}
                            </div>
                        </div>

                        {/* Table Status Card (Only for Dine In) */}
                        {orderType === 'dine_in' && (
                            <div className="bg-orange-50/90 border border-orange-200 p-2.5 rounded-xl flex items-center justify-between gap-2 shadow-2xs">
                                <div className="min-w-0 flex-1">
                                    <div className="text-[10px] font-black text-orange-800 uppercase tracking-wider">Dining Table</div>
                                    <div className="text-xs font-extrabold text-gray-900 truncate mt-0.5 flex items-center gap-1.5">
                                        {selectedTable ? (
                                            <>
                                                <span className="text-orange-950 font-black">🪑 Table {tables.find(t => t.id == selectedTable)?.table_number || selectedTable}</span>
                                                {openBills[selectedTable] && (
                                                    <span className="text-[10px] bg-amber-200 text-amber-900 px-1.5 py-0.2 rounded font-bold shrink-0">
                                                        Active ({currency}{openBills[selectedTable].total.toFixed(2)})
                                                    </span>
                                                )}
                                            </>
                                        ) : (
                                            <span className="text-red-600 font-bold flex items-center gap-1">
                                                ⚠️ No table selected
                                            </span>
                                        )}
                                    </div>
                                </div>

                                <button
                                    type="button"
                                    onClick={() => setShowTableModal(true)}
                                    className="bg-white hover:bg-orange-100 text-orange-900 text-xs font-extrabold px-2.5 py-1.5 rounded-lg border border-orange-300 transition-colors shadow-2xs shrink-0"
                                >
                                    {selectedTable ? 'Change Table' : 'Select Table'}
                                </button>
                            </div>
                        )}

                        {/* Delivery Fields */}
                        {orderType === 'delivery' && (
                            <div className="space-y-2">
                                <div>
                                    <label className="text-[11px] font-bold text-gray-500 uppercase tracking-wider block mb-1">Customer Phone</label>
                                    <input
                                        type="text"
                                        value={customerPhone}
                                        onChange={(e) => setCustomerPhone(e.target.value)}
                                        placeholder="Enter phone number"
                                        className="w-full px-3 py-1.5 border border-gray-200 rounded-lg text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 bg-white"
                                    />
                                </div>
                                <div>
                                    <label className="text-[11px] font-bold text-gray-500 uppercase tracking-wider block mb-1">Delivery Address</label>
                                    <textarea
                                        value={deliveryAddress}
                                        onChange={(e) => setDeliveryAddress(e.target.value)}
                                        placeholder="Enter full address"
                                        rows="2"
                                        className="w-full px-3 py-1.5 border border-gray-200 rounded-lg text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 resize-none bg-white"
                                    />
                                </div>
                                <div>
                                    <label className="text-[11px] font-bold text-gray-500 uppercase tracking-wider block mb-1">Delivery Fee ({currency})</label>
                                    <input
                                        type="number"
                                        value={deliveryFee}
                                        onChange={(e) => setDeliveryFee(e.target.value)}
                                        placeholder="0.00"
                                        className="w-full px-3 py-1.5 border border-gray-200 rounded-lg text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 bg-white"
                                    />
                                </div>
                            </div>
                        )}
                    </div>

                    {/* Cart Items */}
                    <div className="p-4 space-y-3 min-h-[140px]">
                        {cart.length === 0 ? (
                            <div className="py-8 flex flex-col items-center justify-center text-gray-400">
                                <ShoppingCart className="w-10 h-10 mb-2 opacity-40" />
                                <p className="text-xs font-semibold">No items in order yet</p>
                            </div>
                        ) : (
                            cart.map((item, index) => {
                                const itemKey = item.cart_key || item.id;
                                return (
                                    <div key={itemKey || index} className="flex items-center justify-between gap-3 p-2 bg-gray-50/80 rounded-xl border border-gray-100">
                                        <div className="flex-1 min-w-0">
                                            <h4 className="font-bold text-gray-800 text-xs sm:text-sm truncate">{item.name}</h4>
                                            <p className="text-primary font-black text-xs">{currency}{(item.price * item.qty).toFixed(2)}</p>
                                        </div>
                                        <div className="flex items-center gap-2 bg-white rounded-lg p-1 border border-gray-200 shadow-2xs shrink-0">
                                            <button onClick={() => updateQty(itemKey, -1)} className="p-1 hover:bg-gray-100 rounded text-gray-600 transition-colors">
                                                {item.qty === 1 ? <Trash2 className="w-3.5 h-3.5 text-red-500" /> : <Minus className="w-3.5 h-3.5" />}
                                            </button>
                                            <span className="w-4 text-center font-bold text-xs text-gray-900">{item.qty}</span>
                                            <button onClick={() => updateQty(itemKey, 1)} className="p-1 hover:bg-gray-100 rounded text-primary transition-colors">
                                                <Plus className="w-3.5 h-3.5" />
                                            </button>
                                        </div>
                                    </div>
                                );
                            })
                        )}
                    </div>

                    {/* Totals & Payment */}
                    <div className="p-4 border-t border-gray-100 bg-gray-50/50 mt-auto">
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
                                <div className="flex gap-1.5 mb-4 bg-gray-100 p-1.5 rounded-xl flex-wrap">
                                    {availablePaymentMethods.map(method => (
                                        <button
                                            key={method}
                                            type="button"
                                            onClick={() => setData('payment_method', method)}
                                            className={`flex-1 min-w-[70px] py-2 text-xs font-semibold rounded-lg transition-all flex items-center justify-center gap-1.5 ${
                                                data.payment_method === method 
                                                ? 'bg-white text-gray-800 shadow-sm' 
                                                : 'text-gray-500 hover:text-gray-700'
                                            }`}
                                        >
                                            {method.toLowerCase().includes('cash') && <Banknote className="w-4 h-4" />}
                                            {method.toLowerCase().includes('card') && <CreditCard className="w-4 h-4" />}
                                            {!method.toLowerCase().includes('cash') && !method.toLowerCase().includes('card') && <QrCode className="w-4 h-4" />}
                                            {method === 'Cash on Delivery' ? 'COD' : method}
                                        </button>
                                    ))}
                                </div>

                                {/* Cash & Change Return Option */}
                                {data.payment_method.toLowerCase().includes('cash') && (
                                    <div className="mb-4 bg-emerald-50/80 border border-emerald-200/80 p-3 rounded-xl space-y-2.5">
                                        <div className="flex items-center justify-between">
                                            <label className="text-xs font-bold text-emerald-950 uppercase tracking-wider flex items-center gap-1.5">
                                                <Banknote className="w-4 h-4 text-emerald-600" />
                                                Cash Received & Change
                                            </label>
                                            {cashReceivedNum > 0 && (
                                                <button 
                                                    type="button" 
                                                    onClick={() => setCashReceived('')}
                                                    className="text-[11px] text-gray-500 hover:text-red-600 font-semibold transition-colors"
                                                >
                                                    Clear
                                                </button>
                                            )}
                                        </div>

                                        <div className="relative">
                                            <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 font-bold text-sm">
                                                {currency}
                                            </span>
                                            <input
                                                type="number"
                                                step="any"
                                                min="0"
                                                value={cashReceived}
                                                onChange={(e) => setCashReceived(e.target.value)}
                                                placeholder={`Amount paid (e.g. ${total.toFixed(2)})`}
                                                className="w-full pl-8 pr-3 py-2 border border-emerald-300 rounded-lg text-sm font-bold bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500/30"
                                            />
                                        </div>

                                        {/* Preset Fast Cash Options */}
                                        <div className="flex gap-1.5 overflow-x-auto pb-1 scrollbar-hide">
                                            {[
                                                { label: 'Exact', val: total.toFixed(2) },
                                                ...(total < 10 ? [{ label: `${currency}10`, val: '10' }] : []),
                                                ...(total < 20 ? [{ label: `${currency}20`, val: '20' }] : []),
                                                ...(total < 50 ? [{ label: `${currency}50`, val: '50' }] : []),
                                                ...(total < 100 ? [{ label: `${currency}100`, val: '100' }] : []),
                                                ...(total < 500 ? [{ label: `${currency}500`, val: '500' }] : []),
                                                ...(total < 1000 ? [{ label: `${currency}1000`, val: '1000' }] : []),
                                                ...(total < 5000 ? [{ label: `${currency}5000`, val: '5000' }] : []),
                                            ].map((opt, i) => (
                                                <button
                                                    key={i}
                                                    type="button"
                                                    onClick={() => setCashReceived(opt.val)}
                                                    className={`px-2 py-1 text-xs font-bold rounded-lg border transition-all whitespace-nowrap ${
                                                        cashReceived === opt.val
                                                        ? 'bg-emerald-600 text-white border-emerald-600 shadow-xs'
                                                        : 'bg-white text-emerald-800 border-emerald-200 hover:bg-emerald-100'
                                                    }`}
                                                >
                                                    {opt.label}
                                                </button>
                                            ))}
                                        </div>

                                        {/* Return Change / Due Banner */}
                                        {cashReceivedNum > 0 && (
                                            <div className="pt-0.5">
                                                {cashReceivedNum >= total ? (
                                                    <div className="bg-emerald-600 text-white p-2.5 rounded-lg flex items-center justify-between shadow-xs">
                                                        <span className="text-xs font-bold uppercase tracking-wider flex items-center gap-1">
                                                            💵 Return Change:
                                                        </span>
                                                        <span className="text-base font-black">
                                                            {currency}{changeReturnAmount.toFixed(2)}
                                                        </span>
                                                    </div>
                                                ) : (
                                                    <div className="bg-amber-500 text-white p-2.5 rounded-lg flex items-center justify-between shadow-xs">
                                                        <span className="text-xs font-bold uppercase tracking-wider">
                                                            ⚠️ Remaining Due:
                                                        </span>
                                                        <span className="text-sm font-bold">
                                                            {currency}{remainingDueAmount.toFixed(2)}
                                                        </span>
                                                    </div>
                                                )}
                                            </div>
                                        )}
                                    </div>
                                )}

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

            {/* Select Size / Variant Modal */}
            {sizeModalItem && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl max-w-sm w-full p-6 shadow-2xl relative">
                        <button 
                            onClick={() => setSizeModalItem(null)}
                            className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 p-1.5 rounded-full hover:bg-gray-100 transition-colors"
                        >
                            <X className="w-5 h-5" />
                        </button>

                        <div className="text-center mb-5">
                            {sizeModalItem.image ? (
                                <img src={`/storage/${sizeModalItem.image}`} alt={sizeModalItem.name} className="w-16 h-16 object-cover rounded-full mx-auto mb-2 border border-gray-100 shadow-xs" />
                            ) : (
                                <div className="text-4xl mb-2">🍽️</div>
                            )}
                            <h3 className="text-lg font-bold text-gray-900">{sizeModalItem.name}</h3>
                            <p className="text-xs text-purple-600 font-medium">Please select a size variant</p>
                        </div>

                        <div className="space-y-2.5 mb-5 max-h-60 overflow-y-auto pr-1">
                            {sizeModalItem.variants.map(variant => (
                                <button
                                    key={variant.id}
                                    onClick={() => addVariantToCart(sizeModalItem, variant)}
                                    className="w-full p-3.5 rounded-xl border border-gray-200 hover:border-primary hover:bg-primary/5 flex justify-between items-center transition-all group shadow-2xs"
                                >
                                    <span className="font-semibold text-gray-800 text-sm group-hover:text-primary">{variant.name}</span>
                                    <span className="font-bold text-primary text-base">{currency}{Number(variant.price).toFixed(2)}</span>
                                </button>
                            ))}
                        </div>

                        <Button
                            variant="outline"
                            className="w-full text-xs py-2 rounded-xl"
                            onClick={() => setSizeModalItem(null)}
                        >
                            Cancel
                        </Button>
                    </div>
                </div>
            )}

            {/* Receipt Modal */}
            {showReceipt && lastOrder && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4 print:bg-white print:p-0 print:block">
                    <div className="bg-white rounded-2xl w-full max-w-sm shadow-xl overflow-hidden print:shadow-none print:w-full print:max-w-none">
                        <div className="p-6 print:p-4">
                            <div className="text-center mb-6 border-b border-dashed border-gray-300 pb-6">
                                <h2 className="text-2xl font-bold mb-1">RESTAURANT RECEIPT</h2>
                                <p className="text-gray-500 text-sm">{lastOrder.date}</p>
                                <p className="text-gray-900 font-bold text-base mt-1">
                                    Order #{lastOrder.order_id} ({lastOrder.table})
                                </p>
                                <p className="text-xs font-semibold text-purple-700 bg-purple-50 px-2 py-1 rounded-md inline-block mt-1">
                                    Payment Method: {lastOrder.method || 'Cash'}
                                </p>
                                {lastOrder.customer && (
                                    <p className="text-gray-800 text-sm font-semibold mt-1">
                                        Customer: {lastOrder.customer}
                                    </p>
                                )}
                                {lastOrder.phone && (
                                    <p className="text-gray-800 text-xs font-medium">
                                        Phone: {lastOrder.phone}
                                    </p>
                                )}
                                {lastOrder.address && (
                                    <p className="text-gray-700 text-xs mt-1.5 bg-gray-50 p-2 rounded-lg border border-gray-200 text-left">
                                        <strong>Delivery Address:</strong><br />
                                        {lastOrder.address}
                                    </p>
                                )}
                            </div>
                            
                            <div className="space-y-3 mb-6">
                                {lastOrder.items.map((item, idx) => (
                                    <div key={idx} className="flex justify-between text-sm">
                                        <span>{item.qty}x {item.name}</span>
                                        <span>{currency}{(item.price * item.qty).toFixed(2)}</span>
                                    </div>
                                ))}
                            </div>

                            <div className="border-t border-dashed border-gray-300 pt-4 space-y-2 mb-4">
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
                                <div className="flex justify-between font-bold text-lg pt-2 border-b border-dashed border-gray-300 pb-2">
                                    <span>Total</span>
                                    <span>{currency}{lastOrder.total.toFixed(2)}</span>
                                </div>

                                {lastOrder.cash_received > 0 && (
                                    <>
                                        <div className="flex justify-between text-sm text-gray-700 font-semibold pt-1">
                                            <span>Paid ({lastOrder.method})</span>
                                            <span>{currency}{lastOrder.cash_received.toFixed(2)}</span>
                                        </div>
                                        <div className="flex justify-between text-sm text-emerald-700 font-bold bg-emerald-50 p-2 rounded-lg border border-emerald-200">
                                            <span>Change Returned</span>
                                            <span>{currency}{lastOrder.change_return.toFixed(2)}</span>
                                        </div>
                                    </>
                                )}
                            </div>

                            <div className="text-center text-sm text-gray-500 mb-2">
                                Paid via {lastOrder.method}
                            </div>

                            <div className="text-center text-[11px] font-black text-gray-400 mb-5 pt-2 border-t border-dashed border-gray-300 uppercase tracking-widest">
                                Powered by DineDesk
                            </div>

                            <div className="grid grid-cols-2 gap-2.5 print:hidden">
                                <Button className="flex justify-center items-center gap-1.5 bg-slate-800 hover:bg-slate-900 text-xs py-2.5 rounded-xl font-bold" onClick={printReceipt}>
                                    <Printer className="w-4 h-4" /> Print Receipt
                                </Button>
                                <Button className="flex justify-center items-center gap-1.5 bg-orange-600 hover:bg-orange-700 text-white text-xs py-2.5 rounded-xl font-bold" onClick={printKOT}>
                                    <Printer className="w-4 h-4" /> Print KOT
                                </Button>
                                <Button className="flex justify-center items-center gap-1.5 bg-purple-600 hover:bg-purple-700 text-white text-xs py-2.5 rounded-xl font-bold shadow-xs" onClick={printBoth}>
                                    <Printer className="w-4 h-4" /> Print Both (Cut)
                                </Button>
                                <Button variant="outline" className="flex justify-center items-center gap-1.5 text-xs py-2.5 rounded-xl font-semibold" onClick={() => setShowReceipt(false)}>
                                    <X className="w-4 h-4" /> Close
                                </Button>
                            </div>
                        </div>
                    </div>
                </div>
            )}

            {/* Table Selection & Open Bills Modal */}
            {showTableModal && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl w-full max-w-2xl shadow-2xl overflow-hidden max-h-[90vh] flex flex-col">
                        <div className="p-5 border-b border-gray-100 flex justify-between items-center bg-gray-50/80">
                            <div>
                                <h2 className="text-lg font-bold text-gray-900 flex items-center gap-2">
                                    <span>🪑 Select Dining Table / Open Bills</span>
                                </h2>
                                <p className="text-xs text-gray-500">Choose a free table or tap an active open bill to load it.</p>
                            </div>
                            <button onClick={() => setShowTableModal(false)} className="p-2 hover:bg-gray-200 rounded-full transition-colors">
                                <X className="w-5 h-5 text-gray-500" />
                            </button>
                        </div>
                        
                        <div className="p-6 overflow-y-auto flex-1 bg-gray-50/50">
                            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
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
                                                setShowTableModal(false);
                                            }}
                                            className={`p-3.5 rounded-2xl border text-left transition-all duration-200 shadow-sm relative flex flex-col justify-between min-h-[100px] ${
                                                isSelected 
                                                    ? 'bg-gradient-to-br from-orange-500 to-amber-600 text-white border-orange-600 shadow-md ring-4 ring-orange-400/30 scale-[1.02]' 
                                                    : isOpen 
                                                        ? 'bg-amber-500 text-white border-amber-600 hover:bg-amber-600 shadow-xs' 
                                                        : 'bg-white text-gray-900 border-gray-200 hover:border-orange-400 hover:bg-orange-50/50'
                                            }`}
                                        >
                                            <div className="flex items-center justify-between">
                                                <span className={`font-black text-sm ${isSelected || isOpen ? 'text-white' : 'text-gray-900'}`}>
                                                    Table {table.table_number}
                                                </span>
                                                <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full uppercase tracking-tight ${
                                                    isSelected || isOpen ? 'bg-white/20 text-white' : 'bg-gray-100 text-gray-600'
                                                }`}>
                                                    {isOpen ? 'Open' : table.status === 'occupied' ? 'Occupied' : 'Free'}
                                                </span>
                                            </div>

                                            {isOpen ? (
                                                <div className="mt-2">
                                                    <div className={`font-black text-base ${isSelected || isOpen ? 'text-white' : 'text-orange-800'}`}>
                                                        {currency}{bill.total.toFixed(2)}
                                                    </div>
                                                    <div className={`text-[10px] font-medium ${isSelected || isOpen ? 'text-white/90' : 'text-orange-700'}`}>
                                                        Tap to load bill
                                                    </div>
                                                </div>
                                            ) : (
                                                <div className={`text-[11px] mt-2 font-semibold ${isSelected ? 'text-white/90' : 'text-gray-500'}`}>
                                                    {isSelected ? '✓ Selected' : 'Tap to select'}
                                                </div>
                                            )}
                                        </button>
                                    );
                                })}
                            </div>

                            {tables.length === 0 && (
                                <div className="text-center py-12 text-gray-500">
                                    No dining tables created yet. Go to Tables settings to add tables.
                                </div>
                            )}
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

            {/* Mobile Floating Quick Cart Bar */}
            {mobileTab === 'menu' && cart.length > 0 && (
                <div className="lg:hidden fixed bottom-4 left-4 right-4 bg-gray-900 text-white rounded-2xl p-4 flex items-center justify-between shadow-2xl z-30 border border-gray-800">
                    <div>
                        <div className="text-xs text-gray-400 font-medium">{cart.reduce((sum, i) => sum + i.qty, 0)} item(s) in order</div>
                        <div className="text-lg font-extrabold text-white">{currency}{total.toFixed(2)}</div>
                    </div>
                    <button
                        onClick={() => setMobileTab('cart')}
                        className="bg-primary hover:bg-orange-600 text-white font-bold px-5 py-2.5 rounded-xl text-sm shadow-md transition-all flex items-center gap-2"
                    >
                        <span>Review & Pay</span>
                        <ShoppingCart className="w-4 h-4" />
                    </button>
                </div>
            )}
        </AdminLayout>
    );
}
