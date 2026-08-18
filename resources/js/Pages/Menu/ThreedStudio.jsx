import React, { useState, useRef, useEffect } from 'react';
import AdminLayout from '../../Layouts/AdminLayout';
import { Card, CardContent } from '../../Components/ui/Card';
import { Button } from '../../Components/ui/Button';
import { useForm, usePage, router } from '@inertiajs/react';
import ThreedViewer from '../../Components/3D/ThreedViewer';
import { 
    Box, 
    Camera, 
    Upload, 
    Sparkles, 
    CheckCircle2, 
    Loader2, 
    RotateCw, 
    UtensilsCrossed, 
    AlertTriangle, 
    ArrowRight,
    Layers,
    Plus,
    X,
    Trash2,
    Eye
} from 'lucide-react';

export default function ThreedStudio({ menuItems = [], hasFeature = true }) {
    const { flash, currencySymbol = '$' } = usePage().props;
    const [selectedItem, setSelectedItem] = useState(menuItems[0] ? String(menuItems[0].id) : '');
    const [photoPreviews, setPhotoPreviews] = useState([null, null, null, null]);
    const [previewModalItem, setPreviewModalItem] = useState(null);
    const fileInputRefs = [useRef(null), useRef(null), useRef(null), useRef(null)];
    const topFormRef = useRef(null);

    // Auto load Google <model-viewer> web component for 3D GLB models preview
    useEffect(() => {
        if (!document.getElementById('model-viewer-script')) {
            const script = document.createElement('script');
            script.id = 'model-viewer-script';
            script.type = 'module';
            script.src = 'https://ajax.googleapis.com/ajax/libs/model-viewer/3.4.0/model-viewer.min.js';
            document.head.appendChild(script);
        }
    }, []);

    const [studioMode, setStudioMode] = useState('photos'); // 'photos' | 'upload_3d'
    const [guidedCameraSlot, setGuidedCameraSlot] = useState(null); // null | 0 | 1 | 2 | 3
    const guidedVideoRef = useRef(null);
    const guidedCanvasRef = useRef(null);

    const { data, setData, post, processing, errors, progress } = useForm({
        menu_item_id: selectedItem,
        photos: [],
        model_file: null,
    });

    const angleLabels = [
        { label: 'Front View', icon: '📸', desc: 'Direct eye-level front photo of the dish' },
        { label: '45° Top Angle', icon: '📐', desc: '45-degree angle showing top & sides' },
        { label: 'Left Side', icon: '👈', desc: 'Left profile angle of the dish' },
        { label: 'Right Side', icon: '👉', desc: 'Right profile angle of the dish' },
    ];

    const openGuidedCamera = (slotIdx) => {
        setGuidedCameraSlot(slotIdx);
    };

    const closeGuidedCamera = () => {
        if (guidedVideoRef.current && guidedVideoRef.current.srcObject) {
            const tracks = guidedVideoRef.current.srcObject.getTracks();
            tracks.forEach(track => track.stop());
            guidedVideoRef.current.srcObject = null;
        }
        setGuidedCameraSlot(null);
    };

    useEffect(() => {
        let streamTrack = null;
        if (guidedCameraSlot !== null) {
            navigator.mediaDevices.getUserMedia({ video: { facingMode: { ideal: 'environment' } } })
                .then(stream => {
                    streamTrack = stream;
                    if (guidedVideoRef.current) {
                        guidedVideoRef.current.srcObject = stream;
                        guidedVideoRef.current.play().catch(e => console.log(e));
                    }
                })
                .catch(err => {
                    console.log("Guided camera error:", err);
                    alert("Please allow camera access to capture 360° dish photos.");
                    setGuidedCameraSlot(null);
                });
        }
        return () => {
            if (streamTrack) {
                streamTrack.getTracks().forEach(track => track.stop());
            }
        };
    }, [guidedCameraSlot]);

    const captureGuidedPhoto = () => {
        if (!guidedVideoRef.current || !guidedCanvasRef.current || guidedCameraSlot === null) return;

        const video = guidedVideoRef.current;
        const canvas = guidedCanvasRef.current;
        canvas.width = video.videoWidth || 1280;
        canvas.height = video.videoHeight || 720;

        const ctx = canvas.getContext('2d');
        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

        canvas.toBlob((blob) => {
            if (!blob) return;
            const file = new File([blob], `angle_${guidedCameraSlot + 1}.jpg`, { type: 'image/jpeg' });
            handlePhotoChange(guidedCameraSlot, file);

            if (guidedCameraSlot < 3) {
                setGuidedCameraSlot(guidedCameraSlot + 1);
            } else {
                closeGuidedCamera();
            }
        }, 'image/jpeg', 0.92);
    };

    const handlePhotoChange = (index, file) => {
        if (!file) return;
        const newPreviews = [...photoPreviews];
        newPreviews[index] = URL.createObjectURL(file);
        setPhotoPreviews(newPreviews);

        const newPhotos = [...data.photos];
        newPhotos[index] = file;
        setData('photos', newPhotos);
    };

    const handleRemovePhoto = (index) => {
        const newPreviews = [...photoPreviews];
        newPreviews[index] = null;
        setPhotoPreviews(newPreviews);

        const newPhotos = [...data.photos];
        newPhotos[index] = null;
        setData('photos', newPhotos);
        if (fileInputRefs[index].current) {
            fileInputRefs[index].current.value = '';
        }
    };

    const handleItemSelect = (id) => {
        setSelectedItem(id);
        setData('menu_item_id', id);

        const found = menuItems.find(i => String(i.id) === String(id));
        if (found) {
            setPreviewModalItem(found);
        }
    };

    const handlePreviewClick = (item) => {
        setSelectedItem(String(item.id));
        setData('menu_item_id', String(item.id));
        setPreviewModalItem(item);
        if (topFormRef.current) {
            topFormRef.current.scrollIntoView({ behavior: 'smooth' });
        }
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        const validPhotos = data.photos.filter(Boolean);
        if (validPhotos.length < 3) {
            alert("Please upload at least 3 angle photos of the dish to generate the 3D model.");
            return;
        }

        post('/menu/3d-studio/generate', {
            preserveScroll: true,
            onSuccess: () => {
                setPhotoPreviews([null, null, null, null]);
                setData('photos', []);
            }
        });
    };

    const currentItem = menuItems.find(i => String(i.id) === String(selectedItem));

    return (
        <AdminLayout>
            <div className="max-w-5xl mx-auto space-y-6" ref={topFormRef}>
                {/* Top Banner */}
                <div className="bg-gradient-to-r from-slate-900 via-amber-950 to-slate-900 text-white rounded-3xl p-6 shadow-xl border border-amber-500/20 relative overflow-hidden">
                    <div className="absolute -right-6 -bottom-6 w-48 h-48 bg-amber-500/10 rounded-full blur-3xl pointer-events-none"></div>
                    <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-4">
                        <div>
                            <div className="inline-flex items-center gap-1.5 px-3 py-1 bg-amber-500/20 border border-amber-500/30 text-amber-300 rounded-full text-xs font-bold mb-3">
                                <Sparkles className="w-3.5 h-3.5" /> AI Photogrammetry & AR Studio
                            </div>
                            <h1 className="text-2xl font-extrabold tracking-tight drop-shadow-xs">3D Food Menu Creator</h1>
                            <p className="text-xs text-slate-300 mt-1 max-w-xl leading-relaxed">
                                Upload 360° angle photos of your restaurant dishes. Our AI engine will automatically generate interactive 3D models and project them live on customers' dining tables in Augmented Reality!
                            </p>
                        </div>

                        <div className="flex items-center gap-3 shrink-0">
                            <div className="bg-slate-800/80 border border-slate-700/80 rounded-2xl p-3 text-center">
                                <div className="text-xl font-black text-amber-400">
                                    {menuItems.filter(i => i.model_3d).length} / {menuItems.length}
                                </div>
                                <div className="text-[10px] text-slate-400 font-medium uppercase">3D Models Ready</div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Plan Notice */}
                {!hasFeature && (
                    <div className="bg-amber-50 border border-amber-200 text-amber-900 rounded-2xl p-4 flex items-center justify-between">
                        <div className="flex items-center gap-3">
                            <AlertTriangle className="w-5 h-5 text-amber-600 shrink-0" />
                            <div className="text-xs">
                                <strong className="font-bold block">Upgrade Plan for Full AI 3D Generator Access</strong>
                                AI 3D Menu Studio is included in Pro & Enterprise SaaS subscription plans.
                            </div>
                        </div>
                    </div>
                )}

                {flash?.message && (
                    <div className="p-4 bg-emerald-50 text-emerald-700 rounded-2xl border border-emerald-200 font-medium flex items-center gap-2 text-sm shadow-xs">
                        <CheckCircle2 className="w-5 h-5 text-emerald-600 shrink-0" />
                        {flash.message}
                    </div>
                )}

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    {/* Left 2 Cols: 3D Generator Form */}
                    <div className="lg:col-span-2 space-y-6">
                        <Card className="rounded-3xl border-gray-100 shadow-sm">
                            <CardContent className="p-6">
                                <form onSubmit={handleSubmit} className="space-y-6">
                                    {/* Step 1: Select Menu Item */}
                                    <div>
                                        <label className="block text-sm font-bold text-gray-900 mb-2 flex items-center gap-2">
                                            <span className="w-6 h-6 bg-amber-500 text-white rounded-full text-xs font-black flex items-center justify-center">1</span>
                                            Select Restaurant Menu Item
                                        </label>
                                        <select
                                            value={selectedItem}
                                            onChange={e => handleItemSelect(e.target.value)}
                                            className="w-full px-4 py-3 border border-gray-200 rounded-2xl focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none text-sm font-medium transition-all"
                                            required
                                        >
                                            {menuItems.map(item => (
                                                <option key={item.id} value={item.id}>
                                                    {item.name} ({item.category ? item.category.name : 'General'}) - {currencySymbol}{Number(item.price).toFixed(2)} {item.model_3d ? '✓ (3D Active)' : ''}
                                                </option>
                                            ))}
                                        </select>
                                    </div>

                                    {/* Step 2: Choose 3D Creation Method */}
                                    <div>
                                        <label className="block text-sm font-bold text-gray-900 mb-2 flex items-center gap-2">
                                            <span className="w-6 h-6 bg-amber-500 text-white rounded-full text-xs font-black flex items-center justify-center">2</span>
                                            Choose 3D Model Creation Method
                                        </label>

                                        <div className="grid grid-cols-2 gap-3 mb-5">
                                            <button
                                                type="button"
                                                onClick={() => setStudioMode('photos')}
                                                className={`p-3.5 rounded-2xl border text-left transition-all flex items-center gap-3 ${
                                                    studioMode === 'photos'
                                                        ? 'border-amber-500 bg-amber-50/50 ring-2 ring-amber-500/20 text-amber-950 font-bold'
                                                        : 'border-gray-200 hover:border-gray-300 text-gray-600 bg-gray-50/50'
                                                }`}
                                            >
                                                <div className={`p-2.5 rounded-xl ${studioMode === 'photos' ? 'bg-amber-500 text-white' : 'bg-gray-200 text-gray-600'}`}>
                                                    <Camera className="w-5 h-5" />
                                                </div>
                                                <div>
                                                    <div className="text-xs font-extrabold">Option A: Guided AI Scanner</div>
                                                    <div className="text-[10px] text-gray-500 font-normal">Snap 360° photos with guided camera</div>
                                                </div>
                                            </button>

                                            <button
                                                type="button"
                                                onClick={() => setStudioMode('upload_3d')}
                                                className={`p-3.5 rounded-2xl border text-left transition-all flex items-center gap-3 ${
                                                    studioMode === 'upload_3d'
                                                        ? 'border-amber-500 bg-amber-50/50 ring-2 ring-amber-500/20 text-amber-950 font-bold'
                                                        : 'border-gray-200 hover:border-gray-300 text-gray-600 bg-gray-50/50'
                                                }`}
                                            >
                                                <div className={`p-2.5 rounded-xl ${studioMode === 'upload_3d' ? 'bg-amber-500 text-white' : 'bg-gray-200 text-gray-600'}`}>
                                                    <Box className="w-5 h-5" />
                                                </div>
                                                <div>
                                                    <div className="text-xs font-extrabold">Option B: Direct 3D Upload</div>
                                                    <div className="text-[10px] text-gray-500 font-normal">Upload custom .glb / .gltf file</div>
                                                </div>
                                            </button>
                                        </div>

                                        {/* Option A: Guided 360° Photo Angles */}
                                        {studioMode === 'photos' && (
                                            <div className="space-y-4">
                                                <div className="flex items-center justify-between">
                                                    <p className="text-xs text-gray-500">Capture 360° angle photos using live camera or upload photo files.</p>
                                                    <button
                                                        type="button"
                                                        onClick={() => openGuidedCamera(0)}
                                                        className="px-3 py-1.5 bg-gradient-to-r from-amber-500 to-orange-500 text-white rounded-xl text-xs font-bold flex items-center gap-1.5 shadow-sm hover:brightness-105 transition-all"
                                                    >
                                                        <Camera className="w-3.5 h-3.5" /> Launch Guided Camera
                                                    </button>
                                                </div>

                                                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                                                    {angleLabels.map((angle, idx) => (
                                                        <div 
                                                            key={idx}
                                                            className={`border-2 border-dashed rounded-2xl p-2.5 text-center flex flex-col items-center justify-center h-48 relative transition-all group ${
                                                                photoPreviews[idx] ? 'border-amber-500 bg-amber-50/30' : 'border-gray-200 hover:border-amber-400 bg-gray-50/50'
                                                            }`}
                                                        >
                                                            {photoPreviews[idx] ? (
                                                                <div className="w-full h-full relative rounded-xl overflow-hidden">
                                                                    <img src={photoPreviews[idx]} alt={angle.label} className="w-full h-full object-cover" />
                                                                    <button
                                                                        type="button"
                                                                        onClick={() => handleRemovePhoto(idx)}
                                                                        className="absolute top-1 right-1 bg-red-600 text-white p-1 rounded-full shadow-md hover:bg-red-700 transition-colors"
                                                                    >
                                                                        <X className="w-3.5 h-3.5" />
                                                                    </button>
                                                                </div>
                                                            ) : (
                                                                <div className="flex flex-col items-center justify-between w-full h-full p-1">
                                                                    <div className="text-center pt-2">
                                                                        <span className="text-2xl block mb-1">{angle.icon}</span>
                                                                        <span className="text-xs font-bold text-gray-800">{angle.label}</span>
                                                                        <span className="text-[9px] text-gray-400 line-clamp-1 mt-0.5">{angle.desc}</span>
                                                                    </div>

                                                                    <div className="flex flex-col gap-1 w-full mt-2">
                                                                        <button
                                                                            type="button"
                                                                            onClick={() => openGuidedCamera(idx)}
                                                                            className="w-full py-1 bg-amber-500 hover:bg-amber-600 text-white font-bold rounded-lg text-[10px] flex items-center justify-center gap-1 shadow-xs transition-colors"
                                                                        >
                                                                            <Camera className="w-3 h-3" /> Snap Live
                                                                        </button>
                                                                        <button
                                                                            type="button"
                                                                            onClick={() => fileInputRefs[idx].current?.click()}
                                                                            className="w-full py-1 bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium rounded-lg text-[10px] flex items-center justify-center gap-1 transition-colors"
                                                                        >
                                                                            <Upload className="w-3 h-3" /> Upload
                                                                        </button>
                                                                    </div>
                                                                </div>
                                                            )}

                                                            <input 
                                                                type="file" 
                                                                ref={fileInputRefs[idx]}
                                                                accept="image/*" 
                                                                className="hidden" 
                                                                onChange={e => handlePhotoChange(idx, e.target.files[0])}
                                                            />
                                                        </div>
                                                    ))}
                                                </div>
                                            </div>
                                        )}

                                        {/* Option B: Direct 3D File Upload (.glb / .gltf) */}
                                        {studioMode === 'upload_3d' && (
                                            <div className="space-y-4 border-2 border-dashed border-amber-300 bg-amber-50/20 rounded-2xl p-6 text-center">
                                                <Box className="w-12 h-12 text-amber-500 mx-auto" />
                                                <div>
                                                    <h4 className="font-extrabold text-sm text-gray-900">Upload 3D Model File (.glb or .gltf)</h4>
                                                    <p className="text-xs text-gray-500 mt-1 max-w-sm mx-auto">
                                                        Select a 3D GLB or glTF mesh file created by your 3D designer or 3D scanner app.
                                                    </p>
                                                </div>

                                                <label className="inline-flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white font-bold text-xs px-5 py-2.5 rounded-xl cursor-pointer shadow-md transition-all">
                                                    <Upload className="w-4 h-4" />
                                                    Browse 3D Model File
                                                    <input
                                                        type="file"
                                                        accept=".glb,.gltf"
                                                        className="hidden"
                                                        onChange={e => setData('model_file', e.target.files[0])}
                                                    />
                                                </label>

                                                {data.model_file && (
                                                    <div className="p-3 bg-white rounded-xl border border-amber-200 flex items-center justify-between text-xs max-w-md mx-auto shadow-xs">
                                                        <div className="flex items-center gap-2 font-bold text-gray-800 truncate">
                                                            <Box className="w-4 h-4 text-amber-500 shrink-0" />
                                                            <span className="truncate">{data.model_file.name}</span>
                                                            <span className="text-[10px] text-gray-400 font-normal shrink-0">
                                                                ({(data.model_file.size / (1024 * 1024)).toFixed(2)} MB)
                                                            </span>
                                                        </div>
                                                        <button
                                                            type="button"
                                                            onClick={() => setData('model_file', null)}
                                                            className="text-red-600 hover:text-red-700 p-1"
                                                        >
                                                            <X className="w-4 h-4" />
                                                        </button>
                                                    </div>
                                                )}
                                            </div>
                                        )}
                                    </div>

                                    {/* Submit Action */}
                                    <div className="pt-4 border-t border-gray-100 flex items-center justify-between">
                                        <div className="text-xs text-gray-500 font-medium">
                                            {studioMode === 'photos' ? `Uploaded: ${data.photos.filter(Boolean).length} / 4 Photos` : data.model_file ? '1 3D Model File Selected' : 'No File Selected'}
                                        </div>
                                        <Button
                                            type="submit"
                                            disabled={processing || (studioMode === 'photos' && data.photos.filter(Boolean).length < 1) || (studioMode === 'upload_3d' && !data.model_file)}
                                            className="bg-amber-500 hover:bg-amber-600 text-white font-bold px-6 py-3 rounded-2xl shadow-lg shadow-amber-500/30 flex items-center gap-2 transition-all active:scale-95 disabled:opacity-50"
                                        >
                                            {processing ? (
                                                <>
                                                    <Loader2 className="w-4 h-4 animate-spin" />
                                                    {studioMode === 'photos' ? 'Synthesizing AI 3D Mesh...' : 'Uploading 3D Model...'}
                                                </>
                                            ) : (
                                                <>
                                                    <Sparkles className="w-4 h-4" />
                                                    {studioMode === 'photos' ? 'Generate AI 3D Model' : 'Save & Map 3D Model'}
                                                </>
                                            )}
                                        </Button>
                                    </div>
                                </form>
                            </CardContent>
                        </Card>
                    </div>

                    {/* Right 1 Col: Live 3D Model Card Preview */}
                    <div className="space-y-6">
                        <Card className="rounded-3xl border-gray-100 shadow-sm overflow-hidden cursor-pointer hover:shadow-md transition-shadow" onClick={() => currentItem && setPreviewModalItem(currentItem)}>
                            <CardContent className="p-5 space-y-4">
                                <div className="flex items-center justify-between border-b border-gray-100 pb-3">
                                    <h3 className="font-bold text-sm text-gray-900 flex items-center gap-1.5">
                                        <Box className="w-4 h-4 text-amber-500" />
                                        Active 3D Dish Preview
                                    </h3>
                                    {currentItem?.model_3d && (
                                        <span className="bg-emerald-100 text-emerald-700 text-[10px] font-bold px-2 py-0.5 rounded-full">
                                            3D Mesh Ready
                                        </span>
                                    )}
                                </div>

                                {currentItem ? (
                                    <div className="space-y-3">
                                        <div className="relative h-48 bg-slate-900 rounded-2xl overflow-hidden flex items-center justify-center border border-slate-800 p-4">
                                            {currentItem.model_3d ? (
                                                <model-viewer
                                                    src={`/storage/${currentItem.model_3d}`}
                                                    alt={currentItem.name}
                                                    auto-rotate
                                                    camera-controls
                                                    shadow-intensity="1.5"
                                                    environment-image="neutral"
                                                    exposure="1"
                                                    style={{ width: '100%', height: '100%' }}
                                                ></model-viewer>
                                            ) : currentItem.image ? (
                                                <img src={`/storage/${currentItem.image}`} alt={currentItem.name} className="w-32 h-32 object-cover rounded-full shadow-2xl ring-2 ring-white/10" />
                                            ) : (
                                                <div className="w-32 h-32 rounded-full bg-slate-800 flex items-center justify-center text-amber-400">
                                                    <UtensilsCrossed className="w-12 h-12" />
                                                </div>
                                            )}
                                            <div className="absolute bottom-2 left-2 right-2 text-center bg-black/60 backdrop-blur-xs text-[10px] text-amber-300 py-1 rounded-xl font-bold flex items-center justify-center gap-1">
                                                <RotateCw className="w-3 h-3 animate-spin" /> Click for Full 360° Stage
                                            </div>
                                        </div>

                                        <div>
                                            <h4 className="font-bold text-gray-900 text-base">{currentItem.name}</h4>
                                            <p className="text-xs text-gray-500 line-clamp-2 mt-0.5">{currentItem.description || 'Delicious restaurant dish ready for customer AR 3D preview.'}</p>
                                            <div className="text-sm font-black text-amber-600 mt-2">{currencySymbol}{Number(currentItem.price).toFixed(2)}</div>
                                        </div>
                                    </div>
                                ) : (
                                    <div className="text-center py-8 text-gray-400 text-xs">
                                        No menu item selected.
                                    </div>
                                )}
                            </CardContent>
                        </Card>
                    </div>
                </div>

                {/* Generated 3D Models Connected Items Table */}
                <Card className="rounded-3xl border-gray-100 shadow-sm overflow-hidden">
                    <CardContent className="p-6 space-y-4">
                        <div className="flex items-center justify-between border-b border-gray-100 pb-4">
                            <div>
                                <h3 className="font-bold text-base text-gray-900 flex items-center gap-2">
                                    <Layers className="w-5 h-5 text-amber-500" />
                                    Generated 3D Food Models & Connected Items
                                </h3>
                                <p className="text-xs text-gray-500 mt-0.5">
                                    List of restaurant dishes mapped with interactive 3D GLB models & AR camera table projections.
                                </p>
                            </div>
                            <span className="bg-amber-100 text-amber-800 text-xs font-bold px-3 py-1 rounded-full">
                                {menuItems.filter(i => i.model_3d).length} Connected 3D Assets
                            </span>
                        </div>

                        <div className="overflow-x-auto">
                            <table className="w-full text-left text-xs">
                                <thead>
                                    <tr className="border-b border-gray-100 text-gray-400 font-bold uppercase tracking-wider text-[10px]">
                                        <th className="py-3 px-3">Menu Item</th>
                                        <th className="py-3 px-3">Category</th>
                                        <th className="py-3 px-3">Price</th>
                                        <th className="py-3 px-3">3D Asset Status</th>
                                        <th className="py-3 px-3 text-right">Actions</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-gray-50 font-medium text-gray-700">
                                    {menuItems.map(item => (
                                        <tr key={item.id} className="hover:bg-gray-50/80 transition-colors">
                                            <td className="py-3 px-3 flex items-center gap-3">
                                                {item.image ? (
                                                    <img src={`/storage/${item.image}`} alt={item.name} className="w-9 h-9 rounded-xl object-cover border border-gray-200 shadow-xs" />
                                                ) : (
                                                    <div className="w-9 h-9 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center font-bold text-xs border border-amber-200">
                                                        <UtensilsCrossed className="w-4 h-4" />
                                                    </div>
                                                )}
                                                <div>
                                                    <div className="font-bold text-gray-900 text-xs">{item.name}</div>
                                                    <div className="text-[10px] text-gray-400 truncate max-w-xs">{item.description || 'No description'}</div>
                                                </div>
                                            </td>

                                            <td className="py-3 px-3">
                                                <span className="bg-gray-100 text-gray-700 text-[10px] font-bold px-2.5 py-1 rounded-lg">
                                                    {item.category ? item.category.name : 'General'}
                                                </span>
                                            </td>

                                            <td className="py-3 px-3 font-extrabold text-gray-900">
                                                {currencySymbol}{Number(item.price).toFixed(2)}
                                            </td>

                                            <td className="py-3 px-3">
                                                {item.model_3d ? (
                                                    <span className="bg-emerald-100 text-emerald-800 text-[10px] font-bold px-2 py-0.5 rounded-full flex items-center gap-1 w-max">
                                                        <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                                                        3D Mesh Active
                                                    </span>
                                                ) : (
                                                    <span className="bg-gray-100 text-gray-400 text-[10px] font-bold px-2 py-0.5 rounded-full w-max inline-block">
                                                        No 3D Model
                                                    </span>
                                                )}
                                            </td>

                                            <td className="py-3 px-3 text-right">
                                                <div className="flex items-center justify-end gap-2">
                                                    <button
                                                        type="button"
                                                        onClick={() => handlePreviewClick(item)}
                                                        className="px-2.5 py-1.5 bg-amber-50 hover:bg-amber-100 text-amber-700 font-bold rounded-xl text-[11px] flex items-center gap-1 transition-colors shadow-xs"
                                                    >
                                                        <Eye className="w-3.5 h-3.5" /> Preview 3D
                                                    </button>

                                                    {item.model_3d && (
                                                        <button
                                                            type="button"
                                                            onClick={() => {
                                                                if (confirm(`Unlink 3D model from '${item.name}'?`)) {
                                                                    router.delete(`/menu/3d-studio/${item.id}`, { preserveScroll: true });
                                                                }
                                                            }}
                                                            title="Unlink 3D Model"
                                                            className="p-1.5 text-red-500 hover:text-red-700 hover:bg-red-50 rounded-xl transition-colors"
                                                        >
                                                            <Trash2 className="w-4 h-4" />
                                                        </button>
                                                    )}
                                                </div>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Interactive 3D Model Preview Modal */}
            {previewModalItem && (
                <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-md flex items-center justify-center p-4">
                    <div className="bg-slate-900 text-white w-full max-w-lg rounded-3xl overflow-hidden shadow-2xl border border-slate-800 animate-scale-up">
                        {/* Header */}
                        <div className="p-4 border-b border-slate-800 flex items-center justify-between bg-slate-900">
                            <div className="flex items-center gap-2">
                                <div className="p-2 bg-amber-500/20 text-amber-400 rounded-xl">
                                    <Box className="w-5 h-5" />
                                </div>
                                <div>
                                    <h3 className="font-bold text-sm text-white">{previewModalItem.name}</h3>
                                    <div className="text-[10px] text-amber-400 font-semibold flex items-center gap-1">
                                        <RotateCw className="w-3 h-3 animate-spin" /> 360° Interactive 3D Stage Preview
                                    </div>
                                </div>
                            </div>
                            <button
                                type="button"
                                onClick={() => setPreviewModalItem(null)}
                                className="p-2 text-slate-400 hover:text-white rounded-full hover:bg-slate-800 transition-colors"
                            >
                                <X className="w-5 h-5" />
                            </button>
                        </div>

                        {/* 3D Model WebGL Stage Canvas */}
                        <div className="relative h-80 bg-gradient-to-b from-slate-950 to-slate-900 flex items-center justify-center p-2 overflow-hidden select-none border-b border-slate-800">
                            <model-viewer
                                src={previewModalItem.model_3d ? `/storage/${previewModalItem.model_3d}` : '/models/default_food_3d.glb'}
                                alt={previewModalItem.name}
                                auto-rotate
                                camera-controls
                                shadow-intensity="2"
                                environment-image="neutral"
                                exposure="1.2"
                                style={{ width: '100%', height: '100%', minHeight: '300px', display: 'block' }}
                            ></model-viewer>
                        </div>

                        {/* Footer */}
                        <div className="p-5 border-t border-slate-800 flex items-center justify-between bg-slate-900">
                            <div>
                                <div className="text-[10px] text-slate-400 uppercase font-bold">Item Price</div>
                                <div className="text-lg font-black text-amber-400">
                                    {currencySymbol}{Number(previewModalItem.price).toFixed(2)}
                                </div>
                            </div>
                            <Button
                                type="button"
                                onClick={() => setPreviewModalItem(null)}
                                className="bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs px-5 py-2.5 rounded-xl shadow-md"
                            >
                                Close Preview
                            </Button>
                        </div>
                    </div>
                </div>
            )}

            {/* Guided Live Camera Viewfinder Modal */}
            {guidedCameraSlot !== null && (
                <div className="fixed inset-0 bg-slate-950/90 backdrop-blur-md z-50 flex items-center justify-center p-4">
                    <div className="bg-slate-900 border border-slate-800 text-white rounded-3xl w-full max-w-lg overflow-hidden shadow-2xl relative">
                        {/* Modal Header */}
                        <div className="p-4 border-b border-slate-800 flex items-center justify-between bg-slate-950">
                            <div>
                                <span className="text-[10px] text-amber-400 font-bold uppercase tracking-wider">
                                    Step {guidedCameraSlot + 1} of 4: Guided 3D Scanner
                                </span>
                                <h3 className="font-extrabold text-sm text-white flex items-center gap-1.5 mt-0.5">
                                    <Camera className="w-4 h-4 text-amber-400" />
                                    {angleLabels[guidedCameraSlot].label} ({angleLabels[guidedCameraSlot].icon})
                                </h3>
                            </div>
                            <button
                                type="button"
                                onClick={closeGuidedCamera}
                                className="p-2 text-slate-400 hover:text-white rounded-full hover:bg-slate-800 transition-colors"
                            >
                                <X className="w-5 h-5" />
                            </button>
                        </div>

                        {/* Guided Camera Stream Viewfinder */}
                        <div className="relative h-96 bg-black flex items-center justify-center overflow-hidden">
                            <video
                                ref={guidedVideoRef}
                                autoPlay
                                playsInline
                                muted
                                className="w-full h-full object-cover"
                            />
                            <canvas ref={guidedCanvasRef} className="hidden" />

                            {/* 3D Alignment Overlay Guide */}
                            <div className="absolute inset-0 pointer-events-none flex flex-col items-center justify-center">
                                <div className="w-64 h-64 border-2 border-dashed border-amber-400/80 rounded-full flex items-center justify-center animate-pulse">
                                    <div className="w-56 h-56 border border-white/40 rounded-full flex items-center justify-center">
                                        <span className="text-amber-400/80 font-bold text-xs bg-black/60 px-3 py-1 rounded-full backdrop-blur-xs">
                                            Center Dish Here
                                        </span>
                                    </div>
                                </div>
                                <p className="text-xs text-amber-200 mt-4 bg-black/70 px-4 py-1.5 rounded-full font-semibold border border-amber-500/30">
                                    {angleLabels[guidedCameraSlot].desc}
                                </p>
                            </div>
                        </div>

                        {/* Capture Shutter Action */}
                        <div className="p-5 bg-slate-950 flex items-center justify-between border-t border-slate-800">
                            <div className="flex items-center gap-1 text-xs text-slate-400 font-medium">
                                <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping"></span>
                                Camera Live
                            </div>
                            <button
                                type="button"
                                onClick={captureGuidedPhoto}
                                className="w-16 h-16 rounded-full bg-gradient-to-tr from-amber-500 to-orange-500 hover:scale-105 active:scale-95 text-slate-950 flex items-center justify-center shadow-xl shadow-amber-500/40 ring-4 ring-white/20 transition-all"
                                title="Capture Angle Photo"
                            >
                                <Camera className="w-7 h-7 stroke-[2.5]" />
                            </button>
                            <button
                                type="button"
                                onClick={closeGuidedCamera}
                                className="text-xs text-slate-400 hover:text-white font-semibold"
                            >
                                Skip Camera
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </AdminLayout>
    );
}
