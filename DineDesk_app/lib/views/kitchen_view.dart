import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class KitchenView extends StatefulWidget {
  const KitchenView({super.key});

  @override
  State<KitchenView> createState() => _KitchenViewState();
}

class _KitchenViewState extends State<KitchenView> {
  String _searchQuery = '';
  String _selectedFilter = 'All'; // All | Pending | Preparing | Dine-In | Takeaway
  final Set<String> _knownOrderIds = {};
  bool _isFirstLoad = true;

  void _checkAndPlayNotificationSound(List<OrderModel> currentOrders) {
    bool hasNewOrder = false;
    for (var o in currentOrders) {
      if (!_knownOrderIds.contains(o.localId)) {
        _knownOrderIds.add(o.localId);
        if (!_isFirstLoad) {
          hasNewOrder = true;
        }
      }
    }
    _isFirstLoad = false;

    if (hasNewOrder) {
      // Play notification sound and haptic vibration for new kitchen ticket!
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Active orders for kitchen display
    var activeOrders = provider.orders
        .where((o) => o.status != 'completed' && o.status != 'cancelled')
        .toList();

    // Sort LATEST ON TOP (newest orders first)
    activeOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Check for newly arrived orders to trigger chime sound!
    _checkAndPlayNotificationSound(activeOrders);

    // Apply Search & Filter
    var filteredOrders = activeOrders.where((order) {
      // Status & OrderType Filter
      if (_selectedFilter == 'Pending' && order.status == 'preparing') return false;
      if (_selectedFilter == 'Preparing' && order.status != 'preparing') return false;
      if (_selectedFilter == 'Dine-In' && order.orderType != 'dine_in') return false;
      if (_selectedFilter == 'Takeaway' && order.orderType != 'takeaway') return false;

      // Text Search Filter
      if (_searchQuery.isNotEmpty) {
        String q = _searchQuery.toLowerCase();
        String ticketIdStr = order.localId.toLowerCase();
        String tableStr = order.tableId != null ? 'table ${order.tableId}' : '';
        String customerStr = order.customerName.toLowerCase();
        bool matchesItems = order.items.any((i) => i.name.toLowerCase().contains(q));

        if (!ticketIdStr.contains(q) &&
            !tableStr.contains(q) &&
            !customerStr.contains(q) &&
            !matchesItems) {
          return false;
        }
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Search & Filter Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: Colors.white,
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search ticket #, item name, table...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Realtime Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('All', activeOrders.length),
                      _filterChip('Pending', activeOrders.where((o) => o.status != 'preparing').length),
                      _filterChip('Preparing', activeOrders.where((o) => o.status == 'preparing').length),
                      _filterChip('Dine-In', activeOrders.where((o) => o.orderType == 'dine_in').length),
                      _filterChip('Takeaway', activeOrders.where((o) => o.orderType == 'takeaway').length),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Kitchen Tickets Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.soup_kitchen_outlined, size: 56, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No kitchen tickets found',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text('New orders will appear here automatically with chime sound.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 340,
                        mainAxisExtent: 260,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        String ticketIdStr = order.localId.length >= 3 ? order.localId.substring(order.localId.length - 3) : order.localId;
                        bool isPreparing = order.status == 'preparing';

                        return _KitchenTicketCard(
                          key: ValueKey(order.localId),
                          order: order,
                          ticketIdStr: ticketIdStr,
                          isPreparing: isPreparing,
                          provider: provider,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int count) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        label: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
        selectedColor: Colors.deepOrange,
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) => setState(() => _selectedFilter = label),
      ),
    );
  }
}

class _KitchenTicketCard extends StatefulWidget {
  final OrderModel order;
  final String ticketIdStr;
  final bool isPreparing;
  final AppProvider provider;

  const _KitchenTicketCard({
    super.key,
    required this.order,
    required this.ticketIdStr,
    required this.isPreparing,
    required this.provider,
  });

  @override
  State<_KitchenTicketCard> createState() => _KitchenTicketCardState();
}

class _KitchenTicketCardState extends State<_KitchenTicketCard> {
  bool _isLoading = false;

  String _formatTime(String createdAt) {
    try {
      DateTime dt = DateTime.parse(createdAt);
      String hh = dt.hour.toString().padLeft(2, '0');
      String mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } catch (_) {
      return '09:58';
    }
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = widget.isPreparing ? Colors.amber.shade800 : Colors.red;
    String statusText = widget.isPreparing ? 'PREPARING' : 'PENDING';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Top Colored Border Strip
            Container(
              height: 5,
              width: double.infinity,
              color: themeColor,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: #210 NEW PENDING
                    Row(
                      children: [
                        Text(
                          '#${widget.ticketIdStr}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // NEW Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Color(0xFFE11D48),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Status Badge (PENDING / PREPARING)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.isPreparing
                                ? Colors.amber.shade50
                                : const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: widget.isPreparing
                                  ? Colors.amber.shade900
                                  : const Color(0xFFBE123C),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Sub-Header Row: Order Type & Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.order.tableId != null
                              ? 'Table ${widget.order.tableId}'
                              : widget.order.orderType == 'takeaway'
                                  ? 'Takeaway'
                                  : 'Delivery',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(widget.order.createdAt),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Items Container Box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.order.items.length,
                          itemBuilder: (context, idx) {
                            final item = widget.order.items[idx];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${item.qty}x',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xFF0F172A),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Action Button (Start Preparing / Mark Ready)
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.isPreparing
                              ? const Color(0xFF16A34A) // Green for Mark Ready
                              : const Color(0xFFFF5722), // Deep Vibrant Orange for Start Preparing
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                try {
                                  String nextStatus = widget.isPreparing ? 'completed' : 'preparing';
                                  await widget.provider.updateOrderStatusAsync(widget.order.localId, nextStatus);
                                  if (mounted && widget.isPreparing) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Ticket #${widget.ticketIdStr} Marked Ready & Cleared!'),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.isPreparing ? Icons.check_circle : Icons.restaurant,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.isPreparing ? 'Mark Ready ✓' : 'Start Preparing',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
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
}
