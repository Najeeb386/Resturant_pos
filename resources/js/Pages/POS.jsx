import React, { useState, useEffect } from 'react';
import AdminLayout from '../Layouts/AdminLayout';
import { Card, CardContent } from '../Components/ui/Card';
import { Button } from '../Components/ui/Button';
import { Search, ShoppingCart, Trash2, Plus, Minus, CreditCard, Banknote, QrCode, Printer, X, Loader2 } from 'lucide-react';
import { useForm, router } from '@inertiajs/react';

export default function POS({ categories = [], menuItems = [], tables = [], restaurant = {}, flash = {} }) {
    const [activeCategory, setActiveCategory] = useState('All');
    const [cart, setCart] = useState([]);
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedTable, setSelectedTable] = useState('');
    const [showReceipt, setShowReceipt] = useState(false);
    const [lastOrder, setLastOrder] = useState(null);

    const { data, setData, post, processing, reset } = useForm({
        table_id: '',
        cart: [],
        subtotal: 0,
        tax: 0,
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
    const total = subtotal + tax;
    const currency = restaurant.currency_symbol || '$';

    useEffect(() => {
        setData({
            ...data,
            cart: cart,
            subtotal: subtotal,
            tax: tax,
            total: total,
            table_id: selectedTable || null
        });
    }, [cart, subtotal, tax, total, selectedTable]);

    const handleCheckout = (method) => {
        setData('payment_method', method);
        
        post('/pos/checkout', {
            onSuccess: (page) => {
                setLastOrder({
                    items: [...cart],
                    subtotal,
                    tax,
                    total,
                    method,
                    table: tables.find(t => t.id == selectedTable)?.table_number || 'Takeaway',
                    order_id: page.props.flash.order_id,
                    date: new Date().toLocaleString()
                });
                setCart([]);
                setSelectedTable('');
                setShowReceipt(true);
            }
        });
    };

    const handlePrint = () => {
        window.print();
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
                    <div className="p-4 border-b border-gray-100 bg-gray-50">
                        <div className="flex items-center justify-between mb-3">
                            <h2 className="font-bold text-lg flex items-center gap-2">
                                <ShoppingCart className="w-5 h-5 text-primary" />
                                Current Order
                            </h2>
                            <span className="bg-primary/10 text-primary px-3 py-1 rounded-full text-sm font-bold">
                                {cart.length} items
                            </span>
                        </div>
                        <select
                            value={selectedTable}
                            onChange={(e) => setSelectedTable(e.target.value)}
                            className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary bg-white text-sm"
                        >
                            <option value="">Takeaway / Select Table</option>
                            {tables.filter(t => t.status !== 'occupied').map(t => (
                                <option key={t.id} value={t.id}>Table {t.table_number}</option>
                            ))}
                        </select>
                    </div>

                    {/* Cart Items */}
                    <div className="flex-1 overflow-y-auto p-4 space-y-4">
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

                    {/* Totals & Payment */}
                    <div className="p-4 border-t border-gray-100 bg-gray-50/50">
                        <div className="space-y-2 mb-4">
                            <div className="flex justify-between text-gray-500 text-sm">
                                <span>Subtotal</span>
                                <span>{currency}{subtotal.toFixed(2)}</span>
                            </div>
                            <div className="flex justify-between text-gray-500 text-sm">
                                <span>Tax ({restaurant.tax_percentage || 10}%)</span>
                                <span>{currency}{tax.toFixed(2)}</span>
                            </div>
                            <div className="flex justify-between font-bold text-xl pt-2 border-t border-gray-200 text-gray-900">
                                <span>Total</span>
                                <span>{currency}{total.toFixed(2)}</span>
                            </div>
                        </div>

                        <div className="grid grid-cols-3 gap-2 mb-3">
                            <Button 
                                variant="outline" 
                                className="flex flex-col gap-1 items-center h-auto py-3 hover:bg-primary/5 hover:border-primary"
                                onClick={() => handleCheckout('Cash')}
                                disabled={cart.length === 0 || processing}
                            >
                                {processing && data.payment_method === 'Cash' ? (
                                    <Loader2 className="w-5 h-5 animate-spin" />
                                ) : (
                                    <Banknote className="w-5 h-5" />
                                )}
                                <span className="text-xs">Cash</span>
                            </Button>
                            <Button 
                                variant="outline" 
                                className="flex flex-col gap-1 items-center h-auto py-3 hover:bg-primary/5 hover:border-primary"
                                onClick={() => handleCheckout('Card')}
                                disabled={cart.length === 0 || processing}
                            >
                                {processing && data.payment_method === 'Card' ? (
                                    <Loader2 className="w-5 h-5 animate-spin" />
                                ) : (
                                    <CreditCard className="w-5 h-5" />
                                )}
                                <span className="text-xs">Card</span>
                            </Button>
                            <Button 
                                variant="outline" 
                                className="flex flex-col gap-1 items-center h-auto py-3 hover:bg-primary/5 hover:border-primary"
                                onClick={() => handleCheckout('QR Pay')}
                                disabled={cart.length === 0 || processing}
                            >
                                {processing && data.payment_method === 'QR Pay' ? (
                                    <Loader2 className="w-5 h-5 animate-spin" />
                                ) : (
                                    <QrCode className="w-5 h-5" />
                                )}
                                <span className="text-xs">QR Pay</span>
                            </Button>
                        </div>
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
                                <p className="text-gray-500 text-sm">Order #{lastOrder.order_id} | Table: {lastOrder.table}</p>
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
                                <div className="flex justify-between font-bold text-lg pt-2">
                                    <span>Total</span>
                                    <span>{currency}{lastOrder.total.toFixed(2)}</span>
                                </div>
                            </div>

                            <div className="text-center text-sm text-gray-500 mb-6">
                                Paid via {lastOrder.method}
                            </div>

                            <div className="flex gap-3 print:hidden">
                                <Button className="flex-1 flex justify-center gap-2" onClick={handlePrint}>
                                    <Printer className="w-4 h-4" /> Print
                                </Button>
                                <Button variant="outline" className="flex-1" onClick={() => setShowReceipt(false)}>
                                    <X className="w-4 h-4" /> Close
                                </Button>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </AdminLayout>
    );
}
