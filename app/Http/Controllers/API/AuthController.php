<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (!auth()->attempt($request->only('email', 'password'))) {
            return back()->withErrors(['email' => 'Invalid credentials']);
        }

        if (auth()->user()->role_id === 1) {
            auth()->logout();
            return back()->withErrors(['email' => 'Super Admins must use the Admin Portal to log in.']);
        }

        $request->session()->regenerate();

        return redirect('/dashboard');
    }

    public function adminLogin(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (!auth()->attempt($request->only('email', 'password'))) {
            return back()->withErrors(['email' => 'Invalid credentials']);
        }

        if (auth()->user()->role_id !== 1) {
            auth()->logout();
            return back()->withErrors(['email' => 'Access denied. You are not a Super Admin.']);
        }

        $request->session()->regenerate();

        return redirect('/admin/dashboard');
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:6',
            'role_id' => 'required|exists:roles,id',
            'restaurant_id' => 'nullable|exists:restaurants,id',
        ]);

        $user = \App\Models\User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => \Hash::make($request->password),
            'role_id' => $request->role_id,
            'restaurant_id' => $request->restaurant_id,
        ]);

        $token = $user->createToken('API Token')->plainTextToken;

        return response()->json([
            'user' => $user->load('role', 'restaurant'),
            'token' => $token,
        ], 201);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out']);
    }

    public function user(Request $request)
    {
        return response()->json($request->user()->load('role', 'restaurant'));
    }
}
