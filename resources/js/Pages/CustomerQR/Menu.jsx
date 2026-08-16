import React, { useState, useMemo } from 'react';
import { Head, useForm } from '@inertiajs/react';
import { 
    UtensilsCrossed, 
    Search, 
    ShoppingCart, 
    Plus, 
    Minus, 
    CheckCircle2, 
    ChevronRight, 
    X, 
    Clock, 
    AlertTriangle,
    ChefHat,
    Sparkles,
    PhoneCall
} from 'lucide-react';

export default function CustomerMenu({ restaurant, table, categories = [], hasQrOrdering = true, flash = {} }) {
    const [selectedCategory, setSelectedCategory] = useState('all');
    const [searchQuery, setSearchQuery] = useState('');
    const [cart, setCart] = useState([]);
    const [isCartOpen, setIsCartOpen] = useState(false);
    const [placedOrder, setPlacedOrder] = useState(flash?.order || null);

    const currencySymbol = restaurant?.currency_symbol || '$';
    const taxPercentage = restaurant?.tax_percentage || 0;

    // Checkout Form
    const { data, setData, post, processing, errors } = useForm({
        restaurant_id: restaurant?.id || '',
        table_id: table?.id || '',
        customer_name: '',
        customer_phone: '',
        notes: '',
        items: [],
    });

    // Flatten all items
    const allItems = useMemo(() => {
        let items = [];
        categories.forEach(cat => {
            if (cat.menu_items && Array.isArray(cat.menu_items)) {
                cat.menu_items.forEach(item => {
                    items.push({ ...item, category_id: cat.id, category_name: cat.name });
                });
            }
        });
        return items;
    }, [categories]);

    // Filter items by category & search
    const filteredItems = useMemo(() => {
        return allItems.filter(item => {
            const matchesCategory = selectedCategory === 'all' || item.category_id === Number(selectedCategory);
            const matchesSearch = !searchQuery || 
                item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                (item.description && item.description.toLowerCase().includes(searchQuery.toLowerCase()));
            return matchesCategory && matchesSearch;
        });
    }, [allItems, selectedCategory, searchQuery]);

    // Cart Actions
    const addToCart = (item) => {
        setCart(prev => {
            const existingIndex = prev.findIndex(i => i.menu_item_id === item.id);
            if (existingIndex > -1) {
                const updated = [...prev];
                updated[existingIndex].quantity += 1;
                return updated;
            } else {
                return [...prev, {
                    menu_item_id: item.id,
                    name: item.name,
                    unit_price: Number(item.price),
                    quantity: 1,
                    image: item.image,
                    notes: '',
                }];
            }
        });
    };

    const updateQuantity = (itemId, delta) => {
        setCart(prev => {
            return prev.map(i => {
                if (i.menu_item_id === itemId) {
                    const newQty = i.quantity + delta;
                    return newQty > 0 ? { ...i, quantity: newQty } : null;
                }
                return i;
            }).filter(Boolean);
        });
    };

    const getItemQuantityInCart = (itemId) => {
        const found = cart.find(i => i.menu_item_id === itemId);
        return found ? found.quantity : 0;
    };

    // Calculate totals
    const cartSubtotal = useMemo(() => {
        return cart.reduce((sum, item) => sum + (item.unit_price * item.quantity), 0);
    }, [cart]);

    const cartTax = useMemo(() => {
        return (cartSubtotal * taxPercentage) / 100;
    }, [cartSubtotal, taxPercentage]);

    const cartTotal = cartSubtotal + cartTax;
    const totalCartItemsCount = cart.reduce((sum, i) => sum + i.quantity, 0);

    // Handle Submit Checkout
    const handleCheckout = (e) => {
        e.preventDefault();
        if (cart.length === 0) return;

        const formattedItems = cart.map(item => ({
            menu_item_id: item.menu_item_id,
            quantity: item.quantity,
            unit_price: item.unit_price,
            notes: item.notes || null,
        }));

        post('/table-order/checkout', {
            data: {
                ...data,
                items: formattedItems,
            },
            onSuccess: (page) => {
                setCart([]);
                setIsCartOpen(false);
                if (page.props.flash?.order) {
                    setPlacedOrder(page.props.flash.order);
                }
            },
        });
    };

    return (
        <div className="min-h-screen bg-slate-50 font-sans text-slate-800 pb-28">
            <Head title={`${restaurant?.name} - Table ${table?.table_number} Menu`} />

            {/* Header Banner */}
            <div className="bg-gradient-to-r from-orange-600 to-amber-600 text-white sticky top-0 z-30 shadow-md">
                <div className="max-w-md mx-auto px-4 py-3 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        {restaurant?.logo ? (
                            <img src={`/storage/${restaurant.logo}`} alt="Logo" className="w-10 h-10 rounded-full object-cover border-2 border-white/80" />
                        ) : (
                            <div className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-xs flex items-center justify-center font-bold text-lg">
                                <UtensilsCrossed className="w-5 h-5 text-white" />
                            </div>
                        )}
                        <div>
                            <h1 className="font-bold text-base leading-tight drop-shadow-xs">{restaurant?.name}</h1>
                            <div className="flex items-center gap-1.5 text-xs text-orange-100 font-medium">
                                <span className="inline-block w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
                                Table #{table?.table_number}
                            </div>
                        </div>
                    </div>

                    <div className="flex items-center gap-2">
                        <button 
                            onClick={() => setIsCartOpen(true)}
                            className="relative p-2 bg-white/20 hover:bg-white/30 backdrop-blur-md rounded-full text-white transition-all active:scale-95"
                        >
                            <ShoppingCart className="w-5 h-5" />
                            {totalCartItemsCount > 0 && (
                                <span className="absolute -top-1 -right-1 bg-white text-orange-600 font-extrabold text-[10px] w-5 h-5 rounded-full flex items-center justify-center shadow-md animate-bounce">
                                    {totalCartItemsCount}
                                </span>
                            )}
                        </button>
                    </div>
                </div>
            </div>

            {/* Main Content Container */}
            <div className="max-w-md mx-auto px-4 pt-4">
                {/* Disabled Plan Notice */}
                {!hasQrOrdering && (
                    <div className="mb-4 bg-amber-50 border border-amber-200 rounded-2xl p-4 flex items-start gap-3 shadow-xs">
                        <AlertTriangle className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
                        <div className="text-xs text-amber-800 leading-relaxed">
                            <strong className="font-bold block text-sm text-amber-900 mb-0.5">Self-Ordering Temporarily Disabled</strong>
                            Digital QR self-ordering is currently inactive for this restaurant. Please request a waiter for assistance.
                        </div>
                    </div>
                )}

                {/* Live Search Bar */}
                <div className="relative mb-4">
                    <Search className="w-4 h-4 absolute left-3.5 top-3 text-slate-400" />
                    <input 
                        type="text" 
                        value={searchQuery} 
                        onChange={(e) => setSearchQuery(e.target.value)}
                        placeholder="Search delicious food items..." 
                        className="w-full bg-white border border-slate-200 rounded-xl py-2.5 pl-10 pr-4 text-sm text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500 transition-all shadow-xs"
                    />
                    {searchQuery && (
                        <button onClick={() => setSearchQuery('')} className="absolute right-3 top-3 text-slate-400 hover:text-slate-600">
                            <X className="w-4 h-4" />
                        </button>
                    )}
                </div>

                {/* Category Pills Slider */}
                <div className="flex items-center gap-2 overflow-x-auto pb-3 mb-2 no-scrollbar">
                    <button 
                        onClick={() => setSelectedCategory('all')}
                        className={`px-4 py-2 rounded-xl text-xs font-bold whitespace-nowrap transition-all ${
                            selectedCategory === 'all' 
                                ? 'bg-orange-500 text-white shadow-md shadow-orange-500/30' 
                                : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
                        }`}
                    >
                        All Categories
                    </button>
                    {categories.map(cat => (
                        <button 
                            key={cat.id}
                            onClick={() => setSelectedCategory(cat.id)}
                            className={`px-4 py-2 rounded-xl text-xs font-bold whitespace-nowrap transition-all ${
                                String(selectedCategory) === String(cat.id) 
                                    ? 'bg-orange-500 text-white shadow-md shadow-orange-500/30' 
                                    : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
                            }`}
                        >
                            {cat.name}
                        </button>
                    ))}
                </div>

                {/* Menu Items List */}
                <div className="space-y-3">
                    {filteredItems.map(item => {
                        const qty = getItemQuantityInCart(item.id);

                        return (
                            <div key={item.id} className="bg-white border border-slate-100 rounded-2xl p-3 shadow-xs hover:shadow-md transition-all flex items-center justify-between gap-3">
                                {item.image ? (
                                    <img src={`/storage/${item.image}`} alt={item.name} className="w-20 h-20 rounded-xl object-cover shrink-0 border border-slate-100" />
                                ) : (
                                    <div className="w-20 h-20 rounded-xl bg-orange-50 flex items-center justify-center shrink-0 border border-orange-100 text-orange-400">
                                        <UtensilsCrossed className="w-8 h-8" />
                                    </div>
                                )}

                                <div className="flex-1 min-w-0">
                                    <div className="flex items-center gap-1.5 mb-0.5">
                                        <h3 className="font-bold text-slate-900 text-sm truncate">{item.name}</h3>
                                    </div>
                                    {item.description && (
                                        <p className="text-xs text-slate-500 line-clamp-2 mb-2 leading-relaxed">{item.description}</p>
                                    )}
                                    <div className="text-sm font-extrabold text-orange-600">
                                        {currencySymbol}{Number(item.price).toFixed(2)}
                                    </div>
                                </div>

                                {/* Add / Qty Controls */}
                                {hasQrOrdering && (
                                    <div className="shrink-0">
                                        {qty === 0 ? (
                                            <button 
                                                onClick={() => addToCart(item)}
                                                className="bg-orange-500 hover:bg-orange-600 text-white text-xs font-bold px-3 py-2 rounded-xl flex items-center gap-1 shadow-sm active:scale-95 transition-all"
                                            >
                                                <Plus className="w-3.5 h-3.5" /> Add
                                            </button>
                                        ) : (
                                            <div className="flex items-center bg-orange-50 border border-orange-200 rounded-xl p-1 gap-2">
                                                <button 
                                                    onClick={() => updateQuantity(item.id, -1)}
                                                    className="w-6 h-6 bg-white rounded-lg flex items-center justify-center text-orange-600 font-bold shadow-xs active:scale-90"
                                                >
                                                    <Minus className="w-3 h-3" />
                                                </button>
                                                <span className="text-xs font-extrabold text-orange-700 w-4 text-center">{qty}</span>
                                                <button 
                                                    onClick={() => updateQuantity(item.id, 1)}
                                                    className="w-6 h-6 bg-orange-500 text-white rounded-lg flex items-center justify-center font-bold shadow-xs active:scale-90"
                                                >
                                                    <Plus className="w-3 h-3" />
                                                </button>
                                            </div>
                                        )}
                                    </div>
                                )}
                            </div>
                        );
                    })}

                    {filteredItems.length === 0 && (
                        <div className="text-center py-12 bg-white border border-dashed border-slate-200 rounded-2xl p-6">
                            <Sparkles className="w-8 h-8 text-orange-400 mx-auto mb-2 opacity-60" />
                            <h4 className="font-bold text-slate-800 text-sm">No items found</h4>
                            <p className="text-xs text-slate-400 mt-1">Try searching for something else or pick a different category.</p>
                        </div>
                    )}
                </div>
            </div>

            {/* Bottom Floating Cart Bar */}
            {hasQrOrdering && totalCartItemsCount > 0 && !isCartOpen && (
                <div className="fixed bottom-4 left-0 right-0 z-40 px-4">
                    <div className="max-w-md mx-auto bg-slate-900 text-white rounded-2xl p-3.5 shadow-xl flex items-center justify-between border border-slate-800 backdrop-blur-md animate-fade-in-up">
                        <div className="flex items-center gap-3">
                            <div className="bg-orange-500 text-white w-9 h-9 rounded-xl flex items-center justify-center font-extrabold text-xs shadow-sm">
                                {totalCartItemsCount}
                            </div>
                            <div>
                                <div className="text-[11px] text-slate-400 font-medium">Order Subtotal</div>
                                <div className="text-sm font-bold text-white">{currencySymbol}{cartSubtotal.toFixed(2)}</div>
                            </div>
                        </div>

                        <button 
                            onClick={() => setIsCartOpen(true)}
                            className="bg-orange-500 hover:bg-orange-600 text-white font-bold text-xs px-4 py-2.5 rounded-xl flex items-center gap-1.5 shadow-md active:scale-95 transition-all"
                        >
                            View Order <ChevronRight className="w-4 h-4" />
                        </button>
                    </div>
                </div>
            )}

            {/* Cart & Checkout Drawer Modal */}
            {isCartOpen && (
                <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-end sm:items-center justify-center p-0 sm:p-4">
                    <div className="bg-white w-full max-w-md rounded-t-3xl sm:rounded-3xl shadow-2xl max-h-[90vh] flex flex-col overflow-hidden animate-slide-up">
                        {/* Drawer Header */}
                        <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/80">
                            <div>
                                <h2 className="font-bold text-slate-900 text-base">Your Table Order</h2>
                                <div className="text-xs text-orange-600 font-semibold">{restaurant?.name} • Table #{table?.table_number}</div>
                            </div>
                            <button onClick={() => setIsCartOpen(false)} className="p-2 text-slate-400 hover:text-slate-600 rounded-full hover:bg-slate-100">
                                <X className="w-5 h-5" />
                            </button>
                        </div>

                        {/* Cart Items List */}
                        <form onSubmit={handleCheckout} className="flex-1 overflow-y-auto p-6 space-y-4">
                            <div className="space-y-3 max-h-60 overflow-y-auto pr-1">
                                {cart.map(item => (
                                    <div key={item.menu_item_id} className="flex items-center justify-between gap-3 border-b border-slate-100 pb-3">
                                        <div className="flex-1 min-w-0">
                                            <div className="font-bold text-xs text-slate-900 truncate">{item.name}</div>
                                            <div className="text-xs text-slate-500">{currencySymbol}{item.unit_price.toFixed(2)} each</div>
                                        </div>

                                        <div className="flex items-center gap-2 bg-slate-100 rounded-lg p-1">
                                            <button 
                                                type="button" 
                                                onClick={() => updateQuantity(item.menu_item_id, -1)}
                                                className="w-5 h-5 bg-white text-slate-700 rounded flex items-center justify-center font-bold text-xs shadow-xs"
                                            >
                                                -
                                            </button>
                                            <span className="text-xs font-bold w-4 text-center">{item.quantity}</span>
                                            <button 
                                                type="button" 
                                                onClick={() => updateQuantity(item.menu_item_id, 1)}
                                                className="w-5 h-5 bg-orange-500 text-white rounded flex items-center justify-center font-bold text-xs shadow-xs"
                                            >
                                                +
                                            </button>
                                        </div>

                                        <div className="font-extrabold text-xs text-slate-800 shrink-0">
                                            {currencySymbol}{(item.unit_price * item.quantity).toFixed(2)}
                                        </div>
                                    </div>
                                ))}
                            </div>

                            {/* Customer Information (Optional) */}
                            <div className="space-y-3 pt-2">
                                <div>
                                    <label className="block text-xs font-bold text-slate-700 mb-1">Your Name (Optional)</label>
                                    <input 
                                        type="text" 
                                        value={data.customer_name} 
                                        onChange={e => setData('customer_name', e.target.value)}
                                        placeholder="e.g. Alex" 
                                        className="w-full text-xs border border-slate-200 rounded-xl px-3 py-2 focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500 outline-none"
                                    />
                                </div>

                                <div>
                                    <label className="block text-xs font-bold text-slate-700 mb-1">Special Cooking Requests / Notes</label>
                                    <textarea 
                                        rows="2"
                                        value={data.notes} 
                                        onChange={e => setData('notes', e.target.value)}
                                        placeholder="e.g. Less spicy, extra napkins..." 
                                        className="w-full text-xs border border-slate-200 rounded-xl px-3 py-2 focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500 outline-none"
                                    ></textarea>
                                </div>
                            </div>

                            {/* Price Breakdown */}
                            <div className="bg-slate-50 border border-slate-100 rounded-xl p-3.5 space-y-1.5 text-xs">
                                <div className="flex justify-between text-slate-600">
                                    <span>Subtotal</span>
                                    <span className="font-semibold">{currencySymbol}{cartSubtotal.toFixed(2)}</span>
                                </div>
                                {taxPercentage > 0 && (
                                    <div className="flex justify-between text-slate-600">
                                        <span>Tax ({taxPercentage}%)</span>
                                        <span className="font-semibold">{currencySymbol}{cartTax.toFixed(2)}</span>
                                    </div>
                                )}
                                <div className="flex justify-between text-sm font-extrabold text-slate-900 pt-2 border-t border-slate-200">
                                    <span>Total Payable</span>
                                    <span className="text-orange-600">{currencySymbol}{cartTotal.toFixed(2)}</span>
                                </div>
                            </div>

                            <button 
                                type="submit" 
                                disabled={processing}
                                className="w-full bg-orange-500 hover:bg-orange-600 disabled:opacity-50 text-white font-bold text-sm py-3 rounded-xl shadow-lg shadow-orange-500/30 flex items-center justify-center gap-2 active:scale-98 transition-all"
                            >
                                {processing ? 'Sending to Kitchen...' : 'Send Order to Kitchen'}
                            </button>
                        </form>
                    </div>
                </div>
            )}

            {/* Placed Order Confirmation Modal */}
            {placedOrder && (
                <div className="fixed inset-0 z-50 bg-slate-900/70 backdrop-blur-xs flex items-center justify-center p-4">
                    <div className="bg-white w-full max-w-sm rounded-3xl p-6 text-center shadow-2xl animate-scale-up">
                        <div className="w-16 h-16 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto mb-4 shadow-inner">
                            <CheckCircle2 className="w-10 h-10 animate-bounce" />
                        </div>

                        <h3 className="text-xl font-extrabold text-slate-900 mb-1">Order Sent to Kitchen!</h3>
                        <p className="text-xs text-slate-500 mb-4">Your order has been received and is being prepared.</p>

                        <div className="bg-slate-50 rounded-2xl p-4 border border-slate-100 mb-6 text-left space-y-2">
                            <div className="flex justify-between text-xs text-slate-500">
                                <span>Order Number</span>
                                <span className="font-bold text-slate-800">{placedOrder.order_number}</span>
                            </div>
                            <div className="flex justify-between text-xs text-slate-500">
                                <span>Table</span>
                                <span className="font-bold text-slate-800">Table #{table?.table_number}</span>
                            </div>
                            <div className="flex justify-between text-xs text-slate-500">
                                <span>Total</span>
                                <span className="font-extrabold text-orange-600">{currencySymbol}{Number(placedOrder.total).toFixed(2)}</span>
                            </div>
                        </div>

                        <button 
                            onClick={() => setPlacedOrder(null)}
                            className="w-full bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs py-3 rounded-xl shadow-md transition-all"
                        >
                            Back to Menu
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
}
