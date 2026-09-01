import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/superadmin_provider.dart';
import 'package:resturant_pos_app/providers/database_provider.dart';
import 'package:resturant_pos_app/core/utils/backup_helper.dart';
import 'package:resturant_pos_app/core/utils/backup_helper/backup_exporter.dart';

class SuperAdminDashboardView extends StatelessWidget {
  const SuperAdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = superAdminProvider;

    return Scaffold(
      body: Obx(() {
        final mrr = controller.mrr;
        final activeTenants = controller.activeCount;
        final totalTenants = controller.tenants.length;
        final expiringCount = controller.expiringCount;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SaaS Platform Performance',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'System-wide metrics and tenant activity',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 28),

              // Statistics Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 650;
                  if (isMobile) {
                    return Column(
                      children: [
                        _buildStatCard('Monthly Revenue (MRR)', mrr, Icons.monetization_on_outlined, AppTheme.accentTeal),
                        const SizedBox(height: 12),
                        _buildStatCard('Active Restaurants', activeTenants.toDouble(), Icons.store_outlined, AppTheme.accentEmerald, isCount: true),
                        const SizedBox(height: 12),
                        _buildStatCard('Total Signups', totalTenants.toDouble(), Icons.people_outline, AppTheme.primaryDark, isCount: true),
                        const SizedBox(height: 12),
                        _buildStatCard('Expiring Subscriptions', expiringCount.toDouble(), Icons.warning_amber_outlined, AppTheme.accentAmber, isCount: true),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: _buildStatCard('Monthly Revenue (MRR)', mrr, Icons.monetization_on_outlined, AppTheme.accentTeal)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Active Restaurants', activeTenants.toDouble(), Icons.store_outlined, AppTheme.accentEmerald, isCount: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Total Signups', totalTenants.toDouble(), Icons.people_outline, AppTheme.primaryDark, isCount: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Expiring Subscriptions', expiringCount.toDouble(), Icons.warning_amber_outlined, AppTheme.accentAmber, isCount: true)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Charts & Signups
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 900;
                  if (isMobile) {
                    return Column(
                      children: [
                        _buildRevenueChart(),
                        const SizedBox(height: 24),
                        _buildRecentSignups(controller.tenants),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildRevenueChart()),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildRecentSignups(controller.tenants)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildGlobalBackupCard(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(String title, double value, IconData icon, Color color, {bool isCount = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCount ? value.toInt().toString() : Formatters.formatCurrency(value),
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MRR Revenue Trend (SaaS)',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1000),
                        FlSpot(1, 1200),
                        FlSpot(2, 1600),
                        FlSpot(3, 1850),
                        FlSpot(4, 2100),
                        FlSpot(5, 2450),
                      ],
                      isCurved: true,
                      color: AppTheme.accentTeal,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.accentTeal.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSignups(List<TenantModel> tenants) {
    final recent = tenants.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Signups',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              itemBuilder: (context, index) {
                final signup = recent[index];
                Color statusColor = AppTheme.accentEmerald;
                if (signup.status == 'Trial') statusColor = AppTheme.accentAmber;
                if (signup.status == 'Expired' || signup.status == 'Suspended') {
                  statusColor = AppTheme.accentRose;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              signup.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
                            ),
                            Text(
                              'Plan: ${signup.plan}',
                              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                            ),
                          ],
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
                          signup.status.toUpperCase(),
                          style: GoogleFonts.outfit(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalBackupCard(BuildContext context) {
    final RxBool isBackingUp = false.obs;

    return Obx(() {
      final backingUp = isBackingUp.value;

      return Card(
        color: AppTheme.primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.backup_table_outlined, color: AppTheme.accentEmerald, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Global Database Backup',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Generate and export a global SQL database backup containing ALL tenants\' tables, users, transactions, and system-wide configurations.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: backingUp ? null : () async {
                  isBackingUp.value = true;
                  try {
                    final db = databaseProvider;
                    final sqlDump = await BackupHelper.generateSqlDump(db);
                    final fileName = 'global_restaurant_pos_backup_${DateTime.now().millisecondsSinceEpoch}.sql';
                    
                    await saveAndShareFile(fileName, sqlDump);
                    
                    Get.snackbar(
                      'Global Backup Complete',
                      'Full SQL database backup exported successfully.',
                      backgroundColor: AppTheme.accentEmerald,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Backup Failed',
                      'Could not export global database: $e',
                      backgroundColor: AppTheme.accentRose,
                      colorText: Colors.white,
                    );
                  } finally {
                    isBackingUp.value = false;
                  }
                },
                icon: backingUp 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Icon(Icons.backup_outlined, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentEmerald,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                label: Text(
                  backingUp ? 'Exporting...' : 'Export Global Backup (.sql)',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
