import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/superadmin_provider.dart';

class SuperAdminRestaurantsView extends StatelessWidget {
  const SuperAdminRestaurantsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = superAdminProvider;

    final nameController = TextEditingController();
    final adminController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();

    void showAddTenantDialog(List<String> plansList) {
      String? selectedPlan = plansList.isNotEmpty ? plansList.first : null;
      String selectedStatus = 'Active';

      Get.dialog(
        StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            title: Text(
              'Register New Restaurant Branch',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Restaurant Name',
                      hintText: 'e.g. Wok & Roll',
                      labelStyle: TextStyle(color: Colors.black54),
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: adminController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Admin Full Name',
                      hintText: 'e.g. Alex Mercer',
                      labelStyle: TextStyle(color: Colors.black54),
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Admin Email',
                      hintText: 'e.g. alex@wokroll.com',
                      labelStyle: TextStyle(color: Colors.black54),
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Admin Password',
                      hintText: 'Min 6 characters',
                      labelStyle: TextStyle(color: Colors.black54),
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Contact Number / Phone',
                      hintText: 'e.g. +92 300 1234567',
                      labelStyle: TextStyle(color: Colors.black54),
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (plansList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentRose.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.accentRose.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Please create a Subscription Plan in the Plans tab first.',
                        style: GoogleFonts.inter(color: AppTheme.accentRose, fontSize: 13),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: selectedPlan,
                      dropdownColor: Colors.white,
                      decoration: const InputDecoration(
                        labelText: 'Subscription Plan',
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      items: plansList.map((plan) {
                        return DropdownMenuItem(
                          value: plan,
                          child: Text(plan, style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedPlan = val;
                        });
                      },
                    ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(
                      labelText: 'Initial Status',
                      labelStyle: TextStyle(color: Colors.black54),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active', style: TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: 'Trial', child: Text('Trial', style: TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: 'Expired', child: Text('Expired', style: TextStyle(color: Colors.black))),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        selectedStatus = val!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.black54)),
              ),
              ElevatedButton(
                onPressed: (plansList.isEmpty)
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        final admin = adminController.text.trim();
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        if (name.isNotEmpty && admin.isNotEmpty && email.isNotEmpty && password.isNotEmpty && selectedPlan != null) {
                          if (password.length < 6) {
                            Get.snackbar(
                              'Validation Error',
                              'Password must be at least 6 characters.',
                              backgroundColor: AppTheme.accentRose,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 4),
                            );
                            return;
                          }

                          final error = await controller.addTenant(
                            name: name,
                            admin: admin,
                            email: email,
                            password: password,
                            plan: selectedPlan!,
                            status: selectedStatus,
                            phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                          );

                          if (error != null) {
                            Get.snackbar(
                              'Registration Failed',
                              error,
                              backgroundColor: AppTheme.accentRose,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 6),
                            );
                          } else {
                            nameController.clear();
                            adminController.clear();
                            emailController.clear();
                            passwordController.clear();
                            phoneController.clear();
                            Get.back();
                            Get.snackbar(
                              'Tenant Added',
                              'Successfully registered restaurant: $name',
                              backgroundColor: AppTheme.accentEmerald,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryDark),
                child: const Text('Add Tenant'),
              ),
            ],
          ),
        ),
      );
    }

    void showManageSubscriptionDialog(TenantModel tenant) {
      final phoneController = TextEditingController(text: tenant.phone ?? '');
      String localPlan = tenant.plan;
      Get.dialog(
        StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceDark,
              title: Text(
                'Manage Subscription: ${tenant.name}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Status: ${tenant.status}', style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Contact Number / Phone',
                      labelStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (controller.plans.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentRose.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.accentRose.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'No subscription plans available.',
                        style: TextStyle(color: AppTheme.accentRose, fontSize: 13),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: controller.plans.any((p) => p.name == localPlan)
                          ? localPlan
                          : controller.plans.first.name,
                      dropdownColor: AppTheme.surfaceDark,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'Change Subscription Plan',
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      items: controller.plans.map((p) {
                        return DropdownMenuItem(
                          value: p.name,
                          child: Text(p.name, style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          localPlan = val!;
                        });
                      },
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await controller.updateSubscription(
                            tenant.id, 
                            status: 'Trial', 
                            plan: localPlan,
                            phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                          );
                          Get.back();
                          Get.snackbar(
                            'Trial Approved',
                            '${tenant.name} has been set to Trial status.',
                            backgroundColor: AppTheme.accentAmber,
                            colorText: Colors.black,
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentAmber),
                        child: const Text('Approve Trial', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await controller.updateSubscription(
                            tenant.id, 
                            status: 'Active', 
                            plan: localPlan,
                            phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                          );
                          Get.back();
                          Get.snackbar(
                            'Subscription Activated',
                            '${tenant.name} is now Active.',
                            backgroundColor: AppTheme.accentEmerald,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentEmerald),
                        child: const Text('Activate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await controller.updateSubscription(
                          tenant.id, 
                          status: tenant.status, 
                          plan: localPlan,
                          phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                        );
                        Get.back();
                        Get.snackbar(
                          'Tenant Updated',
                          'Subscription details have been saved.',
                          backgroundColor: AppTheme.accentTeal,
                          colorText: Colors.black,
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentTeal),
                      child: const Text('Save Plan & Contact', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await controller.updateSubscription(tenant.id, status: 'Suspended');
                            Get.back();
                            Get.snackbar(
                              'Subscription Cancelled',
                              '${tenant.name} has been suspended/cancelled.',
                              backgroundColor: AppTheme.accentRose,
                              colorText: Colors.white,
                            );
                          },
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                          child: const Text('Suspend', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (tenant.status == 'Suspended' || tenant.status == 'Expired') ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  backgroundColor: AppTheme.surfaceDark,
                                  title: Text(
                                    'Delete Tenant Data?',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete ${tenant.name} and all their restaurant data completely?\n\nThis action cannot be undone.',
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        // Show loading overlay
                                        Get.dialog(
                                          const Center(
                                            child: Card(
                                              child: Padding(
                                                padding: EdgeInsets.all(24.0),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    CircularProgressIndicator(),
                                                    SizedBox(height: 16),
                                                    Text(
                                                      'Deleting Tenant Data...',
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          barrierDismissible: false,
                                        );

                                        // Perform deletion
                                        await controller.deleteTenant(tenant.id);

                                        Get.back(); // close loading overlay
                                        Get.back(); // close confirm dialog
                                        Get.back(); // close settings dialog
                                        
                                        Get.snackbar(
                                          'Tenant Deleted',
                                          '${tenant.name} has been deleted from the database.',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Delete Tenant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTenantDialog(controller.plans.map((p) => p.name).toList()),
        backgroundColor: AppTheme.primaryDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tenant Configurations',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Click on any restaurant row to manage their plans, trials, and subscription lifecycle.',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.tenants.isEmpty) {
                  return Center(
                    child: Text(
                      'No tenants registered yet.',
                      style: GoogleFonts.inter(color: Colors.black38),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.tenants.length,
                  itemBuilder: (context, index) {
                    final tenant = controller.tenants[index];
                    Color statusColor = AppTheme.accentEmerald;
                    if (tenant.status == 'Trial') statusColor = AppTheme.accentAmber;
                    if (tenant.status == 'Expired' || tenant.status == 'Suspended') {
                      statusColor = AppTheme.accentRose;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        onTap: () => showManageSubscriptionDialog(tenant),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.backgroundDark,
                          child: Text(
                            tenant.name[0].toUpperCase(),
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                tenant.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: statusColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                tenant.status.toUpperCase(),
                                style: GoogleFonts.outfit(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              'Admin: ${tenant.admin} (${tenant.email})',
                              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Plan Tier: ${tenant.plan}',
                              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        trailing: Builder(
                          builder: (context) {
                            final planPrice = controller.plans.firstWhere(
                              (p) => p.name.trim().toLowerCase() == tenant.plan.trim().toLowerCase(),
                              orElse: () => PlanModel(name: '', price: 0.0, billing: '', desc: ''),
                            ).price;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  Formatters.formatCurrency(planPrice),
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accentEmerald),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Plan Price',
                                  style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B)),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
