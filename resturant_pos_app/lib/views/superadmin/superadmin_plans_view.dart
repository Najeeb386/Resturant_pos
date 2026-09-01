import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/superadmin_provider.dart';

class SuperAdminPlansView extends StatelessWidget {
  const SuperAdminPlansView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = superAdminProvider;

    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    String selectedBilling = 'Monthly';

    void addPlan(bool hasKitchen, bool hasStaff, bool hasInventory) async {
      final name = nameController.text.trim();
      final priceStr = priceController.text.trim();
      final desc = descController.text.trim();

      if (name.isNotEmpty && priceStr.isNotEmpty && desc.isNotEmpty) {
        await controller.addPlan(
          name: name,
          price: priceStr,
          billing: selectedBilling,
          desc: desc,
          hasKitchen: hasKitchen,
          hasStaff: hasStaff,
          hasInventory: hasInventory,
        );
        nameController.clear();
        priceController.clear();
        descController.clear();
        Get.back();
        Get.snackbar(
          'Plan Created',
          'Subscription tier $name created successfully.',
          backgroundColor: AppTheme.accentEmerald,
          colorText: Colors.white,
        );
      }
    }

    void showAddPlanDialog() {
      bool addKitchen = true;
      bool addStaff = true;
      bool addInventory = true;

      Get.dialog(
        StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Create Subscription Plan',
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
                      labelText: 'Plan Name',
                      hintText: 'e.g. Ultra Enterprise',
                      labelStyle: TextStyle(color: Colors.black54),
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    style: const TextStyle(color: Colors.black),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monthly Price (Rs.)',
                      labelStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'What features does it include?',
                      labelStyle: TextStyle(color: Colors.black54),
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedBilling,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(
                      labelText: 'Billing Cycle',
                      labelStyle: TextStyle(color: Colors.black54),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Monthly', child: Text('Monthly', style: TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: 'Yearly', child: Text('Yearly', style: TextStyle(color: Colors.black))),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        selectedBilling = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Kitchen Monitor Display', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    value: addKitchen,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setDialogState(() {
                        addKitchen = val ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Staff & Multi-user Creation', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    value: addStaff,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setDialogState(() {
                        addStaff = val ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Inventory & Recipes', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    value: addInventory,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setDialogState(() {
                        addInventory = val ?? true;
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
                onPressed: () => addPlan(addKitchen, addStaff, addInventory),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryDark),
                child: const Text('Create Plan', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    void showEditPlanDialog(PlanModel plan) {
      nameController.text = plan.name;
      priceController.text = plan.price.toString();
      descController.text = plan.desc;
      selectedBilling = plan.billing;
      
      bool editKitchen = plan.hasKitchen;
      bool editStaff = plan.hasStaff;
      bool editInventory = plan.hasInventory;

      Get.dialog(
        StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Edit Subscription Plan',
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
                      labelText: 'Plan Name',
                      labelStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    style: const TextStyle(color: Colors.black),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monthly Price (Rs.)',
                      labelStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedBilling,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(
                      labelText: 'Billing Cycle',
                      labelStyle: TextStyle(color: Colors.black54),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Monthly', child: Text('Monthly', style: TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: 'Yearly', child: Text('Yearly', style: TextStyle(color: Colors.black))),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        selectedBilling = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Kitchen Monitor Display', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    value: editKitchen,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setDialogState(() {
                        editKitchen = val ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Staff & Multi-user Creation', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    value: editStaff,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setDialogState(() {
                        editStaff = val ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Inventory & Recipes', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    value: editInventory,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setDialogState(() {
                        editInventory = val ?? true;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  nameController.clear();
                  priceController.clear();
                  descController.clear();
                  Get.back();
                },
                child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.black54)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final priceStr = priceController.text.trim();
                  final desc = descController.text.trim();

                  if (name.isNotEmpty && priceStr.isNotEmpty && desc.isNotEmpty) {
                    await controller.updatePlan(
                      oldName: plan.name,
                      name: name,
                      price: priceStr,
                      billing: selectedBilling,
                      desc: desc,
                      hasKitchen: editKitchen,
                      hasStaff: editStaff,
                      hasInventory: editInventory,
                    );
                    nameController.clear();
                    priceController.clear();
                    descController.clear();
                    Get.back();
                    Get.snackbar(
                      'Plan Updated',
                      'Plan details updated successfully.',
                      backgroundColor: AppTheme.accentTeal,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryDark),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    void showDeletePlanDialog(PlanModel plan) {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Delete Subscription Plan',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: Text(
            'Are you sure you want to delete the "${plan.name}" plan? This action cannot be undone.',
            style: GoogleFonts.inter(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.deletePlan(plan.name);
                Get.back();
                Get.snackbar(
                  'Plan Deleted',
                  'The plan has been deleted successfully.',
                  backgroundColor: AppTheme.accentRose,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRose),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: showAddPlanDialog,
        backgroundColor: AppTheme.primaryDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Matrix',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  itemCount: controller.plans.length,
                  itemBuilder: (context, index) {
                    final plan = controller.plans[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryDark.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.card_membership, color: AppTheme.primaryDark, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan.name,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        plan.desc,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      Formatters.formatCurrency(plan.price),
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppTheme.accentTeal,
                                      ),
                                    ),
                                    Text(
                                      plan.billing,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryDark),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () => showEditPlanDialog(plan),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.accentRose),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () => showDeletePlanDialog(plan),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Colors.black12, height: 1),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildFeatureBadge('Kitchen Monitor', plan.hasKitchen),
                                _buildFeatureBadge('Staff Creation', plan.hasStaff),
                                _buildFeatureBadge('Inventory & Recipes', plan.hasInventory),
                              ],
                            ),
                          ],
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

  Widget _buildFeatureBadge(String label, bool isEnabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isEnabled ? AppTheme.accentEmerald.withOpacity(0.1) : Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isEnabled ? AppTheme.accentEmerald.withOpacity(0.3) : Colors.red.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEnabled ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: isEnabled ? AppTheme.accentEmerald : Colors.redAccent,
            size: 12,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isEnabled ? AppTheme.accentEmerald : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
