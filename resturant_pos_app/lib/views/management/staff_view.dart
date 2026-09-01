import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:resturant_pos_app/providers/database_provider.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';

class StaffView extends StatefulWidget {
  const StaffView({super.key});

  @override
  State<StaffView> createState() => _StaffViewState();
}

class _StaffViewState extends State<StaffView> {
  void _showAddStaffDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    int selectedRole = 3; // Default to Cashier
    bool isSaving = false;

    Get.defaultDialog(
      title: 'Add Staff Member',
      titleStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Staff Role',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 3, child: Text('Cashier / POS Terminal')),
                  DropdownMenuItem(value: 4, child: Text('Kitchen Staff')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      selectedRole = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              isSaving
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final name = nameCtrl.text.trim();
                            final email = emailCtrl.text.trim();
                            final pass = passCtrl.text.trim();
                            
                            if (name.isEmpty || email.isEmpty || pass.isEmpty) {
                              Get.snackbar('Input Error', 'Please fill in all fields',
                                  backgroundColor: AppTheme.accentRose, colorText: Colors.white);
                              return;
                            }

                            setDialogState(() {
                              isSaving = true;
                            });

                            final success = await authProvider.createStaffUser(
                              name: name,
                              email: email,
                              password: pass,
                              roleId: selectedRole,
                            );

                            if (success) {
                              Get.back();
                              setState(() {}); // Refresh FutureBuilder
                              Get.snackbar(
                                'Success',
                                'Staff member created successfully.',
                                backgroundColor: AppTheme.accentEmerald,
                                colorText: Colors.white,
                              );
                            } else {
                              setDialogState(() {
                                isSaving = false;
                              });
                              Get.snackbar(
                                'Registration Failed',
                                authProvider.state.value.error ?? 'Unknown error occurred',
                                backgroundColor: AppTheme.accentRose,
                                colorText: Colors.white,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: const Text('Register', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteStaff(LocalUser staff) {
    Get.defaultDialog(
      title: 'Remove Staff Account',
      titleStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.accentRose),
      middleText: 'Are you sure you want to delete ${staff.name}? This will revoke their terminal login credentials.',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.accentRose,
      onConfirm: () async {
        Get.back(); // close dialog
        final success = await authProvider.deleteStaffUser(staff.id);
        if (success) {
          setState(() {}); // Refresh list
          Get.snackbar(
            'Account Removed',
            'Staff member deleted successfully.',
            backgroundColor: AppTheme.accentEmerald,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Delete Failed',
            authProvider.state.value.error ?? 'Unknown error occurred',
            backgroundColor: AppTheme.accentRose,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add Staff button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Staff & Terminals',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage Cashiers and Kitchen display monitors linked to this branch.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddStaffDialog,
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: Text(
                  'Add Staff Member',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main list container
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<LocalUser>>(
                  future: databaseProvider.select(databaseProvider.localUsers).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final adminId = authProvider.state.value.user?.id;
                    final staffList = snapshot.data
                            ?.where((u) => u.roleId != 1 && u.id != adminId)
                            .toList() ??
                        [];

                    if (staffList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.badge_outlined, size: 48, color: Colors.grey.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'No staff accounts configured.',
                              style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Click "+ Add Staff Member" to set up cashier or kitchen screens.',
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: staffList.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                      ),
                      itemBuilder: (context, index) {
                        final staff = staffList[index];
                        final isCashier = staff.roleId == 3;
                        final roleLabel = isCashier ? 'Cashier / POS' : 'Kitchen Monitor';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: isCashier
                                ? AppTheme.accentEmerald.withOpacity(0.15)
                                : Colors.blue.withOpacity(0.15),
                            child: Icon(
                              isCashier ? Icons.point_of_sale_outlined : Icons.kitchen_outlined,
                              color: isCashier ? AppTheme.accentEmerald : Colors.blue,
                            ),
                          ),
                          title: Text(
                            staff.name,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            staff.email,
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                backgroundColor: isCashier
                                    ? AppTheme.accentEmerald.withOpacity(0.1)
                                    : Colors.blue.withOpacity(0.1),
                                side: BorderSide(
                                  color: isCashier
                                      ? AppTheme.accentEmerald.withOpacity(0.3)
                                      : Colors.blue.withOpacity(0.3),
                                ),
                                label: Text(
                                  roleLabel,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isCashier ? AppTheme.accentEmerald : Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppTheme.accentRose),
                                tooltip: 'Revoke Access',
                                onPressed: () => _confirmDeleteStaff(staff),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
