import React, { useRef } from 'react';
import AdminLayout from '../../Layouts/AdminLayout';
import { Card, CardContent } from '../../Components/ui/Card';
import { Button } from '../../Components/ui/Button';
import { useForm, usePage } from '@inertiajs/react';
import { Save, Upload, Loader2 } from 'lucide-react';

export default function Profile({ restaurant }) {
    const fileInputRef = useRef(null);
    const { flash } = usePage().props;
    const { data, setData, post, processing, errors, progress } = useForm({
        name: restaurant.name || '',
        phone: restaurant.phone || '',
        address: restaurant.address || '',
        email: restaurant.email || '',
        gst_number: restaurant.gst_number || '',
        currency: restaurant.currency || 'USD',
        currency_symbol: restaurant.currency_symbol || '$',
        tax_percentage: restaurant.tax_percentage || 10,
        receipt_header: restaurant.receipt_header || '',
        receipt_footer: restaurant.receipt_footer || '',
        kitchen_bypass: Boolean(restaurant.kitchen_bypass),
        logo: null,
        _method: 'post', // Since we use POST route for handling files easily in Laravel
    });

    const handleSubmit = (e) => {
        e.preventDefault();
        post('/settings/profile', {
            preserveScroll: true,
            onSuccess: () => {
                // optionally reset file input
                if (fileInputRef.current) {
                    fileInputRef.current.value = '';
                }
                setData('logo', null);
            }
        });
    };

    return (
        <AdminLayout>
            <div className="max-w-4xl mx-auto">
                <div className="mb-6">
                    <h1 className="text-2xl font-bold text-gray-900 mb-1">Restaurant Profile</h1>
                    <p className="text-gray-500">Manage your restaurant details, branding, and receipt settings.</p>
                </div>

                {flash?.message && (
                    <div className="mb-6 p-4 bg-green-50 text-green-600 rounded-xl border border-green-200 font-medium">
                        {flash.message}
                    </div>
                )}

                <Card>
                    <CardContent className="p-6">
                        <form onSubmit={handleSubmit} className="space-y-6">
                            {/* Logo Upload Section */}
                            <div className="flex flex-col sm:flex-row gap-6 items-start sm:items-center border-b border-gray-100 pb-6">
                                <div className="w-24 h-24 rounded-2xl border-2 border-dashed border-gray-300 flex items-center justify-center bg-gray-50 overflow-hidden relative group">
                                    {data.logo ? (
                                        <img src={URL.createObjectURL(data.logo)} alt="Preview" className="w-full h-full object-cover" />
                                    ) : restaurant.logo ? (
                                        <img src={`/storage/${restaurant.logo}`} alt="Logo" className="w-full h-full object-cover" />
                                    ) : (
                                        <span className="text-gray-400 font-medium">Logo</span>
                                    )}
                                    <div 
                                        className="absolute inset-0 bg-black/50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer"
                                        onClick={() => fileInputRef.current?.click()}
                                    >
                                        <Upload className="w-6 h-6 text-white" />
                                    </div>
                                </div>
                                <div>
                                    <h3 className="font-semibold text-gray-900 mb-1">Restaurant Logo</h3>
                                    <p className="text-sm text-gray-500 mb-3">Upload a square image (PNG, JPG) up to 2MB.</p>
                                    <input 
                                        type="file" 
                                        ref={fileInputRef}
                                        className="hidden" 
                                        accept="image/*"
                                        onChange={e => setData('logo', e.target.files[0])}
                                    />
                                    <Button type="button" variant="outline" onClick={() => fileInputRef.current?.click()}>
                                        Choose File
                                    </Button>
                                    {progress && (
                                        <progress value={progress.percentage} max="100" className="ml-3">
                                            {progress.percentage}%
                                        </progress>
                                    )}
                                    {errors.logo && <p className="text-red-500 text-xs mt-1">{errors.logo}</p>}
                                </div>
                            </div>

                            {/* Basic Details */}
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Restaurant Name</label>
                                    <input
                                        type="text"
                                        value={data.name}
                                        onChange={e => setData('name', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        required
                                    />
                                    {errors.name && <p className="text-red-500 text-xs mt-1">{errors.name}</p>}
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Phone Number</label>
                                    <input
                                        type="text"
                                        value={data.phone}
                                        onChange={e => setData('phone', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    />
                                    {errors.phone && <p className="text-red-500 text-xs mt-1">{errors.phone}</p>}
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Email Address</label>
                                    <input
                                        type="email"
                                        value={data.email}
                                        onChange={e => setData('email', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    />
                                    {errors.email && <p className="text-red-500 text-xs mt-1">{errors.email}</p>}
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">GST / Tax Number</label>
                                    <input
                                        type="text"
                                        value={data.gst_number}
                                        onChange={e => setData('gst_number', e.target.value)}
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    />
                                    {errors.gst_number && <p className="text-red-500 text-xs mt-1">{errors.gst_number}</p>}
                                </div>
                                <div className="md:col-span-2">
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Complete Address</label>
                                    <textarea
                                        value={data.address}
                                        onChange={e => setData('address', e.target.value)}
                                        rows="3"
                                        className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        required
                                    ></textarea>
                                    {errors.address && <p className="text-red-500 text-xs mt-1">{errors.address}</p>}
                                </div>
                            </div>

                            {/* Financial Settings */}
                            <div className="pt-6 border-t border-gray-100">
                                <h3 className="font-semibold text-gray-900 mb-4">Financial Settings</h3>
                                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-1">Currency Code</label>
                                        <input
                                            type="text"
                                            value={data.currency}
                                            onChange={e => setData('currency', e.target.value)}
                                            placeholder="e.g. USD, EUR, INR"
                                            className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        />
                                        {errors.currency && <p className="text-red-500 text-xs mt-1">{errors.currency}</p>}
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-1">Currency Symbol</label>
                                        <input
                                            type="text"
                                            value={data.currency_symbol}
                                            onChange={e => setData('currency_symbol', e.target.value)}
                                            placeholder="e.g. $, €, ₹"
                                            className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        />
                                        {errors.currency_symbol && <p className="text-red-500 text-xs mt-1">{errors.currency_symbol}</p>}
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-1">Tax Percentage (%)</label>
                                        <input
                                            type="number"
                                            step="0.01"
                                            value={data.tax_percentage}
                                            onChange={e => setData('tax_percentage', e.target.value)}
                                            className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        />
                                        {errors.tax_percentage && <p className="text-red-500 text-xs mt-1">{errors.tax_percentage}</p>}
                                    </div>
                                </div>
                            </div>

                            {/* Kitchen Settings */}
                            <div className="pt-6 border-t border-gray-100">
                                <h3 className="font-semibold text-gray-900 mb-4">Kitchen Workflow</h3>
                                <div className="bg-orange-50 border border-orange-100 p-4 rounded-xl">
                                    <label className="flex items-start gap-3 cursor-pointer">
                                        <div className="flex items-center h-5 mt-0.5">
                                            <input
                                                type="checkbox"
                                                checked={data.kitchen_bypass}
                                                onChange={e => setData('kitchen_bypass', e.target.checked)}
                                                className="w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
                                            />
                                        </div>
                                        <div>
                                            <span className="block text-sm font-medium text-orange-900">Bypass Kitchen Module</span>
                                            <span className="block text-sm text-orange-700 mt-1">If enabled, the cashier/owner can manually mark orders as Preparing, Ready, and Completed directly from the POS or Orders screen. Useful if you don't have a separate kitchen display.</span>
                                        </div>
                                    </label>
                                </div>
                            </div>

                            {/* Receipt Settings */}
                            <div className="pt-6 border-t border-gray-100">
                                <h3 className="font-semibold text-gray-900 mb-4">Receipt Settings</h3>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-1">Receipt Header Message</label>
                                        <textarea
                                            value={data.receipt_header}
                                            onChange={e => setData('receipt_header', e.target.value)}
                                            rows="2"
                                            placeholder="e.g. Welcome to our Restaurant!"
                                            className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        ></textarea>
                                        {errors.receipt_header && <p className="text-red-500 text-xs mt-1">{errors.receipt_header}</p>}
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-1">Receipt Footer Message</label>
                                        <textarea
                                            value={data.receipt_footer}
                                            onChange={e => setData('receipt_footer', e.target.value)}
                                            rows="2"
                                            placeholder="e.g. Thank you for dining with us!"
                                            className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                        ></textarea>
                                        {errors.receipt_footer && <p className="text-red-500 text-xs mt-1">{errors.receipt_footer}</p>}
                                    </div>
                                </div>
                            </div>

                            <div className="pt-6 border-t border-gray-100 flex justify-end">
                                <Button type="submit" disabled={processing} className="flex items-center gap-2">
                                    {processing ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />} 
                                    {processing ? 'Saving...' : 'Save Changes'}
                                </Button>
                            </div>
                        </form>
                    </CardContent>
                </Card>
            </div>
        </AdminLayout>
    );
}
