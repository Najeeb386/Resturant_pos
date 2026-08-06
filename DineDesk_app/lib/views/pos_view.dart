import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class PosView extends StatelessWidget {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth >= 768;

        return Scaffold(
          body: isWide
              ? Row(
                  children: [
                    Expanded(flex: 6, child: _buildMenuSection(context, provider)),
                    VerticalDivider(width: 1, color: Colors.grey.shade200),
                    Expanded(flex: 4, child: _buildCartSection(context, provider)),
                  ],
                )
              : Column(
                  children: [
                    Expanded(child: _buildMenuSection(context, provider)),
                    if (provider.cart.isNotEmpty || provider.drafts.isNotEmpty)
                      _buildMobileCartBar(context, provider),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildMenuSection(BuildContext context, AppProvider provider) {
    List<MenuItem> filteredItems = provider.menuItems.where((item) {
      bool catMatch = provider.selectedCategory == 'All' ||
          provider.categories.any((c) => c.name == provider.selectedCategory && c.id == item.categoryId);
      bool searchMatch = item.name.toLowerCase().contains(provider.searchQuery.toLowerCase());
      return catMatch && searchMatch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search menu items...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),

          // Categories horizontal scroll
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _categoryChip(context, provider, 'All'),
                ...provider.categories.map((c) => _categoryChip(context, provider, c.name)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Products Grid (Fixed Aspect Ratio to 0.70 to prevent pixel overflow)
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('No menu items found.', style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      bool hasVars = item.variants.isNotEmpty;
                      bool isOutOfStock = item.stockQuantity <= 0;
                      bool isLowStock = item.stockQuantity > 0 && item.stockQuantity <= 5;

                      return Card(
                        elevation: isOutOfStock ? 0 : 0.5,
                        color: isOutOfStock ? Colors.grey.shade100 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: isOutOfStock ? Colors.grey.shade300 : Colors.grey.shade200),
                        ),
                        child: Stack(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                if (isOutOfStock) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${item.name} is currently out of stock!'),
                                      backgroundColor: Colors.red.shade700,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                if (hasVars) {
                                  _showSizeSelectorModal(context, provider, item);
                                } else {
                                  bool success = provider.addToCart(item);
                                  if (!success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Cannot add more ${item.name}. Maximum available stock is ${item.stockQuantity}.'),
                                        backgroundColor: Colors.amber.shade900,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Opacity(
                                      opacity: isOutOfStock ? 0.35 : 1.0,
                                      child: const Text('🍽️', style: TextStyle(fontSize: 32)),
                                    ),
                                    Text(
                                      item.name,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: isOutOfStock ? Colors.grey.shade500 : Colors.black87,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          hasVars ? 'Rs ${item.price.toStringAsFixed(0)}+' : 'Rs ${item.price.toStringAsFixed(0)}',
                                          style: isOutOfStock 
                                              ? TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade400, decoration: TextDecoration.lineThrough, fontSize: 12)
                                              : const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 13),
                                        ),
                                        if (hasVars)
                                          Container(
                                            margin: const EdgeInsets.only(top: 2),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: isOutOfStock ? Colors.grey.shade200 : Colors.purple.shade50,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${item.variants.length} Sizes',
                                              style: TextStyle(
                                                fontSize: 9, 
                                                fontWeight: FontWeight.bold, 
                                                color: isOutOfStock ? Colors.grey.shade600 : Colors.purple.shade800,
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            // Stock Badge Top Right
                            Positioned(
                              top: 6,
                              right: 6,
                              child: isOutOfStock
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade600,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'OUT OF STOCK',
                                        style: TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w900),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isLowStock ? Colors.amber.shade100 : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: isLowStock ? Colors.amber.shade300 : Colors.green.shade200),
                                      ),
                                      child: Text(
                                        'Stock: ${item.stockQuantity}',
                                        style: TextStyle(
                                          color: isLowStock ? Colors.amber.shade900 : Colors.green.shade800,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(BuildContext context, AppProvider provider, String label) {
    bool isSelected = provider.selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => provider.setSelectedCategory(label),
        selectedColor: Colors.deepOrange,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
      ),
    );
  }

  Widget _buildCartSection(BuildContext context, AppProvider provider) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  if (provider.drafts.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _showDraftsModal(context, provider),
                      icon: const Icon(Icons.bookmark_outline, size: 18, color: Colors.purple),
                      label: Text('Drafts (${provider.drafts.length})', style: TextStyle(color: Colors.purple.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  Chip(
                    label: Text('${provider.cart.length} items', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.deepOrange,
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),

          // Order type selection (Takeaway, Dine In, Delivery)
          Row(
            children: [
              _orderTypeBtn(provider, 'takeaway', 'Takeaway'),
              const SizedBox(width: 6),
              _orderTypeBtn(provider, 'dine_in', 'Dine In'),
              const SizedBox(width: 6),
              _orderTypeBtn(provider, 'delivery', 'Delivery'),
            ],
          ),
          const SizedBox(height: 10),

          // Dine In Table Selector Dropdown
          if (provider.orderType == 'dine_in')
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepOrange.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text('Select Table for Dine-In', style: TextStyle(fontSize: 13)),
                  value: provider.selectedTableId,
                  items: provider.tables.map((t) {
                    return DropdownMenuItem<int>(
                      value: t.id,
                      child: Text('Table ${t.tableNumber} (${t.capacity} Seats)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (val) => provider.setSelectedTableId(val),
                ),
              ),
            ),

          // Cart Items List
          Expanded(
            child: provider.cart.isEmpty
                ? const Center(child: Text('No items in cart', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: provider.cart.length,
                    itemBuilder: (context, index) {
                      final item = provider.cart[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('Rs ${(item.price * item.qty).toStringAsFixed(2)}', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 22, color: Colors.grey),
                                  onPressed: () => provider.updateCartQty(item.cartKey, -1),
                                ),
                                Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 22, color: Colors.deepOrange),
                                  onPressed: () {
                                    bool success = provider.updateCartQty(item.cartKey, 1);
                                    if (!success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Stock limit reached! Cannot add more.'),
                                          backgroundColor: Colors.amber,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(),

          // Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text('Rs ${provider.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tax (10%)', style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text('Rs ${provider.tax.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Rs ${provider.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ],
          ),
          const SizedBox(height: 10),

          // Actions Row (Hold Draft & Pay Now)
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.purple),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: provider.cart.isEmpty
                        ? null
                        : () {
                            provider.saveAsDraft();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order saved as Draft!'), backgroundColor: Colors.purple),
                            );
                          },
                    icon: const Icon(Icons.bookmark, color: Colors.purple, size: 18),
                    label: const Text('Hold Draft', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: provider.cart.isEmpty
                        ? null
                        : () async {
                            if (provider.orderType == 'dine_in' && provider.selectedTableId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a Table for Dine-In order'), backgroundColor: Colors.amber),
                              );
                              return;
                            }
                            try {
                              var order = await provider.submitOrder();
                              String orderIdShort = order.localId.length >= 4 ? order.localId.substring(order.localId.length - 4) : order.localId;
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Order #$orderIdShort completed successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Order failed: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                    child: const Text('Pay Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _orderTypeBtn(AppProvider provider, String type, String label) {
    bool isSelected = provider.orderType == type;
    return Expanded(
      child: Material(
        color: isSelected ? Colors.deepOrange : Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => provider.setOrderType(type),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade300),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCartBar(BuildContext context, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade900,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${provider.cart.length} item(s)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text('Rs ${provider.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              if (provider.drafts.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.bookmark, color: Colors.purpleAccent),
                  onPressed: () => _showDraftsModal(context, provider),
                ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (modalContext) => Consumer<AppProvider>(
                      builder: (modalContext, modalProvider, child) => SizedBox(
                        height: MediaQuery.of(modalContext).size.height * 0.85,
                        child: _buildCartSection(modalContext, modalProvider),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: const Text('View Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showSizeSelectorModal(BuildContext context, AppProvider provider, MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(item.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please select a size:', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            ...item.variants.map((v) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text('Rs ${v.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    onTap: () {
                      bool success = provider.addVariantToCart(item, v);
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cannot add more ${item.name} (${v.name}). Maximum stock available is ${item.stockQuantity}.'),
                            backgroundColor: Colors.amber.shade900,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showDraftsModal(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Saved Draft Bills', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: provider.drafts.isEmpty
              ? const Text('No drafts saved.', textAlign: TextAlign.center)
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.drafts.length,
                  itemBuilder: (context, index) {
                    final draft = provider.drafts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(draft.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${draft.items.length} items • Rs ${draft.total.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.upload, color: Colors.blue),
                              onPressed: () {
                                provider.loadDraft(draft);
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => provider.deleteDraft(draft.localId),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
