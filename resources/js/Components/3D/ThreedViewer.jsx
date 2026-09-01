import React, { useRef, useEffect, useState } from 'react';
import { RotateCw, ZoomIn, ZoomOut, RefreshCw, Sun } from 'lucide-react';

export default function ThreedViewer({ imageUrl, name, price, themeColor = '#f97316' }) {
    const canvasRef = useRef(null);
    const [isRotating, setIsRotating] = useState(true);
    const [rotation, setRotation] = useState({ x: 15, y: 45 });
    const [zoom, setZoom] = useState(1);
    const isDraggingRef = useRef(false);
    const lastMousePosRef = useRef({ x: 0, y: 0 });
    const animationFrameRef = useRef(null);

    // Auto-rotation loop
    useEffect(() => {
        if (!isRotating) return;

        let frameId;
        const animate = () => {
            setRotation(prev => ({ ...prev, y: (prev.y + 0.8) % 360 }));
            frameId = requestAnimationFrame(animate);
        };

        frameId = requestAnimationFrame(animate);
        return () => cancelAnimationFrame(frameId);
    }, [isRotating]);

    // Canvas 3D WebGL / 3D Canvas Rendering
    useEffect(() => {
        const canvas = canvasRef.current;
        if (!canvas) return;

        const ctx = canvas.getContext('2d');
        const width = canvas.width = canvas.clientWidth * (window.devicePixelRatio || 1);
        const height = canvas.height = canvas.clientHeight * (window.devicePixelRatio || 1);

        let img = new Image();
        let isImgLoaded = false;
        if (imageUrl) {
            img.src = imageUrl;
            img.onload = () => { isImgLoaded = true; };
        }

        const render3DStage = () => {
            ctx.clearRect(0, 0, width, height);

            const centerX = width / 2;
            const centerY = height / 2 + 10;
            const radius = Math.min(width, height) * 0.32 * zoom;

            // 1. Render 3D Radial Pedestal Glow
            const glowGradient = ctx.createRadialGradient(centerX, centerY, 5, centerX, centerY, radius * 1.6);
            glowGradient.addColorStop(0, 'rgba(249, 115, 22, 0.35)');
            glowGradient.addColorStop(0.5, 'rgba(249, 115, 22, 0.1)');
            glowGradient.addColorStop(1, 'rgba(0, 0, 0, 0)');
            ctx.fillStyle = glowGradient;
            ctx.fillRect(0, 0, width, height);

            // 2. Render 3D Pedestal Base (Ellipse Disk)
            ctx.save();
            ctx.translate(centerX, centerY + radius * 0.7);
            ctx.scale(1, 0.35);
            ctx.beginPath();
            ctx.arc(0, 0, radius * 1.1, 0, Math.PI * 2);
            ctx.fillStyle = 'rgba(15, 23, 42, 0.9)';
            ctx.shadowColor = 'rgba(0, 0, 0, 0.8)';
            ctx.shadowBlur = 25;
            ctx.fill();
            ctx.lineWidth = 4;
            ctx.strokeStyle = themeColor;
            ctx.stroke();
            ctx.restore();

            // 3. Render 3D Dish Object with 3D Perspective Rotation
            ctx.save();
            ctx.translate(centerX, centerY);

            const rotXRad = (rotation.x * Math.PI) / 180;
            const rotYRad = (rotation.y * Math.PI) / 180;

            const scaleX = Math.cos(rotYRad);
            const scaleY = Math.cos(rotXRad);

            ctx.save();
            ctx.scale(scaleX, 1);
            ctx.rotate(rotYRad * 0.15);

            // 3D Dish Outer Rim
            ctx.beginPath();
            ctx.arc(0, 0, radius, 0, Math.PI * 2);
            ctx.fillStyle = '#0f172a';
            ctx.shadowColor = 'rgba(249, 115, 22, 0.4)';
            ctx.shadowBlur = 20;
            ctx.fill();
            ctx.lineWidth = 6 * zoom;
            ctx.strokeStyle = themeColor;
            ctx.stroke();

            // Dish Face / Texture Image
            if (isImgLoaded) {
                ctx.save();
                ctx.beginPath();
                ctx.arc(0, 0, radius * 0.92, 0, Math.PI * 2);
                ctx.clip();
                ctx.drawImage(img, -radius * 0.92, -radius * 0.92, radius * 1.84, radius * 1.84);
                ctx.restore();
            } else {
                // Render 3D Stylized Gourmet Dish Texture
                ctx.save();
                ctx.beginPath();
                ctx.arc(0, 0, radius * 0.92, 0, Math.PI * 2);
                const dishGrad = ctx.createRadialGradient(0, 0, 5, 0, 0, radius * 0.92);
                dishGrad.addColorStop(0, '#334155');
                dishGrad.addColorStop(0.7, '#1e293b');
                dishGrad.addColorStop(1, '#0f172a');
                ctx.fillStyle = dishGrad;
                ctx.fill();

                // Inner Food Plate Pattern & Ring
                ctx.beginPath();
                ctx.arc(0, 0, radius * 0.7, 0, Math.PI * 2);
                ctx.lineWidth = 2;
                ctx.strokeStyle = 'rgba(249, 115, 22, 0.4)';
                ctx.stroke();

                // Food Dish Name & 3D Badge Embellishment
                ctx.fillStyle = themeColor;
                ctx.font = `bold ${Math.max(14, radius * 0.22)}px sans-serif`;
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                ctx.fillText(name ? name.substring(0, 16) : '3D Dish', 0, -radius * 0.15);

                ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
                ctx.font = `${Math.max(10, radius * 0.15)}px sans-serif`;
                ctx.fillText('3D Interactive Model', 0, radius * 0.2);
                ctx.restore();
            }

            // 3D Lighting Specular Highlight Overlay
            const lightGrad = ctx.createLinearGradient(-radius, -radius, radius, radius);
            lightGrad.addColorStop(0, 'rgba(255, 255, 255, 0.35)');
            lightGrad.addColorStop(0.4, 'rgba(255, 255, 255, 0.05)');
            lightGrad.addColorStop(1, 'rgba(0, 0, 0, 0.4)');
            ctx.fillStyle = lightGrad;
            ctx.beginPath();
            ctx.arc(0, 0, radius * 0.92, 0, Math.PI * 2);
            ctx.fill();

            ctx.restore();
            ctx.restore();
        };

        render3DStage();
    }, [rotation, zoom, imageUrl, themeColor]);

    // Touch / Mouse Drag Controls
    const handleMouseDown = (e) => {
        isDraggingRef.current = true;
        setIsRotating(false);
        lastMousePosRef.current = { x: e.clientX || e.touches?.[0]?.clientX, y: e.clientY || e.touches?.[0]?.clientY };
    };

    const handleMouseMove = (e) => {
        if (!isDraggingRef.current) return;
        const clientX = e.clientX || e.touches?.[0]?.clientX;
        const clientY = e.clientY || e.touches?.[0]?.clientY;

        const deltaX = clientX - lastMousePosRef.current.x;
        const deltaY = clientY - lastMousePosRef.current.y;

        setRotation(prev => ({
            x: Math.max(-60, Math.min(60, prev.x + deltaY * 0.5)),
            y: (prev.y + deltaX * 0.8) % 360
        }));

        lastMousePosRef.current = { x: clientX, y: clientY };
    };

    const handleMouseUp = () => {
        isDraggingRef.current = false;
    };

    return (
        <div className="relative w-full h-full flex flex-col items-center justify-center select-none overflow-hidden bg-slate-950 rounded-2xl border border-slate-800">
            <canvas
                ref={canvasRef}
                onMouseDown={handleMouseDown}
                onMouseMove={handleMouseMove}
                onMouseUp={handleMouseUp}
                onMouseLeave={handleMouseUp}
                onTouchStart={handleMouseDown}
                onTouchMove={handleMouseMove}
                onTouchEnd={handleMouseUp}
                className="w-full h-full cursor-grab active:cursor-grabbing touch-none"
            />

            {/* 3D Control Floating Bar */}
            <div className="absolute bottom-3 left-3 right-3 flex items-center justify-between bg-slate-900/90 backdrop-blur-md px-3 py-1.5 rounded-xl border border-slate-800 text-xs">
                <div className="flex items-center gap-1.5">
                    <button
                        type="button"
                        onClick={() => setIsRotating(!isRotating)}
                        className={`p-1.5 rounded-lg text-xs font-bold flex items-center gap-1 transition-colors ${
                            isRotating ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30' : 'bg-slate-800 text-slate-400'
                        }`}
                    >
                        <RotateCw className={`w-3.5 h-3.5 ${isRotating ? 'animate-spin' : ''}`} />
                        {isRotating ? 'Auto-Rotate ON' : 'Paused'}
                    </button>
                </div>

                <div className="flex items-center gap-1">
                    <button
                        type="button"
                        onClick={() => setZoom(z => Math.max(0.6, z - 0.15))}
                        className="p-1.5 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800"
                        title="Zoom Out"
                    >
                        <ZoomOut className="w-3.5 h-3.5" />
                    </button>

                    <button
                        type="button"
                        onClick={() => setZoom(z => Math.min(1.6, z + 0.15))}
                        className="p-1.5 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800"
                        title="Zoom In"
                    >
                        <ZoomIn className="w-3.5 h-3.5" />
                    </button>

                    <button
                        type="button"
                        onClick={() => { setRotation({ x: 15, y: 45 }); setZoom(1); }}
                        className="p-1.5 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800"
                        title="Reset 3D View"
                    >
                        <RefreshCw className="w-3.5 h-3.5" />
                    </button>
                </div>
            </div>
        </div>
    );
}
