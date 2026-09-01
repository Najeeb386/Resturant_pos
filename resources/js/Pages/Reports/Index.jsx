import React, { useState } from 'react';
import AdminLayout from '../../Layouts/AdminLayout';
import { Card, CardContent, CardHeader, CardTitle } from '../../Components/ui/Card';
import { Badge } from '../../Components/ui/Badge';
import { Button } from '../../Components/ui/Button';
import { router } from '@inertiajs/react';
import { 
    TrendingUp, TrendingDown, DollarSign, Receipt, PieChart, Activity, 
    Truck, ShoppingBag, Search, CreditCard, Wallet, QrCode, Calendar, Filter
} from 'lucide-react';

export default function ReportsIndex({ 
    range = 'today', 
    startDate = '', 
    endDate = '', 
    currencySymbol, 
    cashFlowSummary = {}, 
    productSales = [], 
    deliverySummary = {} 
}) {
    const [activeTab, setActiveTab] = useState('cash_flow'); // 'cash_flow' | 'product_sales' | 'delivery_charges'
    const [productSearch, setProductSearch] = useState('');
    const [deliverySearch, setDeliverySearch] = useState('');

    const todayStr = new Date().toISOString().split('T')[0];
    const [customStartDate, setCustomStartDate] = useState(startDate || todayStr);
    const [customEndDate, setCustomEndDate] = useState(endDate || todayStr);

    const currency = currencySymbol || '$';

    const handleRangeSelect = (e) => {
        const selectedRange = e.target.value;
        if (selectedRange === 'custom') {
            router.get('/reports', { range: 'custom', start_date: customStartDate, end_date: customEndDate }, { preserveState: true });
        } else {
            router.get('/reports', { range: selectedRange }, { preserveState: true });
        }
    };

    const handleApplyCustomDates = (e) => {
        e.preventDefault();
        router.get('/reports', { range: 'custom', start_date: customStartDate, end_date: customEndDate }, { preserveState: true });
    };

    // Filter Product Sales in real-time
    const filteredProducts = productSales.filter(item => {
        const query = productSearch.toLowerCase().trim();
        if (!query) return true;
        return item.name.toLowerCase().includes(query) || (item.category && item.category.toLowerCase().includes(query));
    });

    // Filter Delivery Orders in real-time
    const deliveryOrdersList = deliverySummary.orders || [];
    const filteredDeliveryOrders = deliveryOrdersList.filter(order => {
        const query = deliverySearch.toLowerCase().trim();
        if (!query) return true;
        return order.id.toString().includes(query) ||
            (`#${order.id}`).includes(query) ||
            order.customer_name.toLowerCase().includes(query) ||
            order.customer_phone.toLowerCase().includes(query) ||
            order.delivery_address.toLowerCase().includes(query);
    });

    return (
        <AdminLayout>
            {/* Header & Date Range Filter Bar */}
            <div className="mb-6 bg-white p-5 rounded-2xl border border-gray-100 shadow-xs flex flex-col lg:flex-row justify-between items-start lg:items-center gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 mb-1">Financial & Operational Reports</h1>
                    <p className="text-sm text-gray-500">Track Cash Flow, Product Sales Margins, and Delivery Fees.</p>
                </div>

                <div className="flex flex-wrap items-center gap-3 w-full lg:w-auto">
                    <div className="flex items-center gap-2 w-full sm:w-auto">
                        <Calendar className="w-4 h-4 text-gray-400 shrink-0" />
                        <select 
                            value={range}
                            onChange={handleRangeSelect}
                            className="w-full sm:w-auto bg-white border border-gray-200 text-gray-800 text-sm font-semibold py-2 px-3.5 rounded-xl shadow-xs focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all cursor-pointer"
                        >
                            <option value="today">Today (Cashier Report)</option>
                            <option value="week">This Week</option>
                            <option value="month">This Month</option>
                            <option value="year">This Year</option>
                            <option value="all">All Time</option>
                            <option value="custom">📅 Custom Date Range</option>
                        </select>
                    </div>

                    {/* Custom Date Range Inputs */}
                    {range === 'custom' && (
                        <form onSubmit={handleApplyCustomDates} className="flex flex-wrap items-center gap-2 bg-gray-50 p-2 rounded-xl border border-gray-200 w-full sm:w-auto">
                            <div className="flex items-center gap-1.5 text-xs font-semibold text-gray-600">
                                <span>From:</span>
                                <input 
                                    type="date"
                                    value={customStartDate}
                                    onChange={(e) => setCustomStartDate(e.target.value)}
                                    className="bg-white border border-gray-200 text-gray-800 text-xs py-1.5 px-2 rounded-lg focus:outline-none focus:ring-1 focus:ring-primary"
                                    required
                                />
                            </div>

                            <div className="flex items-center gap-1.5 text-xs font-semibold text-gray-600">
                                <span>To:</span>
                                <input 
                                    type="date"
                                    value={customEndDate}
                                    onChange={(e) => setCustomEndDate(e.target.value)}
                                    className="bg-white border border-gray-200 text-gray-800 text-xs py-1.5 px-2 rounded-lg focus:outline-none focus:ring-1 focus:ring-primary"
                                    required
                                />
                            </div>

                            <Button type="submit" size="sm" className="bg-primary hover:bg-primary/90 text-white text-xs px-3 py-1.5 rounded-lg shadow-xs font-bold">
                                Apply Filter
                            </Button>
                        </form>
                    )}
                </div>
            </div>

            {/* Tab Navigation */}
            <div className="mb-6 flex flex-wrap gap-2 border-b border-gray-200 pb-px">
                <button 
                    onClick={() => setActiveTab('cash_flow')}
                    className={`flex items-center gap-2 px-5 py-3 font-bold text-sm transition-all rounded-t-xl relative ${
                        activeTab === 'cash_flow' 
                            ? 'bg-white text-primary border-t-2 border-x border-gray-200 -mb-px shadow-2xs' 
                            : 'text-gray-500 hover:text-gray-700 bg-gray-50/50'
                    }`}
                >
                    <Wallet className="w-4 h-4 text-primary" />
                    Cash Flow
                </button>

                <button 
                    onClick={() => setActiveTab('product_sales')}
                    className={`flex items-center gap-2 px-5 py-3 font-bold text-sm transition-all rounded-t-xl relative ${
                        activeTab === 'product_sales' 
                            ? 'bg-white text-primary border-t-2 border-x border-gray-200 -mb-px shadow-2xs' 
                            : 'text-gray-500 hover:text-gray-700 bg-gray-50/50'
                    }`}
                >
                    <ShoppingBag className="w-4 h-4 text-purple-600" />
                    Product Sales ({productSales.length})
                </button>

                <button 
                    onClick={() => setActiveTab('delivery_charges')}
                    className={`flex items-center gap-2 px-5 py-3 font-bold text-sm transition-all rounded-t-xl relative ${
                        activeTab === 'delivery_charges' 
                            ? 'bg-white text-primary border-t-2 border-x border-gray-200 -mb-px shadow-2xs' 
                            : 'text-gray-500 hover:text-gray-700 bg-gray-50/50'
                    }`}
                >
                    <Truck className="w-4 h-4 text-emerald-600" />
                    Delivery Charges ({deliverySummary.totalDeliveredOrders || 0})
                </button>
            </div>

            {/* ==================== TAB 1: CASH FLOW ==================== */}
            {activeTab === 'cash_flow' && (
                <div className="space-y-6">
                    {/* Profit & Loss Summary Cards */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
                        <Card className="bg-white border-0 shadow-sm relative overflow-hidden">
                            <div className="absolute top-0 left-0 w-1.5 h-full bg-blue-500"></div>
                            <CardContent className="p-6">
                                <div className="flex justify-between items-start">
                                    <div>
                                        <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1">Gross Sales</p>
                                        <h3 className="text-2xl font-black text-gray-900">{currency}{(cashFlowSummary.grossSales || 0).toFixed(2)}</h3>
                                    </div>
                                    <div className="w-11 h-11 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600">
                                        <DollarSign className="w-5 h-5" />
                                    </div>
                                </div>
                            </CardContent>
                        </Card>

                        <Card className="bg-white border-0 shadow-sm relative overflow-hidden">
                            <div className="absolute top-0 left-0 w-1.5 h-full bg-amber-500"></div>
                            <CardContent className="p-6">
                                <div className="flex justify-between items-start">
                                    <div>
                                        <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1">Cost of Goods (COGS)</p>
                                        <h3 className="text-2xl font-black text-gray-900">{currency}{(cashFlowSummary.cogs || 0).toFixed(2)}</h3>
                                    </div>
                                    <div className="w-11 h-11 rounded-xl bg-amber-50 flex items-center justify-center text-amber-600">
                                        <PieChart className="w-5 h-5" />
                                    </div>
                                </div>
                            </CardContent>
                        </Card>

                        <Card className="bg-white border-0 shadow-sm relative overflow-hidden">
                            <div className="absolute top-0 left-0 w-1.5 h-full bg-red-500"></div>
                            <CardContent className="p-6">
                                <div className="flex justify-between items-start">
                                    <div>
                                        <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1">Operating Expenses</p>
                                        <h3 className="text-2xl font-black text-gray-900">{currency}{(cashFlowSummary.expenses || 0).toFixed(2)}</h3>
                                    </div>
                                    <div className="w-11 h-11 rounded-xl bg-red-50 flex items-center justify-center text-red-600">
                                        <Receipt className="w-5 h-5" />
                                    </div>
                                </div>
                            </CardContent>
                        </Card>

                        <Card className={`bg-gradient-to-br ${(cashFlowSummary.netProfit || 0) >= 0 ? 'from-green-600 to-emerald-700' : 'from-red-600 to-rose-700'} text-white border-0 shadow-md relative overflow-hidden`}>
                            <CardContent className="p-6">
                                <div className="flex justify-between items-start">
                                    <div>
                                        <p className="text-xs font-bold text-white/80 uppercase tracking-wider mb-1">Net Profit</p>
                                        <h3 className="text-2xl font-black">{currency}{(cashFlowSummary.netProfit || 0).toFixed(2)}</h3>
                                    </div>
                                    <div className="w-11 h-11 rounded-xl bg-white/20 flex items-center justify-center text-white backdrop-blur-xs">
                                        {(cashFlowSummary.netProfit || 0) >= 0 ? <TrendingUp className="w-5 h-5" /> : <TrendingDown className="w-5 h-5" />}
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                    </div>

                    {/* Cashier & Payment Methods Summary */}
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <Card className="shadow-xs border-gray-100">
                            <CardHeader className="bg-gray-50/60 border-b border-gray-100 py-4">
                                <CardTitle className="text-base font-bold text-gray-800 flex items-center gap-2">
                                    <Activity className="w-5 h-5 text-primary" />
                                    Sales Overview & Orders
                                </CardTitle>
                            </CardHeader>
                            <CardContent className="p-0">
                                <div className="divide-y divide-gray-100">
                                    <div className="p-4 flex justify-between items-center hover:bg-gray-50/50 transition-colors">
                                        <span className="text-gray-600 font-semibold text-sm">Total Paid Orders</span>
                                        <span className="font-extrabold text-base text-gray-900">{cashFlowSummary.orderCount || 0} Orders</span>
                                    </div>
                                    <div className="p-4 flex justify-between items-center hover:bg-gray-50/50 transition-colors">
                                        <span className="text-gray-600 font-semibold text-sm">Total Gross Revenue</span>
                                        <span className="font-black text-base text-blue-600">{currency}{(cashFlowSummary.grossSales || 0).toFixed(2)}</span>
                                    </div>
                                    <div className="p-4 flex justify-between items-center hover:bg-gray-50/50 transition-colors">
                                        <span className="text-gray-600 font-semibold text-sm">Total Expenses Logged</span>
                                        <span className="font-bold text-base text-red-600">{currency}{(cashFlowSummary.expenses || 0).toFixed(2)}</span>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>

                        <Card className="shadow-xs border-gray-100">
                            <CardHeader className="bg-gray-50/60 border-b border-gray-100 py-4">
                                <CardTitle className="text-base font-bold text-gray-800 flex items-center gap-2">
                                    <CreditCard className="w-5 h-5 text-emerald-600" />
                                    Payment Method Breakdown
                                </CardTitle>
                            </CardHeader>
                            <CardContent className="p-0">
                                <div className="divide-y divide-gray-100">
                                    <div className="p-4 flex justify-between items-center hover:bg-gray-50/50 transition-colors">
                                        <div className="flex items-center gap-3">
                                            <div className="w-9 h-9 rounded-lg bg-green-50 flex items-center justify-center text-green-600">
                                                <Wallet className="w-4 h-4" />
                                            </div>
                                            <span className="text-gray-700 font-semibold text-sm">Cash Collected</span>
                                        </div>
                                        <span className="font-extrabold text-base text-green-700">{currency}{(cashFlowSummary.cashSales || 0).toFixed(2)}</span>
                                    </div>

                                    <div className="p-4 flex justify-between items-center hover:bg-gray-50/50 transition-colors">
                                        <div className="flex items-center gap-3">
                                            <div className="w-9 h-9 rounded-lg bg-blue-50 flex items-center justify-center text-blue-600">
                                                <CreditCard className="w-4 h-4" />
                                            </div>
                                            <span className="text-gray-700 font-semibold text-sm">Card Payments</span>
                                        </div>
                                        <span className="font-extrabold text-base text-blue-600">{currency}{(cashFlowSummary.cardSales || 0).toFixed(2)}</span>
                                    </div>

                                    <div className="p-4 flex justify-between items-center hover:bg-gray-50/50 transition-colors">
                                        <div className="flex items-center gap-3">
                                            <div className="w-9 h-9 rounded-lg bg-purple-50 flex items-center justify-center text-purple-600">
                                                <QrCode className="w-4 h-4" />
                                            </div>
                                            <span className="text-gray-700 font-semibold text-sm">QR Code Payments</span>
                                        </div>
                                        <span className="font-extrabold text-base text-purple-600">{currency}{(cashFlowSummary.qrSales || 0).toFixed(2)}</span>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                    </div>
                </div>
            )}

            {/* ==================== TAB 2: PRODUCT SALES ==================== */}
            {activeTab === 'product_sales' && (
                <div className="space-y-6">
                    {/* Search & Filter Bar */}
                    <div className="bg-white p-4 rounded-2xl shadow-xs border border-gray-100 flex flex-col sm:flex-row gap-4 items-center justify-between">
                        <div className="relative w-full sm:w-96">
                            <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                            <input 
                                type="text"
                                placeholder="Search product by name or category..."
                                value={productSearch}
                                onChange={(e) => setProductSearch(e.target.value)}
                                className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary text-sm transition-all"
                            />
                        </div>

                        <div className="flex items-center gap-4 text-xs font-semibold text-gray-500">
                            <span>Total Products Sold: <strong className="text-gray-900 text-sm">{filteredProducts.reduce((sum, p) => sum + p.total_sold, 0)} units</strong></span>
                        </div>
                    </div>

                    <Card className="shadow-xs border-gray-100">
                        <CardHeader className="bg-gray-50/60 border-b border-gray-100 py-4">
                            <CardTitle className="text-base font-bold text-gray-800 flex items-center gap-2">
                                <ShoppingBag className="w-5 h-5 text-purple-600" />
                                Product Sales & Margin Analysis
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="p-0">
                            <div className="overflow-x-auto">
                                <table className="w-full text-left border-collapse">
                                    <thead>
                                        <tr className="bg-gray-50 text-xs text-gray-500 uppercase tracking-wider border-b border-gray-100">
                                            <th className="py-3.5 px-5 font-bold">Menu Item</th>
                                            <th className="py-3.5 px-5 font-bold">Category</th>
                                            <th className="py-3.5 px-5 font-bold text-right">Qty Sold</th>
                                            <th className="py-3.5 px-5 font-bold text-right">Total Revenue</th>
                                            <th className="py-3.5 px-5 font-bold text-right">Total Cost</th>
                                            <th className="py-3.5 px-5 font-bold text-right">Net Profit</th>
                                            <th className="py-3.5 px-5 font-bold text-right">Margin %</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-gray-100 text-sm">
                                        {filteredProducts.map((item, index) => (
                                            <tr key={index} className="hover:bg-gray-50/60 transition-colors">
                                                <td className="py-3.5 px-5 font-bold text-gray-900">{item.name}</td>
                                                <td className="py-3.5 px-5 text-gray-500 font-medium">{item.category}</td>
                                                <td className="py-3.5 px-5 text-right font-black text-gray-800">
                                                    <span className="bg-gray-100 px-2.5 py-1 rounded-md">{item.total_sold}x</span>
                                                </td>
                                                <td className="py-3.5 px-5 text-right font-bold text-blue-600">{currency}{item.revenue.toFixed(2)}</td>
                                                <td className="py-3.5 px-5 text-right font-semibold text-amber-600">{currency}{item.cost.toFixed(2)}</td>
                                                <td className="py-3.5 px-5 text-right font-extrabold text-green-600">{currency}{item.profit.toFixed(2)}</td>
                                                <td className="py-3.5 px-5 text-right">
                                                    <span className={`inline-flex px-2.5 py-0.5 rounded-full text-xs font-extrabold ${
                                                        item.margin >= 50 ? 'bg-green-100 text-green-800 border border-green-200' :
                                                        item.margin >= 20 ? 'bg-amber-100 text-amber-800 border border-amber-200' :
                                                        'bg-red-100 text-red-800 border border-red-200'
                                                    }`}>
                                                        {item.margin}%
                                                    </span>
                                                </td>
                                            </tr>
                                        ))}

                                        {filteredProducts.length === 0 && (
                                            <tr>
                                                <td colSpan="7" className="py-12 text-center text-gray-400">
                                                    No product sales recorded for this period.
                                                </td>
                                            </tr>
                                        )}
                                    </tbody>
                                </table>
                            </div>
                        </CardContent>
                    </Card>
                </div>
            )}

            {/* ==================== TAB 3: DELIVERY CHARGES ==================== */}
            {activeTab === 'delivery_charges' && (
                <div className="space-y-6">
                    {/* Delivery KPI Summary Cards */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
                        <Card className="bg-gradient-to-br from-emerald-500 to-green-600 text-white border-0 shadow-md relative overflow-hidden">
                            <CardContent className="p-6">
                                <div className="flex justify-between items-start">
                                    <div>
                                        <p className="text-xs font-bold text-white/80 uppercase tracking-wider mb-1">Collected Delivery Charges</p>
                                        <h3 className="text-3xl font-black">{currency}{(deliverySummary.collectedDeliveryCharges || 0).toFixed(2)}</h3>
                                        <p className="text-xs text-emerald-100 mt-1 font-medium">Total delivery fees collected from customers</p>
                                    </div>
                                    <div className="w-12 h-12 rounded-xl bg-white/20 flex items-center justify-center text-white backdrop-blur-xs">
                                        <Truck className="w-6 h-6" />
                                    </div>
                                </div>
                            </CardContent>
                        </Card>

                        <Card className="bg-white border-0 shadow-sm relative overflow-hidden border-l-4 border-l-blue-600">
                            <CardContent className="p-6">
                                <div className="flex justify-between items-start">
                                    <div>
                                        <p className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-1">Total Delivered Orders</p>
                                        <h3 className="text-3xl font-black text-gray-900">{deliverySummary.totalDeliveredOrders || 0}</h3>
                                        <p className="text-xs text-gray-400 mt-1 font-medium">Total home delivery order count</p>
                                    </div>
                                    <div className="w-12 h-12 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600">
                                        <ShoppingBag className="w-6 h-6" />
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                    </div>

                    {/* Real-time Delivery Search */}
                    <div className="bg-white p-4 rounded-2xl shadow-xs border border-gray-100 flex flex-col sm:flex-row gap-4 items-center justify-between">
                        <div className="relative w-full sm:w-96">
                            <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                            <input 
                                type="text"
                                placeholder="Search by Order #, Customer Name, Phone, or Address..."
                                value={deliverySearch}
                                onChange={(e) => setDeliverySearch(e.target.value)}
                                className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary text-sm transition-all"
                            />
                        </div>

                        <div className="text-xs font-semibold text-gray-500">
                            Showing <strong className="text-gray-900">{filteredDeliveryOrders.length}</strong> delivery order logs
                        </div>
                    </div>

                    {/* Delivery Orders Log Table */}
                    <Card className="shadow-xs border-gray-100">
                        <CardHeader className="bg-gray-50/60 border-b border-gray-100 py-4">
                            <CardTitle className="text-base font-bold text-gray-800 flex items-center gap-2">
                                <Truck className="w-5 h-5 text-emerald-600" />
                                Delivered Orders & Fee Log
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="p-0">
                            <div className="overflow-x-auto">
                                <table className="w-full text-left border-collapse">
                                    <thead>
                                        <tr className="bg-gray-50 text-xs text-gray-500 uppercase tracking-wider border-b border-gray-100">
                                            <th className="py-3.5 px-5 font-bold">Order #</th>
                                            <th className="py-3.5 px-5 font-bold">Customer Name</th>
                                            <th className="py-3.5 px-5 font-bold">Phone Number</th>
                                            <th className="py-3.5 px-5 font-bold">Delivery Address</th>
                                            <th className="py-3.5 px-5 font-bold text-right">Delivery Fee</th>
                                            <th className="py-3.5 px-5 font-bold text-right">Order Total</th>
                                            <th className="py-3.5 px-5 font-bold text-center">Status</th>
                                            <th className="py-3.5 px-5 font-bold text-right">Date</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-gray-100 text-sm">
                                        {filteredDeliveryOrders.map((order) => (
                                            <tr key={order.id} className="hover:bg-gray-50/60 transition-colors">
                                                <td className="py-3.5 px-5 font-black text-gray-900">#{order.id}</td>
                                                <td className="py-3.5 px-5 font-semibold text-gray-800">{order.customer_name}</td>
                                                <td className="py-3.5 px-5 text-gray-600 font-mono text-xs">{order.customer_phone}</td>
                                                <td className="py-3.5 px-5 text-gray-600 text-xs max-w-xs truncate" title={order.delivery_address}>
                                                    {order.delivery_address}
                                                </td>
                                                <td className="py-3.5 px-5 text-right font-black text-emerald-700 bg-emerald-50/50">
                                                    +{currency}{order.delivery_fee.toFixed(2)}
                                                </td>
                                                <td className="py-3.5 px-5 text-right font-bold text-gray-900">
                                                    {currency}{order.total.toFixed(2)}
                                                </td>
                                                <td className="py-3.5 px-5 text-center">
                                                    <Badge variant={order.payment_status === 'paid' ? 'success' : 'warning'}>
                                                        {order.payment_status.toUpperCase()}
                                                    </Badge>
                                                </td>
                                                <td className="py-3.5 px-5 text-right text-xs text-gray-500 font-medium">
                                                    {order.date}
                                                </td>
                                            </tr>
                                        ))}

                                        {filteredDeliveryOrders.length === 0 && (
                                            <tr>
                                                <td colSpan="8" className="py-12 text-center text-gray-400">
                                                    No delivery orders logged for this time period.
                                                </td>
                                            </tr>
                                        )}
                                    </tbody>
                                </table>
                            </div>
                        </CardContent>
                    </Card>
                </div>
            )}
        </AdminLayout>
    );
}
