import React from 'react';
import SuperAdminLayout from '../../Layouts/SuperAdminLayout';
import { Card, CardContent, CardHeader, CardTitle } from '../../Components/ui/Card';
import { DollarSign, Store, Activity, Clock, ArrowUpRight } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export default function Dashboard({ stats = { mrr: '0.00', activeRestaurants: 0, totalTenants: 0, expiringSubscriptions: 0 }, chartData = [], recentSignups = [] }) {
    return (
        <SuperAdminLayout>
            <div className="space-y-6">
                {/* Stats Row */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <Card>
                        <CardContent className="p-6 flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-slate-500 mb-1">Monthly Recurring Revenue</p>
                                <h3 className="text-3xl font-bold text-slate-900">${stats.mrr}</h3>
                                <div className="flex items-center gap-1 text-emerald-600 text-sm mt-2 font-medium">
                                    <ArrowUpRight className="w-4 h-4" />
                                    <span>+12.5%</span>
                                    <span className="text-slate-400 ml-1 font-normal">vs last month</span>
                                </div>
                            </div>
                            <div className="w-14 h-14 rounded-2xl bg-blue-100 flex items-center justify-center text-blue-600">
                                <DollarSign className="w-7 h-7" />
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardContent className="p-6 flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-slate-500 mb-1">Active Restaurants</p>
                                <h3 className="text-3xl font-bold text-slate-900">{stats.activeRestaurants}</h3>
                                <div className="flex items-center gap-1 text-emerald-600 text-sm mt-2 font-medium">
                                    <ArrowUpRight className="w-4 h-4" />
                                    <span>+8 this month</span>
                                </div>
                            </div>
                            <div className="w-14 h-14 rounded-2xl bg-indigo-100 flex items-center justify-center text-indigo-600">
                                <Store className="w-7 h-7" />
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardContent className="p-6 flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-slate-500 mb-1">Total Tenants</p>
                                <h3 className="text-3xl font-bold text-slate-900">{stats.totalTenants}</h3>
                                <div className="flex items-center gap-1 text-emerald-600 text-sm mt-2 font-medium">
                                    <ArrowUpRight className="w-4 h-4" />
                                    <span>+5 this month</span>
                                </div>
                            </div>
                            <div className="w-14 h-14 rounded-2xl bg-emerald-100 flex items-center justify-center text-emerald-600">
                                <Activity className="w-7 h-7" />
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardContent className="p-6 flex items-center justify-between">
                            <div>
                                <p className="text-sm font-medium text-slate-500 mb-1">Subscriptions Expiring Soon</p>
                                <h3 className="text-3xl font-bold text-slate-900">{stats.expiringSubscriptions}</h3>
                                <div className="text-sm mt-2 text-slate-500">Active plans ending within 30 days</div>
                            </div>
                            <div className="w-14 h-14 rounded-2xl bg-amber-100 flex items-center justify-center text-amber-600">
                                <Clock className="w-7 h-7" />
                            </div>
                        </CardContent>
                    </Card>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    {/* Chart */}
                    <Card className="lg:col-span-2">
                        <CardHeader>
                            <CardTitle>MRR Growth (YTD)</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="h-[300px] w-full min-h-[300px]" style={{ minHeight: 300 }}>
                                <ResponsiveContainer width="100%" height={300}>
                                    <BarChart data={chartData}>
                                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                                        <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#64748b'}} dy={10} />
                                        <YAxis axisLine={false} tickLine={false} tick={{fill: '#64748b'}} dx={-10} />
                                        <Tooltip 
                                            cursor={{fill: '#f8fafc'}}
                                            contentStyle={{borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)'}}
                                        />
                                        <Bar dataKey="revenue" fill="#2563eb" radius={[6, 6, 0, 0]} barSize={40} />
                                    </BarChart>
                                </ResponsiveContainer>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Recent Signups */}
                    <Card>
                        <CardHeader>
                            <CardTitle>New Registration Requests</CardTitle>
                        </CardHeader>
                        <CardContent className="p-0">
                            <div className="divide-y divide-slate-100">
                                {recentSignups.length > 0 ? recentSignups.map((req, idx) => (
                                    <div key={idx} className="p-4 hover:bg-slate-50 transition-colors">
                                        <div className="flex justify-between items-start mb-1">
                                            <h4 className="font-semibold text-slate-800">{req.name}</h4>
                                            <span className="text-xs text-slate-400">{req.time}</span>
                                        </div>
                                        <div className="text-sm text-slate-500 mb-2">{req.plan}</div>
                                        <span className={`text-xs px-2 py-1 rounded-full font-medium ${
                                            req.status === 'Approved' ? 'bg-emerald-100 text-emerald-700' :
                                            req.status === 'Pending Verification' ? 'bg-amber-100 text-amber-700' :
                                            'bg-slate-100 text-slate-700'
                                        }`}>
                                            {req.status}
                                        </span>
                                    </div>
                                )) : (
                                    <div className="p-4 text-center text-slate-500">No recent signups.</div>
                                )}
                            </div>
                            <div className="p-4 border-t border-slate-100 bg-slate-50 rounded-b-2xl">
                                <button className="w-full text-center text-blue-600 font-medium text-sm hover:underline">
                                    View All Requests
                                </button>
                            </div>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </SuperAdminLayout>
    );
}
