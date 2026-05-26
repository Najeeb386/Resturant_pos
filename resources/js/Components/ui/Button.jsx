import React from 'react';
import clsx from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs) {
  return twMerge(clsx(inputs));
}

export function Button({ className, variant = 'primary', size = 'md', children, ...props }) {
    const baseStyles = "inline-flex items-center justify-center font-medium rounded-xl transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed";
    
    const variants = {
        primary: "bg-primary hover:bg-secondary text-white shadow-md shadow-primary/30",
        secondary: "bg-orange-100 text-primary hover:bg-orange-200",
        outline: "border-2 border-gray-200 text-gray-700 hover:border-primary hover:text-primary",
        ghost: "text-gray-600 hover:bg-gray-100",
        danger: "bg-red-500 hover:bg-red-600 text-white shadow-md shadow-red-500/30",
    };

    const sizes = {
        sm: "px-3 py-1.5 text-sm",
        md: "px-4 py-2.5",
        lg: "px-6 py-3 text-lg",
        icon: "p-2",
    };

    return (
        <button 
            className={cn(baseStyles, variants[variant], sizes[size], className)} 
            {...props}
        >
            {children}
        </button>
    );
}
