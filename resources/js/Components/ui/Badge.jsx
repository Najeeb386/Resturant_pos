import React from 'react';
import { cn } from './Button';

export function Badge({ className, variant = 'default', children, ...props }) {
    const variants = {
        default: "bg-gray-100 text-gray-700",
        primary: "bg-orange-100 text-primary",
        success: "bg-green-100 text-green-700",
        warning: "bg-yellow-100 text-yellow-700",
        danger: "bg-red-100 text-red-700",
    };

    return (
        <span 
            className={cn("px-2.5 py-0.5 rounded-full text-xs font-semibold uppercase tracking-wide inline-flex items-center", variants[variant], className)}
            {...props}
        >
            {children}
        </span>
    );
}
