import React, { useEffect } from 'react';
import AdminLayout from '../Layouts/AdminLayout';
import { Card, CardContent } from '../Components/ui/Card';
import { Badge } from '../Components/ui/Badge';
import { Button } from '../Components/ui/Button';
import { Check, Clock, Utensils, Loader2 } from 'lucide-react';
import { useForm, router } from '@inertiajs/react';

export default function Kitchen({ orders = [] }) {
    
    // Automatically refresh orders every 30 seconds
    useEffect(() => {
        const interval = setInterval(() => {
            router.reload({ only: ['orders'] });
        }, 30000);
        return () => clearInterval(interval);
    }, []);

    const { post } = useForm();
    const [updatingId, setUpdatingId] = React.useState(null);

    const updateStatus = (id, newStatus) => {
        setUpdatingId(id);
        post(`/kitchen/${id}/status`, {
            data: { status: newStatus },
            preserveScroll: true,
            onFinish: () => setUpdatingId(null)
        });
    };

    return (
        <AdminLayout>
            <div className="mb-6 flex justify-between items-end">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 mb-1">Kitchen Display System</h1>
                    <p className="text-gray-500">Manage active orders and track preparation times.</p>
                </div>
                <div className="flex gap-4">
                    <div className="flex items-center gap-2">
                        <div className="w-3 h-3 rounded-full bg-red-500"></div>
                        <span className="text-sm font-medium text-gray-600">Pending ({orders.filter(o => o.status === 'pending').length})</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className="w-3 h-3 rounded-full bg-orange-500"></div>
                        <span className="text-sm font-medium text-gray-600">Preparing ({orders.filter(o => o.status === 'preparing').length})</span>
                    </div>
                </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                {orders.map(order => (
                    <Card key={order.id} className={`border-t-4 shadow-sm hover:shadow-md transition-shadow ${
                        order.status === 'pending' ? 'border-t-red-500' : 'border-t-orange-500'
                    }`}>
                        <CardContent className="p-5">
                            <div className="flex justify-between items-start mb-4">
                                <div>
                                    <h3 className="font-bold text-lg text-gray-900">#{order.id}</h3>
                                    <p className="text-gray-500 font-medium">{order.table}</p>
                                </div>
                                <div className="text-right">
                                    <Badge variant={order.status === 'pending' ? 'danger' : 'warning'} className="mb-1">
                                        {order.status.toUpperCase()}
                                    </Badge>
                                    <div className="flex items-center text-gray-500 text-sm gap-1">
                                        <Clock className="w-3 h-3" />
                                        {order.time}
                                    </div>
                                </div>
                            </div>

                            <div className="space-y-3 mb-6 bg-gray-50 p-4 rounded-xl border border-gray-100">
                                {order.items.map((item, idx) => (
                                    <div key={idx} className="flex justify-between items-start">
                                        <div className="flex gap-3">
                                            <span className="font-bold text-gray-900">{item.qty}x</span>
                                            <span className="text-gray-700 font-medium">{item.name}</span>
                                        </div>
                                    </div>
                                ))}
                            </div>

                            <div className="flex gap-3 mt-auto">
                                {order.status === 'pending' && (
                                    <Button 
                                        className="w-full flex justify-center items-center gap-2 bg-orange-500 hover:bg-orange-600 text-white"
                                        onClick={() => updateStatus(order.id, 'preparing')}
                                        disabled={updatingId === order.id}
                                    >
                                        {updatingId === order.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Utensils className="w-4 h-4" />}
                                        Start Preparing
                                    </Button>
                                )}
                                {order.status === 'preparing' && (
                                    <Button 
                                        className="w-full flex justify-center items-center gap-2 bg-green-500 hover:bg-green-600 text-white"
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

                {orders.length === 0 && (
                    <div className="col-span-full py-24 flex flex-col items-center justify-center text-gray-400">
                        <Utensils className="w-16 h-16 mb-4 text-gray-200" />
                        <h2 className="text-xl font-bold text-gray-500">No active orders</h2>
                        <p>The kitchen is clear. Waiting for new orders...</p>
                    </div>
                )}
            </div>
        </AdminLayout>
    );
}
