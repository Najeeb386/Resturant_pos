import React, { useState, useEffect, useRef } from 'react';
import AdminLayout from '../Layouts/AdminLayout';
import { Card, CardContent } from '../Components/ui/Card';
import { Badge } from '../Components/ui/Badge';
import { Button } from '../Components/ui/Button';
import { Check, Clock, Utensils, Loader2, Volume2, Search, Filter, AlertTriangle, CheckCircle2, Sparkles } from 'lucide-react';
import { router } from '@inertiajs/react';

export default function Kitchen({ orders: initialOrders = [] }) {
    const [orders, setOrders] = useState(initialOrders);
    const [updatingId, setUpdatingId] = useState(null);
    const [soundEnabled, setSoundEnabled] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState('All');
    const prevOrderIdsRef = useRef(initialOrders.map(o => o.id));

    // Audio chime helper using Web Audio API (no external asset needed)
    const playNewOrderSound = () => {
        try {
            const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            
            osc.type = 'sine';
            osc.frequency.setValueAtTime(587.33, audioCtx.currentTime); // D5
            osc.frequency.exponentialRampToValueAtTime(880, audioCtx.currentTime + 0.15); // A5
            
            gain.gain.setValueAtTime(0.3, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.5);
            
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            
            osc.start();
            osc.stop(audioCtx.currentTime + 0.5);
        } catch (e) {
            console.log("Audio notification context blocked by browser autoplay policy.");
        }
    };

    // Keep state updated if Inertia props change
    useEffect(() => {
        setOrders(initialOrders);
    }, [initialOrders]);

    // High-frequency 2-second real-time polling loop
    useEffect(() => {
        const fetchLiveOrders = async () => {
            try {
                const res = await fetch('/kitchen/live-orders', {
                    headers: {
                        'Accept': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest'
                    }
                });
                if (res.ok) {
                    const data = await res.json();
                    if (data && data.orders) {
                        const newOrderIds = data.orders.map(o => o.id);
                        const hasNewOrder = newOrderIds.some(id => !prevOrderIdsRef.current.includes(id));
                        
                        if (hasNewOrder && soundEnabled) {
                            playNewOrderSound();
                        }
                        
                        prevOrderIdsRef.current = newOrderIds;
                        setOrders(data.orders);
                    }
                }
            } catch (err) {
                // Fallback to Inertia reload if fetch encounters error
                router.reload({
                    only: ['orders'],
                    preserveScroll: true,
                    preserveState: true
                });
            }
        };

        const interval = setInterval(fetchLiveOrders, 2000); // 2 seconds fast sync
        return () => clearInterval(interval);
    }, [soundEnabled]);

    const updateStatus = (id, newStatus) => {
        setUpdatingId(id);
        router.post(`/kitchen/${id}/status`, { status: newStatus }, {
            preserveScroll: true,
            onSuccess: () => {
                setOrders(prev => prev.map(o => o.id === id ? { ...o, status: newStatus } : o).filter(o => o.status !== 'completed'));
            },
            onFinish: () => setUpdatingId(null)
        });
    };

    const handleConfirmUpdate = (id) => {
        setUpdatingId(id);
        router.post(`/kitchen/${id}/confirm-update`, {}, {
            preserveScroll: true,
            onSuccess: () => {
                setOrders(prev => prev.map(o => o.id === id ? { 
                    ...o, 
                    is_updated: false,
                    items: o.items.map(item => ({ ...item, is_new: false }))
                } : o));
            },
            onFinish: () => setUpdatingId(null)
        });
    };

    const updatedCount = orders.filter(o => o.is_updated).length;
    const draftCount = orders.filter(o => o.status === 'draft' || o.status === 'pending').length;
    const preparingCount = orders.filter(o => o.status === 'preparing').length;

    // Filter orders in real-time
    const filteredOrders = orders.filter(order => {
        const statusMatch = statusFilter === 'All' || 
            (statusFilter === 'updated' && order.is_updated) ||
            (statusFilter === 'draft' && (order.status === 'draft' || order.status === 'pending')) ||
            (statusFilter === 'preparing' && order.status === 'preparing');
        const query = searchQuery.toLowerCase().trim();
        if (!query) return statusMatch;

        const idMatch = order.id.toString().includes(query) || (`#${order.id}`).includes(query);
        const tableMatch = order.table && order.table.toLowerCase().includes(query);
        const itemMatch = order.items && order.items.some(item => item.name && item.name.toLowerCase().includes(query));

        return statusMatch && (idMatch || tableMatch || itemMatch);
    });

    return (
        <AdminLayout>
            <div className="mb-6 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-white p-5 rounded-2xl border border-gray-100 shadow-xs">
                <div>
                    <div className="flex items-center gap-2 mb-1">
                        <h1 className="text-2xl font-bold text-gray-900">Kitchen Display System</h1>
                        <span className="flex items-center gap-1.5 px-3 py-1 bg-green-50 text-green-700 text-xs font-semibold rounded-full border border-green-200">
                            <span className="w-2 h-2 rounded-full bg-green-500 animate-ping"></span>
                            Live Auto-Sync Active
                        </span>
                    </div>
                    <p className="text-gray-500 text-sm">Updated table orders display at top • Newly added items are highlighted with a NEW badge.</p>
                </div>

                <div className="flex flex-wrap items-center gap-4 w-full sm:w-auto justify-between sm:justify-end">
                    <button
                        onClick={() => setSoundEnabled(!soundEnabled)}
                        className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold border transition-colors ${
                            soundEnabled ? 'bg-orange-50 text-orange-600 border-orange-200' : 'bg-gray-50 text-gray-400 border-gray-200'
                        }`}
                        title="Toggle sound chime for new orders"
                    >
                        <Volume2 className="w-4 h-4" />
                        {soundEnabled ? 'Chime Alert On' : 'Chime Alert Muted'}
                    </button>

                    <div className="flex items-center gap-4 border-l border-gray-200 pl-4">
                        {updatedCount > 0 && (
                            <div className="flex items-center gap-2">
                                <div className="w-3 h-3 rounded-full bg-purple-600 animate-bounce"></div>
                                <span className="text-sm font-bold text-purple-700">Updated ({updatedCount})</span>
                            </div>
                        )}
                        <div className="flex items-center gap-2">
                            <div className="w-3 h-3 rounded-full bg-red-500"></div>
                            <span className="text-sm font-semibold text-gray-700">Open ({draftCount})</span>
                        </div>
                        <div className="flex items-center gap-2">
                            <div className="w-3 h-3 rounded-full bg-orange-500"></div>
                            <span className="text-sm font-semibold text-gray-700">Preparing ({preparingCount})</span>
                        </div>
                    </div>
                </div>
            </div>

            {/* Search and Status Filter Bar */}
            <div className="bg-white p-4 rounded-2xl shadow-xs border border-gray-100 mb-6 flex flex-col sm:flex-row gap-4 items-center justify-between">
                <div className="relative w-full sm:w-96">
                    <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                    <input 
                        type="text"
                        placeholder="Search by Order #, Table, or Item name..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full pl-10 pr-4 py-2 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary text-sm transition-all"
                    />
                </div>

                <div className="flex items-center gap-2 w-full sm:w-auto">
                    <Filter className="w-4 h-4 text-gray-400 shrink-0" />
                    <select
                        value={statusFilter}
                        onChange={(e) => setStatusFilter(e.target.value)}
                        className="w-full sm:w-48 px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 bg-white"
                    >
                        <option value="All">All Statuses</option>
                        {updatedCount > 0 && <option value="updated">⚠️ Updated Tickets ({updatedCount})</option>}
                        <option value="draft">Open Bills / New</option>
                        <option value="preparing">Preparing Only</option>
                    </select>
                </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-6">
                {filteredOrders.map(order => (
                    <Card key={order.id} className={`border-t-4 shadow-xs hover:shadow-md transition-all ${
                        order.is_updated 
                            ? 'border-t-purple-600 bg-purple-50/20 ring-2 ring-purple-400/50 shadow-md' 
                            : order.status === 'draft' || order.status === 'pending' 
                                ? 'border-t-red-500 bg-red-50/10' 
                                : 'border-t-orange-500 bg-orange-50/10'
                    }`}>
                        <CardContent className="p-5 flex flex-col h-full">
                            <div className="flex justify-between items-start mb-3">
                                <div>
                                    <div className="flex items-center gap-2 flex-wrap">
                                        <h3 className="font-extrabold text-xl text-gray-900">#{order.id}</h3>
                                        {order.is_updated ? (
                                            <span className="text-[11px] bg-purple-600 text-white font-extrabold px-2.5 py-0.5 rounded-md animate-pulse flex items-center gap-1">
                                                <AlertTriangle className="w-3 h-3" />
                                                ITEMS ADDED
                                            </span>
                                        ) : (order.status === 'draft' || order.status === 'pending') && (
                                            <span className="text-xs bg-red-100 text-red-700 font-bold px-2 py-0.5 rounded-md animate-pulse">
                                                {order.status === 'draft' ? 'TABLE DRAFT' : 'NEW'}
                                            </span>
                                        )}
                                    </div>
                                    <p className="text-gray-600 font-semibold text-sm mt-0.5">{order.table}</p>
                                </div>
                                <div className="text-right">
                                    <Badge variant={order.is_updated ? 'primary' : order.status === 'draft' || order.status === 'pending' ? 'danger' : 'warning'} className="mb-1">
                                        {order.is_updated ? 'UPDATED' : order.status === 'draft' ? 'OPEN BILL' : order.status.toUpperCase()}
                                    </Badge>
                                    <div className="flex items-center justify-end text-gray-500 text-xs gap-1 font-medium mt-1">
                                        <Clock className="w-3.5 h-3.5" />
                                        {order.time}
                                    </div>
                                </div>
                            </div>

                            {/* Alert banner for updated orders */}
                            {order.is_updated && (
                                <div className="mb-3 p-2.5 bg-purple-100/80 border border-purple-200 rounded-xl text-xs font-semibold text-purple-900 flex items-center justify-between">
                                    <span>New items added to this table!</span>
                                    <Button
                                        size="sm"
                                        className="bg-purple-700 hover:bg-purple-800 text-white text-[11px] px-2.5 py-1 rounded-lg flex items-center gap-1 shadow-xs"
                                        onClick={() => handleConfirmUpdate(order.id)}
                                        disabled={updatingId === order.id}
                                    >
                                        {updatingId === order.id ? <Loader2 className="w-3 h-3 animate-spin" /> : <CheckCircle2 className="w-3 h-3" />}
                                        Confirm Changes
                                    </Button>
                                </div>
                            )}

                            <div className="space-y-2 mb-6 bg-white p-3 rounded-xl border border-gray-100 shadow-2xs flex-1">
                                {order.items.map((item, idx) => (
                                    <div 
                                        key={idx} 
                                        className={`flex justify-between items-center text-sm p-1.5 rounded-lg transition-all ${
                                            item.is_new ? 'bg-purple-50 border border-purple-200' : ''
                                        }`}
                                    >
                                        <div className="flex items-center gap-2 flex-wrap">
                                            <span className={`font-extrabold text-xs px-2 py-0.5 rounded-md ${
                                                item.is_new ? 'bg-purple-600 text-white' : 'bg-gray-100 text-gray-900'
                                            }`}>
                                                {item.qty}x
                                            </span>

                                            {item.is_new && (
                                                <span className="text-[10px] bg-purple-600 text-white font-black px-1.5 py-0.5 rounded-md uppercase tracking-wider animate-pulse flex items-center gap-0.5">
                                                    <Sparkles className="w-2.5 h-2.5" />
                                                    NEW
                                                </span>
                                            )}

                                            <span className={`${item.is_new ? 'text-purple-950 font-extrabold' : 'text-gray-800 font-semibold'}`}>
                                                {item.name}
                                            </span>
                                        </div>
                                    </div>
                                ))}
                            </div>

                            <div className="flex gap-3 mt-auto">
                                {(order.status === 'draft' || order.status === 'pending') && (
                                    <Button 
                                        className="w-full flex justify-center items-center gap-2 bg-orange-500 hover:bg-orange-600 text-white font-bold py-2.5 rounded-xl shadow-xs transition-all"
                                        onClick={() => updateStatus(order.id, 'preparing')}
                                        disabled={updatingId === order.id}
                                    >
                                        {updatingId === order.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Utensils className="w-4 h-4" />}
                                        Start Preparing
                                    </Button>
                                )}
                                {order.status === 'preparing' && (
                                    <Button 
                                        className="w-full flex justify-center items-center gap-2 bg-green-600 hover:bg-green-700 text-white font-bold py-2.5 rounded-xl shadow-xs transition-all"
                                        onClick={() => updateStatus(order.id, 'completed')}
                                        disabled={updatingId === order.id}
                                    >
                                        {updatingId === order.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Check className="w-4 h-4" />}
                                        Mark Ready
                                    </Button>
                                )}
                            </div>
                        </CardContent>
                    </Card>
                ))}

                {filteredOrders.length === 0 && (
                    <div className="col-span-full py-24 flex flex-col items-center justify-center text-gray-400 bg-white rounded-2xl border border-dashed border-gray-200">
                        <Utensils className="w-16 h-16 mb-4 text-gray-300 animate-bounce" />
                        <h2 className="text-xl font-bold text-gray-600">No active kitchen orders</h2>
                        <p className="text-sm text-gray-400 mt-1">Open table bills & new orders placed at POS will appear here live in real-time!</p>
                    </div>
                )}
            </div>
        </AdminLayout>
    );
}
