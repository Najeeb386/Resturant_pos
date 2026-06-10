import React from 'react';
import AdminLayout from '../../Layouts/AdminLayout';
import { Card, CardContent, CardHeader, CardTitle } from '../../Components/ui/Card';
import { Link, router } from '@inertiajs/react';
import { TrendingUp, TrendingDown, DollarSign, Receipt, PieChart, Activity } from 'lucide-react';

export default function ReportsIndex({ range, summary, itemStats, currencySymbol }) {
    
    const handleRangeChange = (e) => {
        router.get('/reports', { range: e.target.value }, { preserveState: true });
    };

    return (
        <AdminLayout>
            <div className="flex justify-between items-center mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Financial Reports & P&L</h1>
                    <p className="text-sm text-gray-500">Track your profit, expenses, and item margins.</p>
                </div>
                <div>
                    <select 
                        value={range}
                        onChange={handleRangeChange}
                        className="bg-white border border-gray-200 text-gray-700 py-2 px-4 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
                    >
                        <option value="today">Today (Cashier Report)</option>
                        <option value="week">This Week</option>
                        <option value="month">This Month</option>
                        <option value="year">This Year</option>
                        <option value="all">All Time</option>
                    </select>
                </div>
            </div>

            {/* Profit & Loss Summary Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <Card className="bg-white border-0 shadow-lg shadow-gray-100/50 relative overflow-hidden">
                    <div className="absolute top-0 left-0 w-1 h-full bg-blue-500"></div>
                    <CardContent className="p-6">
                        <div className="flex justify-between items-start">
                            <div>
                                <p className="text-sm font-medium text-gray-500 mb-1">Gross Sales</p>
                                <h3 className="text-3xl font-bold text-gray-900">{currencySymbol}{summary.grossSales.toFixed(2)}</h3>
                            </div>
                            <div className="w-12 h-12 rounded-xl bg-blue-50 flex items-center justify-center text-blue-500">
                                <DollarSign className="w-6 h-6" />
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card className="bg-white border-0 shadow-lg shadow-gray-100/50 relative overflow-hidden">
                    <div className="absolute top-0 left-0 w-1 h-full bg-orange-500"></div>
                    <CardContent className="p-6">
                        <div className="flex justify-between items-start">
                            <div>
                                <p className="text-sm font-medium text-gray-500 mb-1">Cost of Goods (COGS)</p>
                                <h3 className="text-3xl font-bold text-gray-900">{currencySymbol}{summary.cogs.toFixed(2)}</h3>
                            </div>
                            <div className="w-12 h-12 rounded-xl bg-orange-50 flex items-center justify-center text-orange-500">
                                <PieChart className="w-6 h-6" />
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card className="bg-white border-0 shadow-lg shadow-gray-100/50 relative overflow-hidden">
                    <div className="absolute top-0 left-0 w-1 h-full bg-red-500"></div>
                    <CardContent className="p-6">
                        <div className="flex justify-between items-start">
                            <div>
                                <p className="text-sm font-medium text-gray-500 mb-1">Operating Expenses</p>
                                <h3 className="text-3xl font-bold text-gray-900">{currencySymbol}{summary.expenses.toFixed(2)}</h3>
                            </div>
                            <div className="w-12 h-12 rounded-xl bg-red-50 flex items-center justify-center text-red-500">
                                <Receipt className="w-6 h-6" />
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card className={`bg-gradient-to-br ${summary.netProfit >= 0 ? 'from-green-500 to-green-600' : 'from-red-500 to-red-600'} text-white border-0 shadow-xl relative overflow-hidden`}>
                    <CardContent className="p-6">
                        <div className="flex justify-between items-start">
                            <div>
                                <p className="text-sm font-medium text-white/80 mb-1">Net Profit</p>
                                <h3 className="text-3xl font-bold">{currencySymbol}{summary.netProfit.toFixed(2)}</h3>
                            </div>
                            <div className="w-12 h-12 rounded-xl bg-white/20 flex items-center justify-center text-white backdrop-blur-sm">
                                {summary.netProfit >= 0 ? <TrendingUp className="w-6 h-6" /> : <TrendingDown className="w-6 h-6" />}
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                
                {/* Cashier Summary */}
                <Card className="lg:col-span-1 shadow-sm border-gray-100">
                    <CardHeader className="bg-gray-50/50 border-b border-gray-100 pb-4">
                        <CardTitle className="text-lg font-bold text-gray-800 flex items-center gap-2">
                            <Activity className="w-5 h-5 text-primary" />
                            Cashier Summary
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="p-0">
                        <div className="divide-y divide-gray-100">
                            <div className="p-4 flex justify-between items-center hover:bg-gray-50 transition-colors">
                                <span className="text-gray-600 font-medium">Total Orders Taken</span>
                                <span className="font-bold text-gray-900">{summary.orderCount}</span>
                            </div>
                            <div className="p-4 flex justify-between items-center hover:bg-gray-50 transition-colors">
                                <span className="text-gray-600 font-medium">Cash Collected</span>
                                <span className="font-bold text-green-600">{currencySymbol}{summary.cashSales.toFixed(2)}</span>
                            </div>
                            <div className="p-4 flex justify-between items-center hover:bg-gray-50 transition-colors">
                                <span className="text-gray-600 font-medium">Card/Online Payments</span>
                                <span className="font-bold text-blue-600">{currencySymbol}{summary.cardSales.toFixed(2)}</span>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                {/* Item Profitability Table */}
                <Card className="lg:col-span-2 shadow-sm border-gray-100">
                    <CardHeader className="bg-gray-50/50 border-b border-gray-100 pb-4">
                        <CardTitle className="text-lg font-bold text-gray-800 flex items-center gap-2">
                            <TrendingUp className="w-5 h-5 text-green-500" />
                            Top Items by Profitability
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="p-0">
                        <div className="overflow-x-auto">
                            <table className="w-full">
                                <thead>
                                    <tr className="bg-gray-50 text-xs text-gray-500 uppercase tracking-wider">
                                        <th className="py-3 px-4 text-left font-semibold border-b">Menu Item</th>
                                        <th className="py-3 px-4 text-right font-semibold border-b">Qty Sold</th>
                                        <th className="py-3 px-4 text-right font-semibold border-b">Revenue</th>
                                        <th className="py-3 px-4 text-right font-semibold border-b">Total Cost</th>
                                        <th className="py-3 px-4 text-right font-semibold border-b">Profit</th>
                                        <th className="py-3 px-4 text-right font-semibold border-b">Margin</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-gray-100">
                                    {itemStats.map((item, index) => (
                                        <tr key={index} className="hover:bg-gray-50 transition-colors">
                                            <td className="py-3 px-4 font-medium text-gray-900">{item.name}</td>
                                            <td className="py-3 px-4 text-right text-gray-600">{item.total_sold}</td>
                                            <td className="py-3 px-4 text-right font-medium text-blue-600">{currencySymbol}{Number(item.revenue).toFixed(2)}</td>
                                            <td className="py-3 px-4 text-right text-orange-500">{currencySymbol}{Number(item.cost).toFixed(2)}</td>
                                            <td className="py-3 px-4 text-right font-bold text-green-600">{currencySymbol}{Number(item.profit).toFixed(2)}</td>
                                            <td className="py-3 px-4 text-right">
                                                <span className={`inline-flex px-2 py-1 rounded-md text-xs font-bold ${
                                                    item.margin >= 50 ? 'bg-green-100 text-green-800' :
                                                    item.margin >= 20 ? 'bg-yellow-100 text-yellow-800' :
                                                    'bg-red-100 text-red-800'
                                                }`}>
                                                    {item.margin}%
                                                </span>
                                            </td>
                                        </tr>
                                    ))}
                                    {itemStats.length === 0 && (
                                        <tr>
                                            <td colSpan="6" className="py-8 text-center text-gray-500">
                                                No sales data found for the selected time range.
                                            </td>
                                        </tr>
                                    )}
                                </tbody>
                            </table>
                        </div>
                    </CardContent>
                </Card>

            </div>
        </AdminLayout>
    );
}
