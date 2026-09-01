import React, { useState, useMemo } from 'react';
import SuperAdminLayout from '../../Layouts/SuperAdminLayout';
import { Card, CardContent, CardHeader, CardTitle } from '../../Components/ui/Card';
import { Badge } from '../../Components/ui/Badge';
import { Button } from '../../Components/ui/Button';
import { 
    BarChart3, 
    TrendingUp, 
    TrendingDown, 
    DollarSign, 
    Users, 
    Calendar, 
    Search, 
    Filter, 
    Printer, 
    ArrowUpRight, 
    ArrowDownRight,
    Store,
    PieChart
} from 'lucide-react';
import { router, usePage } from '@inertiajs/react';

export default function Reports({ 
    period = 'all_time', 
    stats = { grossRevenue: '0.00', totalExpenses: '0.00', netProfit: '0.00', activeTenants: 0, totalTenants: 0, arpu: '0.00' },
    financialBreakdown = [],
    tenantRevenues = []
}) {
    const { currencySymbol = '$' } = usePage().props;
    const [searchTerm, setSearchTerm] = useState('');

    const handlePeriodChange = (newPeriod) => {
        router.get('/admin/reports', { period: newPeriod }, { preserveState: true });
    };

    // Filter tenant breakdown table in real-time
    const filteredTenantRevenues = useMemo(() => {
        return tenantRevenues.filter(tenant => {
            const searchLower = searchTerm.toLowerCase();
            const nameMatch = tenant.name?.toLowerCase().includes(searchLower);
            const emailMatch = tenant.email?.toLowerCase().includes(searchLower);
            const planMatch = tenant.plan_name?.toLowerCase().includes(searchLower);
            return !searchTerm || nameMatch || emailMatch || planMatch;
        });
    }, [tenantRevenues, searchTerm]);

    const isProfit = parseFloat(stats.netProfit) >= 0;

    return (
        <SuperAdminLayout>
            {/* Header & Period Filters */}
            <div className="mb-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900 mb-1">Financial & Revenue Analytics</h1>
                    <p className="text-slate-500 text-sm">Comprehensive platform income, operational costs, and profit/loss reporting.</p>
                </div>
                
                {/* Period Selector Buttons */}
                <div className="flex flex-wrap items-center gap-1.5 bg-slate-200/70 p-1.5 rounded-2xl">
                    {[
                        { id: 'all_time', label: 'All Time' },
                        { id: 'this_month', label: 'This Month' },
                        { id: 'last_month', label: 'Last Month' },
                        { id: 'this_quarter', label: 'This Quarter' },
                        { id: 'this_year', label: 'This Year' },
                    ].map(p => (
                        <button
                            key={p.id}
                            onClick={() => handlePeriodChange(p.id)}
                            className={`px-3 py-1.5 text-xs font-semibold rounded-xl transition-all ${
                                period === p.id 
                                    ? 'bg-white text-slate-900 shadow-sm' 
                                    : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100'
                            }`}
                        >
                            {p.label}
                        </button>
                    ))}
                </div>
            </div>

            {/* Financial Health Summary Cards */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
                {/* Gross Revenue */}
                <Card className="border-slate-200 bg-white">
                    <CardContent className="p-5 flex items-center justify-between">
                        <div>
                            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Gross Revenue</p>
                            <h3 className="text-2xl font-extrabold text-slate-900 mt-1">{currencySymbol}{stats.grossRevenue}</h3>
                            <div className="flex items-center gap-1 text-emerald-600 text-xs mt-2 font-medium">
                                <ArrowUpRight className="w-3.5 h-3.5" />
                                <span>Active Subscriptions</span>
                            </div>
                        </div>
                        <div className="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
                            <DollarSign className="w-6 h-6" />
                        </div>
                    </CardContent>
                </Card>

                {/* Total Platform Expenses */}
                <Card className="border-slate-200 bg-white">
                    <CardContent className="p-5 flex items-center justify-between">
                        <div>
                            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Platform Costs</p>
                            <h3 className="text-2xl font-extrabold text-rose-600 mt-1">{currencySymbol}{stats.totalExpenses}</h3>
                            <div className="flex items-center gap-1 text-rose-600 text-xs mt-2 font-medium">
                                <ArrowDownRight className="w-3.5 h-3.5" />
                                <span>Operational Expenses</span>
                            </div>
                        </div>
                        <div className="w-12 h-12 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center">
                            <TrendingDown className="w-6 h-6" />
                        </div>
                    </CardContent>
                </Card>

                {/* Net Profit / Loss */}
                <Card className="border-slate-200 bg-white">
                    <CardContent className="p-5 flex items-center justify-between">
                        <div>
                            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Net Profit / Loss</p>
                            <h3 className={`text-2xl font-extrabold mt-1 ${isProfit ? 'text-emerald-600' : 'text-rose-600'}`}>
                                {isProfit ? '+' : ''}{currencySymbol}{stats.netProfit}
                            </h3>
                            <div className={`flex items-center gap-1 text-xs mt-2 font-medium ${isProfit ? 'text-emerald-600' : 'text-rose-600'}`}>
                                {isProfit ? <TrendingUp className="w-3.5 h-3.5" /> : <TrendingDown className="w-3.5 h-3.5" />}
                                <span>{isProfit ? 'Net Earnings' : 'Net Loss'}</span>
                            </div>
                        </div>
                        <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${isProfit ? 'bg-emerald-50 text-emerald-600' : 'bg-rose-50 text-rose-600'}`}>
                            <PieChart className="w-6 h-6" />
                        </div>
                    </CardContent>
                </Card>

                {/* Average Revenue Per Tenant (ARPU) */}
                <Card className="border-slate-200 bg-white">
                    <CardContent className="p-5 flex items-center justify-between">
                        <div>
                            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">ARPU (Avg / Tenant)</p>
                            <h3 className="text-2xl font-extrabold text-indigo-600 mt-1">{currencySymbol}{stats.arpu}</h3>
                            <div className="text-xs text-slate-500 mt-2 font-medium">
                                Across {stats.activeTenants} active tenants
                            </div>
                        </div>
                        <div className="w-12 h-12 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
                            <Users className="w-6 h-6" />
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Monthly Trend Breakdown */}
            <Card className="mb-6 border-slate-200 shadow-sm">
                <CardHeader className="p-5 border-b border-slate-100 flex flex-row items-center justify-between">
                    <CardTitle className="text-lg font-bold text-slate-900">Monthly Profit & Loss Analysis</CardTitle>
                    <Badge variant="outline" className="text-xs text-slate-500 font-normal">Last 12 Months</Badge>
                </CardHeader>
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-slate-50/80 border-b border-slate-200">
                                    <th className="py-3.5 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Month</th>
                                    <th className="py-3.5 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Gross Income</th>
                                    <th className="py-3.5 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Operational Expenses</th>
                                    <th className="py-3.5 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Net Profit / Loss</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {financialBreakdown.length === 0 ? (
                                    <tr>
                                        <td colSpan="4" className="py-8 text-center text-slate-500">No monthly financial records found for this period.</td>
                                    </tr>
                                ) : financialBreakdown.map((row, idx) => (
                                    <tr key={idx} className="hover:bg-slate-50/50 transition-colors">
                                        <td className="py-3.5 px-6 font-bold text-slate-900">{row.month}</td>
                                        <td className="py-3.5 px-6 font-bold text-emerald-600">{currencySymbol}{row.revenue.toFixed(2)}</td>
                                        <td className="py-3.5 px-6 font-bold text-rose-600">{currencySymbol}{row.expenses.toFixed(2)}</td>
                                        <td className={`py-3.5 px-6 font-extrabold ${row.net >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                                            {row.net >= 0 ? '+' : ''}{currencySymbol}{row.net.toFixed(2)}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>

            {/* Tenant Earnings Breakdown Table */}
            <Card className="border-slate-200 shadow-sm overflow-hidden">
                <CardHeader className="p-5 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <div>
                        <CardTitle className="text-lg font-bold text-slate-900">Tenant Subscription Revenue Breakdown</CardTitle>
                        <p className="text-xs text-slate-500">Individual subscription earnings per registered restaurant.</p>
                    </div>

                    {/* Real-time Search Input */}
                    <div className="relative w-full sm:w-80">
                        <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
                        <input
                            type="text"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            placeholder="Search tenant or plan..."
                            className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
                        />
                    </div>
                </CardHeader>
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-slate-50/80 border-b border-slate-200">
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Restaurant</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Plan</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">MRR Value</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Joined Date</th>
                                    <th className="py-4 px-6 font-semibold text-slate-600 text-xs uppercase tracking-wider">Status</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100">
                                {filteredTenantRevenues.length === 0 ? (
                                    <tr>
                                        <td colSpan="5" className="py-8 text-center text-slate-500">No tenants found matching your search.</td>
                                    </tr>
                                ) : filteredTenantRevenues.map(tenant => (
                                    <tr key={tenant.id} className="hover:bg-slate-50/50 transition-colors">
                                        <td className="py-4 px-6">
                                            <div className="font-bold text-slate-900">{tenant.name}</div>
                                            <div className="text-xs text-slate-400">{tenant.email}</div>
                                        </td>
                                        <td className="py-4 px-6 text-sm font-semibold text-slate-700">{tenant.plan_name}</td>
                                        <td className="py-4 px-6 font-extrabold text-slate-900">{currencySymbol}{parseFloat(tenant.plan_price).toFixed(2)}</td>
                                        <td className="py-4 px-6 text-sm text-slate-500">{tenant.joined_at}</td>
                                        <td className="py-4 px-6">
                                            <Badge className={`border ${
                                                tenant.status === 'active' ? 'bg-emerald-50 text-emerald-700 border-emerald-200' :
                                                tenant.status === 'expired' ? 'bg-amber-50 text-amber-700 border-amber-200' :
                                                'bg-slate-100 text-slate-600 border-slate-200'
                                            }`}>
                                                {tenant.status}
                                            </Badge>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>
        </SuperAdminLayout>
    );
}
