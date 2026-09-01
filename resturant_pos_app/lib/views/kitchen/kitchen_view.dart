import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/kitchen_provider.dart';
import 'package:resturant_pos_app/providers/orders_provider.dart';

class KitchenView extends StatelessWidget {
  const KitchenView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = kitchenOrdersProvider;
    final ordersNotifier = ordersNotifierProvider;

    return Scaffold(
      body: Obx(() {
        final orders = controller.kitchenOrders;

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.kitchen_outlined, size: 48, color: const Color(0xFF64748B).withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'No active cooking tickets.',
                  style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                ),
              ],
            ),
          );
        }

        final width = MediaQuery.of(context).size.width;
        final int crossAxisCount = width < 600 ? 1 : (width < 900 ? 2 : 3);
        final double childAspectRatio = width < 600 ? 1.3 : 0.95;

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final details = orders[index];
            final isPending = details.order.status == 'pending' || details.order.status == 'draft';
            final isPreparing = details.order.status == 'preparing';
            final isReady = details.order.status == 'ready';

            Color headerColor = AppTheme.accentAmber;
            if (isPreparing) headerColor = AppTheme.primaryDark;
            if (isReady) headerColor = AppTheme.accentTeal;

            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ticket Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: headerColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${details.order.id.substring(0, 8).toUpperCase()}',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                              ),
                              Text(
                                '${details.order.orderType.toUpperCase()} | Table ${details.table?.tableNumber ?? "N/A"}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Formatters.formatTime(details.order.createdAt),
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  // Items List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: details.items.length,
                      itemBuilder: (context, idx) {
                        final item = details.items[idx];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${item.orderItem.quantity}x',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).primaryColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.menuItem?.name ?? 'Item',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Actions Button
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        if (isPending) ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ordersNotifier.updateOrderStatus(details.order.id, 'preparing');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryDark,
                                minimumSize: const Size.fromHeight(40),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Start Cooking'),
                            ),
                          ),
                        ],
                        if (isPreparing) ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ordersNotifier.updateOrderStatus(details.order.id, 'ready');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentTeal,
                                minimumSize: const Size.fromHeight(40),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Mark Ready'),
                            ),
                          ),
                        ],
                        if (isReady) ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ordersNotifier.updateOrderStatus(details.order.id, 'served');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentEmerald,
                                minimumSize: const Size.fromHeight(40),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Mark Served'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
