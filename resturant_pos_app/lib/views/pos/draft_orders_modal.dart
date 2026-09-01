import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:drift/drift.dart' as d;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:resturant_pos_app/providers/database_provider.dart';
import 'package:resturant_pos_app/providers/pos_provider.dart';

class DraftOrdersModal extends StatefulWidget {
  const DraftOrdersModal({super.key});

  @override
  State<DraftOrdersModal> createState() => _DraftOrdersModalState();
}

class _DraftOrdersModalState extends State<DraftOrdersModal> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _dataFuture = _loadDraftsData();
    });
  }

  Future<Map<String, dynamic>> _loadDraftsData() async {
    final db = databaseProvider;
    final auth = authProvider.state.value;
    final restaurantId = auth.restaurant?.id ?? '';

    // Fetch tables to map IDs to Table Numbers
    final tables = await db.select(db.localTables).get();
    final tableMap = {for (var t in tables) t.id: t.tableNumber};

    // Fetch draft orders
    final drafts = await (db.select(db.localOrders)
          ..where((t) => t.restaurantId.equals(restaurantId) & t.status.equals('draft'))
          ..orderBy([(t) => d.OrderingTerm(expression: t.createdAt, mode: d.OrderingMode.desc)]))
        .get();

    return {
      'tableMap': tableMap,
      'drafts': drafts,
    };
  }

  @override
  Widget build(BuildContext context) {
    final posController = Get.find<PosController>();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.folder_open, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            'Active Table / Draft Bills',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading draft bills: ${snapshot.error}'),
              );
            }

            final data = snapshot.data!;
            final tableMap = data['tableMap'] as Map<String, String>;
            final drafts = data['drafts'] as List<LocalOrder>;

            if (drafts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_off_outlined, size: 48, color: const Color(0xFF64748B).withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No active draft bills found.',
                      style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: drafts.length,
              itemBuilder: (context, index) {
                final order = drafts[index];
                
                // Get table description
                String orderSource = 'Walk-in / Takeaway';
                if (order.orderType == 'dine_in') {
                  final tableNum = order.tableId != null ? tableMap[order.tableId] : null;
                  orderSource = tableNum != null ? 'Table $tableNum' : 'Dine In (No Table)';
                } else if (order.orderType == 'delivery') {
                  orderSource = 'Delivery - ${order.customerName ?? "Unknown"}';
                }

                final formattedTime = DateFormat('hh:mm a').format(order.createdAt);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      orderSource,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Time: $formattedTime | Total: ${Formatters.formatCurrency(order.total)}',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Load Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            await posController.loadDraft(order.id);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.open_in_new, size: 14, color: Colors.white),
                          label: Text(
                            'Load',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.accentRose),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Draft?'),
                                content: const Text('Are you sure you want to delete this draft bill?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Delete', style: TextStyle(color: AppTheme.accentRose)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await posController.deleteDraftOrder(order.id);
                              _refreshData();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
