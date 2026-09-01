import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:resturant_pos_app/providers/pos_provider.dart';
import 'package:resturant_pos_app/providers/management_providers.dart';
import 'package:resturant_pos_app/views/pos/cart_pane.dart';
import 'package:resturant_pos_app/views/pos/draft_orders_modal.dart';

class PosView extends StatefulWidget {
  const PosView({super.key});

  @override
  State<PosView> createState() => _PosViewState();
}

class _PosViewState extends State<PosView> {
  String? _selectedCategoryId;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final managementController = Get.find<ManagementController>();
    final posController = Get.find<PosController>();

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 950;

    return Scaffold(
      body: Row(
        children: [
          // Items Grid Section
          Expanded(
            flex: 3,
            child: Obx(() {
              final categories = managementController.categories.toList();
              final menuItems = managementController.menuItems.toList();
              final posState = posController.state.value;

              // 1. Group sized items dynamically by base name
              final Map<String, List<LocalMenuItem>> grouped = {};
              final List<LocalMenuItem> displayItems = [];

              for (final item in menuItems) {
                // Check if this item is in the selected category
                final matchesCategory = _selectedCategoryId == null || item.categoryId == _selectedCategoryId;
                final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
                if (!matchesCategory || !matchesSearch) continue;

                // Match base name and size, e.g. "Pepperoni Pizza (Small)" -> "Pepperoni Pizza", "Small"
                final match = RegExp(r'^(.+?)\s*\(([^)]+)\)$').firstMatch(item.name);
                if (match != null) {
                  final baseName = match.group(1)!.trim();
                  if (!grouped.containsKey(baseName)) {
                    grouped[baseName] = [];
                  }
                  grouped[baseName]!.add(item);
                } else {
                  displayItems.add(item);
                }
              }

              // For each group, create a single representative display item
              for (final baseName in grouped.keys) {
                final itemsInGroup = grouped[baseName]!;
                itemsInGroup.sort((a, b) => a.price.compareTo(b.price));

                final lowestPriceItem = itemsInGroup.first;
                final totalStock = itemsInGroup.fold<int>(0, (sum, element) => sum + element.stockQuantity);
                
                final repItem = LocalMenuItem(
                  id: lowestPriceItem.id,
                  restaurantId: lowestPriceItem.restaurantId,
                  categoryId: lowestPriceItem.categoryId,
                  name: baseName,
                  description: lowestPriceItem.description,
                  imageUrl: lowestPriceItem.imageUrl,
                  price: lowestPriceItem.price,
                  costPrice: lowestPriceItem.costPrice,
                  stockQuantity: totalStock,
                  isDeal: lowestPriceItem.isDeal,
                );
                displayItems.add(repItem);
              }

              // Sort displays items so everything is neat
              displayItems.sort((a, b) => a.name.compareTo(b.name));

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'POS Terminal',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const DraftOrdersModal(),
                            );
                          },
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Draft Bills'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            side: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search menu items...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                        hintStyle: const TextStyle(color: Colors.white30),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Categories List
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length + 1,
                        itemBuilder: (context, index) {
                          final isAll = index == 0;
                          final cat = isAll ? null : categories[index - 1];
                          final isSelected = isAll
                              ? _selectedCategoryId == null
                              : _selectedCategoryId == cat!.id;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(isAll ? 'All Items' : cat!.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategoryId = isAll ? null : cat!.id;
                                });
                              },
                              backgroundColor: AppTheme.surfaceDark,
                              selectedColor: AppTheme.primaryDark,
                              labelStyle: GoogleFonts.outfit(
                                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grid
                    Expanded(
                      child: displayItems.isEmpty
                          ? Center(
                              child: Text(
                                'No items found matching criteria.',
                                style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isTablet ? 3 : 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: displayItems.length,
                              itemBuilder: (context, index) {
                                final item = displayItems[index];
                                return _buildItemCard(item, posController, grouped);
                              },
                            ),
                    ),
                  ],
                ),
              );
            }),
          ),

          // Cart Section (Visible on tablet side-by-side, or accessed via FAB on mobile)
          if (isTablet) ...[
            const VerticalDivider(thickness: 1, width: 1, color: AppTheme.borderDark),
            const Expanded(
              flex: 2,
              child: CartPane(),
            ),
          ],
        ],
      ),
      floatingActionButton: !isTablet
          ? Obx(() {
              final posState = posController.state.value;
              final cartLength = posState.cart.fold(0, (sum, element) => sum + element.quantity);
              return FloatingActionButton.extended(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppTheme.backgroundDark,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.9,
                      maxChildSize: 0.95,
                      minChildSize: 0.5,
                      expand: false,
                      builder: (context, scrollController) => const CartPane(),
                    ),
                  );
                },
                backgroundColor: AppTheme.primaryDark,
                icon: Badge(
                  label: Text('$cartLength'),
                  child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                ),
                label: Text(
                  'Checkout (${Formatters.formatCurrency(posState.subtotal)})',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              );
            })
          : null,
    );
  }

  Widget _buildItemCard(
    LocalMenuItem item, 
    PosController posController, 
    Map<String, List<LocalMenuItem>> grouped,
  ) {
    final hasSizes = grouped.containsKey(item.name);
    final hasStock = item.stockQuantity > 0 || item.isDeal;
    final isOutOfStock = !hasStock && item.stockQuantity == 0;

    return Card(
      child: InkWell(
        onTap: isOutOfStock
            ? null
            : () {
                if (hasSizes) {
                  _showSizeSelectDialog(context, item.name, grouped[item.name]!, posController);
                } else {
                  posController.addToCart(item);
                }
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                item.isDeal ? Icons.local_offer_outlined : Icons.restaurant_outlined,
                                color: Theme.of(context).primaryColor.withOpacity(0.5),
                                size: 32,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              item.isDeal ? Icons.local_offer_outlined : Icons.restaurant_outlined,
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                              size: 32,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Item Name
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isOutOfStock ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4) : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              // Subtitle (Description or Stock)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hasSizes ? 'From ${Formatters.formatCurrency(item.price)}' : Formatters.formatCurrency(item.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isOutOfStock ? AppTheme.accentTeal.withOpacity(0.4) : AppTheme.accentTeal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (item.stockQuantity > 0)
                    Text(
                      'Qty: ${item.stockQuantity}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    )
                  else if (isOutOfStock)
                    Flexible(
                      child: Text(
                        'OUT OF STOCK',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentRose,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSizeSelectDialog(
    BuildContext context, 
    String baseName, 
    List<LocalMenuItem> sizes, 
    PosController posController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Select Size - $baseName',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: SizedBox(
          width: 320,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: sizes.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final sizeItem = sizes[index];
              
              // Extract size name from parenthetical suffix
              final match = RegExp(r'\(([^)]+)\)$').firstMatch(sizeItem.name);
              final sizeName = match != null ? match.group(1) : 'Standard';
              
              final isOutOfStock = sizeItem.stockQuantity == 0 && !sizeItem.isDeal;

              return ListTile(
                title: Text(
                  sizeName!,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: isOutOfStock ? Colors.grey : Colors.black87,
                  ),
                ),
                trailing: Text(
                  isOutOfStock ? 'OUT OF STOCK' : Formatters.formatCurrency(sizeItem.price),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: isOutOfStock ? AppTheme.accentRose : AppTheme.accentTeal,
                  ),
                ),
                onTap: isOutOfStock ? null : () {
                  posController.addToCart(sizeItem);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
