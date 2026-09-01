import React from 'react';
import AdminLayout from '../Layouts/AdminLayout';
import { Card, CardContent, CardHeader, CardTitle } from '../Components/ui/Card';
import { Badge } from '../Components/ui/Badge';
import { DollarSign, ShoppingBag, CreditCard, TrendingUp, ArrowUpRight, ArrowDownRight } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export default function Dashboard({ user, stats, salesChartData = [], recentOrders = [], currency = '$' }) {
    // Fallback data if no sales data exists yet
    const defaultData = [
        { name: 'Mon', sales: 0 },
        { name: 'Tue', sales: 0 },
        { name: 'Wed', sales: 0 },
        { name: 'Thu', sales: 0 },
        { name: 'Fri', sales: 0 },
        { name: 'Sat', sales: 0 },
        { name: 'Sun', sales: 0 },
    ];

    const chartData = salesChartData.length > 0 ? salesChartData : defaultData;

    return (
        <AdminLayout>
            <div className="space-y-6">
                {/* Stats Row */}
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
                    <Card>
                        <CardContent className="p-6 flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-gray-500 mb-1">Today's Revenue</p>
                                <h3 className="text-3xl font-bold text-gray-900">{currency}{Number(stats?.revenue || 0).toFixed(2)}</h3>
                                <div className="flex items-center gap-1 text-green-600 text-sm mt-2 font-medium">
                                    <ArrowUpRight className="w-4 h-4" />
                                    <span>Today</span>
                                    <span className="text-gray-400 ml-1 font-normal">live total</span>
                                </div>
                            </div>
                            <div className="w-14 h-14 rounded-2xl bg-orange-100 flex items-center justify-center text-primary shrink-0">
                                <DollarSign className="w-7 h-7" />
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardContent className="p-6 flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-gray-500 mb-1">Today's Orders</p>
                                <h3 className="text-3xl font-bold text-gray-900">{stats?.orders || 0}</h3>
                                <div className="flex items-center gap-1 text-green-600 text-sm mt-2 font-medium">
                                    <ArrowUpRight className="w-4 h-4" />
                                    <span>Today</span>
                                    <span className="text-gray-400 ml-1 font-normal">total count</span>
                                </div>
                            </div>
                            <div className="w-14 h-14 rounded-2xl bg-blue-100 flex items-center justify-center text-blue-600 shrink-0">
                                <ShoppingBag className="w-7 h-7" />
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardContent className="p-6 flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-gray-500 mb-1">Active Orders</p>
                                <h3 className="text-3xl font-bold text-gray-900">{stats?.active || 0}</h3>
                                <div className="flex items-center gap-1 text-orange-500 text-sm mt-2 font-medium">
                                    <ArrowUpRight className="w-4 h-4" />
                                    <span>In Kitchen</span>
                                    <span className="text-gray-400 ml-1 font-normal">active queue</span>
                                </div>
                            </div>
                            <div className="w-14 h-14 rounded-2xl bg-red-100 flex items-center justify-center text-red-500 shrink-0">
                                <CreditCard className="w-7 h-7" />
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardContent className="p-6 flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-gray-500 mb-1">Low Stock Items</p>
                                <h3 className="text-3xl font-bold text-gray-900">{stats?.lowStock || 0}</h3>
                                <div className="flex items-center gap-1 text-red-600 text-sm mt-2 font-medium">
                                    <ArrowDownRight className="w-4 h-4" />
                                    <span>Needs Restock</span>
                                    <span className="text-gray-400 ml-1 font-normal">inventory alert</span>
                                </div>
                            </div>
                            <div className="w-14 h-14 rounded-2xl bg-green-100 flex items-center justify-center text-green-600 shrink-0">
                                <TrendingUp className="w-7 h-7" />
                            </div>
                        </CardContent>
                    </Card>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    {/* Real-time Sales Chart */}
                    <Card className="lg:col-span-2">
                        <CardHeader className="flex flex-row items-center justify-between pb-2">
                            <CardTitle>Sales Revenue (Last 7 Days)</CardTitle>
                            <span className="text-xs font-semibold text-gray-500 bg-gray-100 px-3 py-1 rounded-full">
                                Real-time DB Data
                            </span>
                        </CardHeader>
                        <CardContent>
                            <div className="h-[300px] w-full min-h-[300px]" style={{ minHeight: 300 }}>
                                <ResponsiveContainer width="100%" height={300} minWidth={0}>
                                    <BarChart data={chartData}>
                                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f3f4f6" />
                                        <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#6b7280', fontSize: 12}} dy={10} />
                                        <YAxis axisLine={false} tickLine={false} tick={{fill: '#6b7280', fontSize: 12}} dx={-10} />
                                        <Tooltip 
                                            cursor={{fill: '#f9fafb'}}
                                            formatter={(value) => [`${currency}${Number(value).toFixed(2)}`, 'Sales Revenue']}
                                            contentStyle={{borderRadius: '12px', border: '1px solid #e5e7eb', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)'}}
                                        />
                                        <Bar dataKey="sales" fill="#FF6B00" radius={[6, 6, 0, 0]} barSize={36} />
                                    </BarChart>
                                </ResponsiveContainer>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Recent Orders Feed */}
                    <Card>
                        <CardHeader>
                            <CardTitle>Live Kitchen Feed</CardTitle>
                        </CardHeader>
                        <CardContent className="p-0">
                            <div className="divide-y divide-gray-50">
                                {recentOrders.map((order) => (
                                    <div key={order.id} className="p-4 hover:bg-gray-50 transition-colors flex items-center justify-between">
                                        <div>
                                            <div className="flex items-center gap-2 mb-1">
                                                <span className="font-semibold text-gray-900">#{order.id}</span>
                                                <span className="text-sm text-gray-500">• {order.table}</span>
                                            </div>
                                            <div className="text-sm font-medium text-gray-600">{currency}{Number(order.total).toFixed(2)}</div>
                                        </div>
                                        <div className="text-right">
                                            <Badge 
                                                variant={
                                                    order.status === 'completed' ? 'success' : 
                                                    order.status === 'preparing' ? 'warning' : 
                                                    order.status === 'pending' ? 'danger' : 'default'
                                                }
                                                className="mb-1 block w-fit ml-auto"
                                            >
                                                {order.status}
                                            </Badge>
                                            <div className="text-xs text-gray-400">{order.time}</div>
                                        </div>
                                    </div>
                                ))}
                                {recentOrders.length === 0 && (
                                    <div className="p-8 text-center text-gray-400 text-sm">
                                        No recent orders today.
                                    </div>
                                )}
                            </div>
                            <div className="p-4 border-t border-gray-50 bg-gray-50 rounded-b-2xl">
                                <a href="/orders" className="block w-full text-center text-primary font-medium text-sm hover:underline">
                                    View All Orders
                                </a>
                            </div>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </AdminLayout>
    );
}