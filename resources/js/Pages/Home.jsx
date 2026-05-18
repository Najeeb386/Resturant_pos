import React, { useEffect } from 'react';
import { router } from '@inertiajs/react';

export default function Home() {
    useEffect(() => {
        router.visit('/login');
    }, []);

    return (
        <div className="container mx-auto p-4">
            <h1 className="text-2xl font-bold">Redirecting...</h1>
        </div>
    );
}