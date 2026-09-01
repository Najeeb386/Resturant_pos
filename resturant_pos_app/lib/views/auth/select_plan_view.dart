import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/providers/superadmin_provider.dart';

class SelectPlanView extends StatelessWidget {
  const SelectPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 750;
    final plansController = superAdminProvider;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF121214), // Carbon Slate Black
              Color(0xFF1C1917), // Stone Grey
              Color(0xFF2E1A05), // Dark Warm Chocolate Orange Tint
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Choose Your Restaurant Plan',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: isTablet ? 36 : 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select the ideal fit for your operations. All plans include a 30-day Free Trial.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF94A3B8), // Slate 400
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                Obx(() {
                  final plansList = plansController.plans;

                  if (plansList.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: AppTheme.primaryLight),
                      ),
                    );
                  }

                  if (isTablet) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: plansList.map((plan) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: _buildPlanCard(context, plan),
                          ),
                        );
                      }).toList(),
                    );
                  }

                  return Column(
                    children: plansList.map((plan) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: _buildPlanCard(context, plan),
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, PlanModel plan) {
    Color accentColor = AppTheme.primaryLight;
    if (plan.name.toLowerCase() == 'standard') {
      accentColor = AppTheme.accentTeal;
    } else if (plan.name.toLowerCase() == 'premium') {
      accentColor = AppTheme.accentEmerald;
    }

    return Card(
      color: const Color(0xFF1E1E24), // Dark grey card background
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentColor.withOpacity(0.2), width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    'TRIAL',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  'Rs. ${plan.price.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  ' / ${plan.billing.toLowerCase().replaceAll('monthly', 'mo')}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              plan.desc,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final String planNameLower = plan.name.toLowerCase();
                
                final String terminalText = planNameLower.contains('basic')
                    ? '1 POS Terminal Limit' 
                    : planNameLower.contains('standard')
                        ? 'Up to 5 POS Terminals' 
                        : 'Unlimited POS Terminals';
                        
                final String reportsText = planNameLower.contains('basic')
                    ? 'Basic Sales Reports' 
                    : planNameLower.contains('standard')
                        ? 'Advanced Reports & Export' 
                        : 'Real-time Analytics & CSV Export';

                final bool hasTables = true;
                final bool hasDelivery = true;
                final bool hasExpenses = !planNameLower.contains('basic');

                return Column(
                  children: [
                    _buildFeatureRow('Kitchen Monitor Display', plan.hasKitchen),
                    const SizedBox(height: 12),
                    _buildFeatureRow('Staff & Cashier Terminals', plan.hasStaff),
                    const SizedBox(height: 12),
                    _buildFeatureRow('Ingredient Recipes & Stocks', plan.hasInventory),
                    const SizedBox(height: 12),
                    _buildFeatureRow(terminalText, true),
                    const SizedBox(height: 12),
                    _buildFeatureRow(reportsText, true),
                    const SizedBox(height: 12),
                    _buildFeatureRow('Tables Management', hasTables),
                    const SizedBox(height: 12),
                    _buildFeatureRow('Delivery & Takeaway Management', hasDelivery),
                    const SizedBox(height: 12),
                    _buildFeatureRow('Expenses Management', hasExpenses),
                  ],
                );
              }
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/RegisterView', arguments: {'selectedPlan': plan.name});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Choose ${plan.name}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: plan.name.toLowerCase() == 'basic' ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, bool included) {
    return Row(
      children: [
        Icon(
          included ? Icons.check_circle_outline : Icons.cancel_outlined,
          color: included ? AppTheme.accentEmerald : const Color(0xFF64748B),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          feature,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: included ? Colors.white70 : const Color(0xFF64748B),
            decoration: included ? TextDecoration.none : TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }
}
