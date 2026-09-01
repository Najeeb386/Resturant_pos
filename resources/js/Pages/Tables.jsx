import React, { useState } from 'react';
import AdminLayout from '../Layouts/AdminLayout';
import { Card, CardContent } from '../Components/ui/Card';
import { Badge } from '../Components/ui/Badge';
import { Button } from '../Components/ui/Button';
import { Plus, Trash2, X, Loader2, QrCode, Printer, ExternalLink, Sparkles, Lock } from 'lucide-react';
import { useForm, usePage } from '@inertiajs/react';
import { SwalConfirm, SwalToast } from '../Utils/swal';

export default function Tables({ tables = [], hasQrOrdering = true, restaurant = null }) {
    const { auth } = usePage().props;
    const isOwner = auth?.user?.role_id === 2;
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingId, setEditingId] = useState(null);
    const [qrModalTable, setQrModalTable] = useState(null);

    const { data, setData, post, put, delete: destroy, reset, errors, clearErrors, processing } = useForm({
        table_number: '',
        capacity: 4,
        status: 'available'
    });

    const openModal = (table = null) => {
        clearErrors();
        if (table) {
            setEditingId(table.id);
            setData({
                table_number: table.table_number,
                capacity: table.capacity,
                status: table.status
            });
        } else {
            setEditingId(null);
            reset();
        }
        setIsModalOpen(true);
    };

    const closeModal = () => {
        setIsModalOpen(false);
        reset();
        setEditingId(null);
        clearErrors();
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        if (editingId) {
            put(`/tables/${editingId}`, {
                onSuccess: () => {
                    closeModal();
                    SwalToast('Table updated');
                },
            });
        } else {
            post('/tables', {
                onSuccess: () => {
                    closeModal();
                    SwalToast('Table added');
                },
            });
        }
    };

    const handleDelete = (id, e) => {
        e.stopPropagation();
        SwalConfirm({
            title: 'Delete Table?',
            text: 'Are you sure you want to delete this table?',
            confirmButtonText: 'Yes, delete table',
            confirmButtonColor: '#ef4444'
        }).then((result) => {
            if (result.isConfirmed) {
                destroy(`/tables/${id}`, {
                    onSuccess: () => SwalToast('Table deleted')
                });
            }
        });
    };

    const handlePrintQr = () => {
        window.print();
    };

    return (
        <AdminLayout>
            <div className="mb-6 flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 mb-1">Table Management</h1>
                    <p className="text-gray-500">Overview of all restaurant tables, live status, and QR code self-ordering stands.</p>
                </div>
                <div className="flex flex-wrap gap-4 items-center">
                    <div className="flex items-center gap-2">
                        <div className="w-3 h-3 rounded-full bg-green-500"></div>
                        <span className="text-sm text-gray-600">Available</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className="w-3 h-3 rounded-full bg-red-500"></div>
                        <span className="text-sm text-gray-600">Occupied</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className="w-3 h-3 rounded-full bg-blue-500"></div>
                        <span className="text-sm text-gray-600">Reserved</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
                        <span className="text-sm text-gray-600">Cleaning</span>
                    </div>
                    {isOwner && (
                        <Button onClick={() => openModal()} className="sm:ml-4 flex items-center gap-2">
                            <Plus className="w-4 h-4" /> Add Table
                        </Button>
                    )}
                </div>
            </div>

            {/* Plan Upgrade Banner if QR ordering is disabled */}
            {!hasQrOrdering && (
                <div className="mb-6 bg-gradient-to-r from-amber-500/10 to-orange-500/10 border border-amber-200 rounded-2xl p-4 flex items-center justify-between gap-4">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-amber-500 text-white flex items-center justify-center font-bold shrink-0">
                            <Lock className="w-5 h-5" />
                        </div>
                        <div>
                            <h3 className="font-bold text-slate-900 text-sm">QR Code Digital Ordering Available on Upgrade</h3>
                            <p className="text-xs text-slate-600">Table QR code self-ordering is disabled in your current subscription plan. Upgrade your plan in SuperAdmin settings to unlock.</p>
                        </div>
                    </div>
                </div>
            )}

            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 sm:gap-6">
                {tables.map(table => {
                    const restaurantId = restaurant?.id || auth?.user?.restaurant_id || 1;
                    const qrUrl = `${window.location.origin}/table-order/${restaurantId}/${table.id}`;
                    const qrImageUrl = `https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${encodeURIComponent(qrUrl)}`;

                    return (
                        <Card key={table.id} className={`transition-all relative group ${
                            table.status === 'occupied' ? 'border-red-200 bg-red-50/10' :
                            table.status === 'reserved' ? 'border-blue-200 bg-blue-50/10' :
                            table.status === 'cleaning' ? 'border-yellow-200 bg-yellow-50/10' :
                            'border-green-200 bg-green-50/10'
                        }`}>
                            {isOwner && (
                                <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity z-10">
                                    <button onClick={(e) => handleDelete(table.id, e)} className="p-1.5 bg-white text-red-500 hover:bg-red-50 rounded-lg shadow-sm">
                                        <Trash2 className="w-4 h-4" />
                                    </button>
                                </div>
                            )}

                            <CardContent className="p-6">
                                <div className="flex justify-between items-start mb-2">
                                    <h3 className="text-xl font-bold text-gray-800">Table {table.table_number}</h3>
                                    <Badge 
                                        variant={
                                            table.status === 'available' ? 'success' :
                                            table.status === 'occupied' ? 'danger' :
                                            table.status === 'reserved' ? 'primary' : 'warning'
                                        }
                                    >
                                        {table.status}
                                    </Badge>
                                </div>

                                <div className="text-gray-500 text-sm mb-4">
                                    {table.capacity} Seats
                                </div>

                                <div className="flex items-center gap-2 pt-2 border-t border-slate-100">
                                    {isOwner && (
                                        <Button 
                                            variant="outline" 
                                            size="sm" 
                                            onClick={() => openModal(table)}
                                            className="flex-1 text-xs"
                                        >
                                            Edit
                                        </Button>
                                    )}

                                    {hasQrOrdering ? (
                                        <Button 
                                            variant="default" 
                                            size="sm" 
                                            onClick={() => setQrModalTable({ ...table, qrUrl, qrImageUrl })}
                                            className="flex-1 text-xs bg-orange-600 hover:bg-orange-700 text-white flex items-center justify-center gap-1.5 shadow-sm"
                                        >
                                            <QrCode className="w-3.5 h-3.5" /> QR Code
                                        </Button>
                                    ) : (
                                        <Button 
                                            variant="outline" 
                                            size="sm" 
                                            disabled
                                            className="flex-1 text-xs opacity-50 cursor-not-allowed flex items-center justify-center gap-1"
                                            title="QR ordering disabled on current plan"
                                        >
                                            <Lock className="w-3 h-3" /> QR Locked
                                        </Button>
                                    )}
                                </div>
                            </CardContent>
                        </Card>
                    );
                })}
                
                {tables.length === 0 && (
                    <div className="col-span-full py-12 text-center text-gray-500 bg-white rounded-2xl border border-dashed border-gray-300">
                        No tables found. Click "Add Table" to create one.
                    </div>
                )}
            </div>

            {/* Table Add/Edit Modal */}
            {isModalOpen && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl w-full max-w-md shadow-xl overflow-hidden">
                        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
                            <h2 className="text-lg font-bold text-gray-900">
                                {editingId ? 'Edit Table' : 'Add New Table'}
                            </h2>
                            <button onClick={closeModal} className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-full transition-colors">
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Table Number/Name</label>
                                <input
                                    type="text"
                                    value={data.table_number}
                                    onChange={e => setData('table_number', e.target.value)}
                                    className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    placeholder="e.g. 12 or Window 1"
                                    required
                                />
                                {errors.table_number && <p className="text-red-500 text-xs mt-1">{errors.table_number}</p>}
                            </div>
                            
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Capacity (Seats)</label>
                                <input
                                    type="number"
                                    min="1"
                                    value={data.capacity}
                                    onChange={e => setData('capacity', e.target.value)}
                                    className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all"
                                    required
                                />
                                {errors.capacity && <p className="text-red-500 text-xs mt-1">{errors.capacity}</p>}
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
                                <select
                                    value={data.status}
                                    onChange={e => setData('status', e.target.value)}
                                    className="w-full px-4 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary outline-none transition-all bg-white"
                                >
                                    <option value="available">Available</option>
                                    <option value="occupied">Occupied</option>
                                    <option value="reserved">Reserved</option>
                                    <option value="cleaning">Cleaning</option>
                                </select>
                                {errors.status && <p className="text-red-500 text-xs mt-1">{errors.status}</p>}
                            </div>

                            <div className="pt-4 flex gap-3">
                                <Button type="button" variant="outline" className="flex-1" onClick={closeModal} disabled={processing}>
                                    Cancel
                                </Button>
                                <Button type="submit" className="flex-1 flex items-center justify-center gap-2" disabled={processing}>
                                    {processing && <Loader2 className="w-4 h-4 animate-spin" />}
                                    {editingId ? 'Update Table' : 'Save Table'}
                                </Button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Printable Table QR Stand Modal */}
            {qrModalTable && (
                <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-3xl w-full max-w-sm shadow-2xl overflow-hidden border border-slate-100 flex flex-col">
                        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <div className="flex items-center gap-2">
                                <QrCode className="w-5 h-5 text-orange-600" />
                                <h2 className="font-bold text-slate-900 text-sm">Tabletop QR Stand</h2>
                            </div>
                            <button onClick={() => setQrModalTable(null)} className="p-1.5 text-slate-400 hover:text-slate-600 rounded-full hover:bg-slate-200/50">
                                <X className="w-5 h-5" />
                            </button>
                        </div>

                        {/* Printable Area */}
                        <div className="p-6 text-center print-area space-y-4">
                            <div className="border-4 border-orange-500 rounded-3xl p-6 bg-gradient-to-b from-orange-50/50 to-white shadow-xs">
                                <div className="mb-2">
                                    {restaurant?.logo && (
                                        <img src={`/storage/${restaurant.logo}`} alt="Logo" className="w-12 h-12 rounded-full mx-auto mb-2 border-2 border-orange-500 object-cover" />
                                    )}
                                    <h3 className="font-extrabold text-slate-900 text-base">{restaurant?.name || 'DineDesk Restaurant'}</h3>
                                    <span className="inline-block bg-orange-600 text-white font-extrabold text-xs px-3 py-1 rounded-full uppercase tracking-wider mt-1">
                                        Table #{qrModalTable.table_number}
                                    </span>
                                </div>

                                <div className="my-4 bg-white p-3 rounded-2xl shadow-sm border border-slate-100 inline-block">
                                    <img 
                                        src={qrModalTable.qrImageUrl} 
                                        alt={`QR Code Table ${qrModalTable.table_number}`} 
                                        className="w-48 h-48 mx-auto"
                                    />
                                </div>

                                <div className="space-y-1">
                                    <div className="text-xs font-bold text-slate-800 flex items-center justify-center gap-1">
                                        <Sparkles className="w-3.5 h-3.5 text-orange-500" /> Scan to View Menu & Order
                                    </div>
                                    <div className="text-[10px] text-slate-400 font-medium">Point your camera to order directly from your phone</div>
                                </div>
                            </div>
                        </div>

                        <div className="p-4 bg-slate-50 border-t border-slate-100 flex items-center gap-3">
                            <a 
                                href={qrModalTable.qrUrl} 
                                target="_blank" 
                                rel="noreferrer"
                                className="flex-1 border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 font-bold text-xs py-2.5 rounded-xl flex items-center justify-center gap-1.5 shadow-2xs"
                            >
                                <ExternalLink className="w-3.5 h-3.5" /> Test Link
                            </a>
                            <Button 
                                onClick={handlePrintQr} 
                                className="flex-1 bg-orange-600 hover:bg-orange-700 text-white font-bold text-xs py-2.5 rounded-xl flex items-center justify-center gap-1.5 shadow-md shadow-orange-500/20"
                            >
                                <Printer className="w-3.5 h-3.5" /> Print Stand
                            </Button>
                        </div>
                    </div>
                </div>
            )}
        </AdminLayout>
    );
}
