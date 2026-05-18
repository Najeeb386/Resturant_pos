import React, { useState } from 'react';
import AdminLayout from '../Layouts/AdminLayout';
import { Card, CardContent, CardHeader, CardTitle } from '../Components/ui/Card';
import { Badge } from '../Components/ui/Badge';
import { Button } from '../Components/ui/Button';
import { Clock, CheckCircle2, PlayCircle } from 'lucide-react';

const initialOrders = [
    { 
        id: '#ORD-001', 
        table: 'Table 4', 
        type: 'Dine-In',
        time: '12:30 PM',
        status: 'pending',
        items: [
            { name: 'Classic Beef Burger', qty: 2, notes: 'No onions' },
            { name: 'Iced Coffee', qty: 2 },
        ]
    },
    { 
        id: '#ORD-002', 
        table: 'Takeaway', 
        type: 'Takeaway',
        time: '12:35 PM',
        status: 'preparing',
        items: [
            { name: 'Pepperoni Pizza', qty: 1 },
            { name: 'Coca Cola', qty: 1 },
        ]
    },
    { 
        id: '#ORD-003', 
        table: 'Delivery', 
        type: 'Delivery',
        time: '12:40 PM',
        status: 'pending',
        items: [
            { name: 'Family Combo', qty: 1 },
            { name: 'Chocolate Sundae', qty: 2 },
        ]
    },
];

export default function Kitchen() {
    const [orders, setOrders] = useState(initialOrders);

    const updateStatus = (id, newStatus) => {
        setOrders(orders.map(order => 
            order.id === id ? { ...order, status: newStatus } : order
        ));
    };

    return (
        <AdminLayout>
            <div className="mb-6 flex justify-between items-end">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 mb-1">Kitchen Display System</h1>
                    <p className="text-gray-500">Live incoming orders and preparation queue.</p>
                </div>
            </div>

            <div className="flex gap-6 overflow-x-auto pb-4 h-[calc(100vh-12rem)]">
                {/* Column: Pending */}
                <div className="flex-shrink-0 w-80 bg-gray-50 rounded-2xl p-4 flex flex-col border border-gray-100">
                    <div className="flex items-center justify-between mb-4">
                        <h2 className="font-bold text-gray-700 flex items-center gap-2">
                            <Clock className="w-5 h-5 text-red-500" />
                            Pending
                        </h2>
                        <span className="bg-red-100 text-red-600 px-2.5 py-0.5 rounded-full text-sm font-bold">
                            {orders.filter(o => o.status === 'pending').length}
                        </span>
                    </div>
                    <div className="flex-1 overflow-y-auto space-y-4">
                        {orders.filter(o => o.status === 'pending').map(order => (
                            <OrderCard key={order.id} order={order} onAction={() => updateStatus(order.id, 'preparing')} actionText="Start Preparing" actionIcon={PlayCircle} color="red" />
                        ))}
                    </div>
                </div>

                {/* Column: Preparing */}
                <div className="flex-shrink-0 w-80 bg-gray-50 rounded-2xl p-4 flex flex-col border border-gray-100">
                    <div className="flex items-center justify-between mb-4">
                        <h2 className="font-bold text-gray-700 flex items-center gap-2">
                            <PlayCircle className="w-5 h-5 text-yellow-500" />
                            Preparing
                        </h2>
                        <span className="bg-yellow-100 text-yellow-700 px-2.5 py-0.5 rounded-full text-sm font-bold">
                            {orders.filter(o => o.status === 'preparing').length}
                        </span>
                    </div>
                    <div className="flex-1 overflow-y-auto space-y-4">
                        {orders.filter(o => o.status === 'preparing').map(order => (
                            <OrderCard key={order.id} order={order} onAction={() => updateStatus(order.id, 'ready')} actionText="Mark Ready" actionIcon={CheckCircle2} color="yellow" />
                        ))}
                    </div>
                </div>

                {/* Column: Ready */}
                <div className="flex-shrink-0 w-80 bg-gray-50 rounded-2xl p-4 flex flex-col border border-gray-100">
                    <div className="flex items-center justify-between mb-4">
                        <h2 className="font-bold text-gray-700 flex items-center gap-2">
                            <CheckCircle2 className="w-5 h-5 text-green-500" />
                            Ready
                        </h2>
                        <span className="bg-green-100 text-green-600 px-2.5 py-0.5 rounded-full text-sm font-bold">
                            {orders.filter(o => o.status === 'ready').length}
                        </span>
                    </div>
                    <div className="flex-1 overflow-y-auto space-y-4">
                        {orders.filter(o => o.status === 'ready').map(order => (
                            <OrderCard key={order.id} order={order} onAction={() => updateStatus(order.id, 'served')} actionText="Mark Served" actionIcon={CheckCircle2} color="green" />
                        ))}
                    </div>
                </div>
            </div>
        </AdminLayout>
    );
}

function OrderCard({ order, onAction, actionText, actionIcon: Icon, color }) {
    const colorClasses = {
        red: 'border-red-200 border-t-4 border-t-red-500',
        yellow: 'border-yellow-200 border-t-4 border-t-yellow-500',
        green: 'border-green-200 border-t-4 border-t-green-500',
    };

    return (
        <Card className={`shadow-sm ${colorClasses[color]}`}>
            <CardHeader className="p-4 pb-2 border-b-0">
                <div className="flex justify-between items-start w-full">
                    <div>
                        <CardTitle className="text-lg">{order.id}</CardTitle>
                        <p className="text-sm text-gray-500 font-medium">{order.table} • {order.type}</p>
                    </div>
                    <div className="text-right">
                        <p className="text-xs font-bold text-gray-400 mb-1">{order.time}</p>
                    </div>
                </div>
            </CardHeader>
            <CardContent className="p-4 pt-2">
                <ul className="space-y-3 mb-4">
                    {order.items.map((item, idx) => (
                        <li key={idx} className="text-sm text-gray-800 flex justify-between items-start border-b border-gray-50 pb-2 last:border-0 last:pb-0">
                            <div>
                                <span className="font-bold mr-2 text-primary">{item.qty}x</span>
                                <span className="font-medium">{item.name}</span>
                                {item.notes && <p className="text-xs text-red-500 mt-0.5 ml-6 italic">Note: {item.notes}</p>}
                            </div>
                        </li>
                    ))}
                </ul>
                <Button className="w-full text-sm py-2" variant={color === 'red' ? 'primary' : color === 'yellow' ? 'secondary' : 'outline'} onClick={onAction}>
                    <Icon className="w-4 h-4 mr-2" />
                    {actionText}
                </Button>
            </CardContent>
        </Card>
    );
}
