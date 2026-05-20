import React from 'react';
import AdminLayout from '../Layouts/AdminLayout';
import { Card, CardContent, CardHeader, CardTitle } from '../Components/ui/Card';
import { Badge } from '../Components/ui/Badge';
import { DollarSign, ShoppingBag, CreditCard, TrendingUp, ArrowUpRight, ArrowDownRight } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const data = [
  { name: 'Mon', sales: 4000 },
  { name: 'Tue', sales: 3000 },
  { name: 'Wed', sales: 2000 },
  { name: 'Thu', sales: 2780 },
  { name: 'Fri', sales: 1890 },
  { name: 'Sat', sales: 2390 },
  { name: 'Sun', sales: 3490 },
];

export default function Dashboard({ user, stats, recentOrders, currency = '$' }) {
    return (
        <AdminLayout>
            <div className="space-y-6">
                {/* Stats Row */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <Card>
                        <CardContent className="p-6 flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-gray-500 mb-1">Today's Revenue</p>
                                <h3 className="text-3xl font-bold text-gray-900">{currency}{Number(stats?.revenue || 0).toFixed(2)}</h3>
                                <div className="flex items-center gap-1 text-green-600 text-sm mt-2 font-medium">
                                    <ArrowUpRight className="w-4 h-4" />
                                    <span>Today</span>
                                    <span className="text-gray-400 ml-1 font-normal">vs last week</span>
                                </div>
                            </div>
                            <div className="w-14 h-14 rounded-2xl bg-orange-100 flex items-center justify-center text-primary">
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
                                    <span className="text-gray-400 ml-1 font-normal">vs last week</span>
                                </div>
                            </div>
                            <div className="w-14 h-14 rounded-2xl bg-blue-100 flex items-center justify-center text-blue-600">
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
                                    <span className="text-gray-400 ml-1 font-normal">vs last week</span>
                                </div>
                            </div>
                            <div className="w-14 h-14 rounded-2xl bg-red-100 flex items-center justify-center text-red-500">
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
                                    <span className="text-gray-400 ml-1 font-normal">vs last week</span>
                                </div>
                            </div>
                            <div className="w-14 h-14 rounded-2xl bg-green-100 flex items-center justify-center text-green-600">
                                <TrendingUp className="w-7 h-7" />
                            </div>
                        </CardContent>
                    </Card>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    {/* Chart */}
                    <Card className="lg:col-span-2">
                        <CardHeader>
                            <CardTitle>Sales Revenue</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="h-[300px] w-full">
                                <ResponsiveContainer width="100%" height="100%">
                                    <BarChart data={data}>
                                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f3f4f6" />
                                        <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#9ca3af'}} dy={10} />
                                        <YAxis axisLine={false} tickLine={false} tick={{fill: '#9ca3af'}} dx={-10} />
                                        <Tooltip 
                                            cursor={{fill: '#f9fafb'}}
                                            contentStyle={{borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)'}}
                                        />
                                        <Bar dataKey="sales" fill="#FF6B00" radius={[6, 6, 0, 0]} barSize={40} />
                                    </BarChart>
                                </ResponsiveContainer>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Recent Orders */}
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
                            </div>
                            <div className="p-4 border-t border-gray-50 bg-gray-50 rounded-b-2xl">
                                <button className="w-full text-center text-primary font-medium text-sm hover:underline">
                                    View All Orders
                                </button>
                            </div>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </AdminLayout>
    );
}