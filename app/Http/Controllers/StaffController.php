<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Role;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Inertia\Inertia;

class StaffController extends Controller
{
    public function index()
    {
        if (auth()->user()->role_id !== 2) {
            abort(403, 'Only the Restaurant Owner can manage staff.');
        }

        $restaurantId = auth()->user()->restaurant_id;
        $staff = User::with('role')
            ->where('restaurant_id', $restaurantId)
            ->where('role_id', '!=', 1)
            ->get();
        
        $roles = Role::where('id', '!=', 1)->get();

        return Inertia::render('Staff/Index', [
            'staff' => $staff,
            'roles' => $roles
        ]);
    }

    public function store(Request $request)
    {
        if (auth()->user()->role_id !== 2) {
            abort(403);
        }

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
            'role_id' => 'required|exists:roles,id',
        ]);

        if ($request->role_id == 1) {
            return back()->withErrors(['role_id' => 'Cannot create Super Admin user.']);
        }

        User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role_id' => $request->role_id,
            'restaurant_id' => auth()->user()->restaurant_id,
        ]);

        return redirect()->back()->with('message', 'Staff member created successfully.');
    }

    public function update(Request $request, User $staff)
    {
        if ($staff->restaurant_id !== auth()->user()->restaurant_id || $staff->role_id == 1) {
            abort(403);
        }

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $staff->id,
            'role_id' => 'required|exists:roles,id',
            'password' => 'nullable|string|min:8',
        ]);

        if ($request->role_id == 1) {
            return back()->withErrors(['role_id' => 'Cannot assign Super Admin role.']);
        }

        $data = $request->only('name', 'email', 'role_id');
        if ($request->filled('password')) {
            $data['password'] = Hash::make($request->password);
        }

        $staff->update($data);

        return redirect()->back()->with('message', 'Staff member updated successfully.');
    }

    public function destroy(User $staff)
    {
        if ($staff->restaurant_id !== auth()->user()->restaurant_id || $staff->id === auth()->id() || $staff->role_id == 1) {
            abort(403);
        }

        $staff->delete();

        return redirect()->back()->with('message', 'Staff member deleted successfully.');
    }
}
