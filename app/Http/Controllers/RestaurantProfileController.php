<?php

namespace App\Http\Controllers;

use App\Models\Restaurant;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\Storage;

class RestaurantProfileController extends Controller
{
    public function edit()
    {
        if (auth()->user()->role_id !== 2) {
            abort(403);
        }

        $restaurant = auth()->user()->restaurant;
        return Inertia::render('Settings/Profile', [
            'restaurant' => $restaurant
        ]);
    }

    public function update(Request $request)
    {
        if (auth()->user()->role_id !== 2) {
            abort(403);
        }

        $restaurant = auth()->user()->restaurant;

        $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'address' => 'required|string',
            'email' => 'nullable|email|max:255',
            'gst_number' => 'nullable|string|max:50',
            'currency' => 'nullable|string|max:3',
            'currency_symbol' => 'nullable|string|max:10',
            'tax_percentage' => 'nullable|numeric|min:0|max:100',
            'logo' => 'nullable|image|max:2048', // 2MB max
            'receipt_header' => 'nullable|string',
            'receipt_footer' => 'nullable|string',
            'kitchen_bypass' => 'boolean',
        ]);

        $data = $request->only('name', 'phone', 'address', 'email', 'gst_number', 'currency', 'currency_symbol', 'tax_percentage', 'receipt_header', 'receipt_footer', 'kitchen_bypass');

        if ($request->hasFile('logo')) {
            if ($restaurant->logo) {
                Storage::disk('public')->delete($restaurant->logo);
            }
            $path = $request->file('logo')->store("restaurants/{$restaurant->id}/logo", 'public');
            $data['logo'] = $path;
        }

        $restaurant->update($data);

        return redirect()->back()->with('message', 'Profile updated successfully.');
    }
}
