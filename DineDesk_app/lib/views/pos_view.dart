import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class PosView extends StatelessWidget {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Responsive layout check
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth >= 768; // Tablet or Landscape

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
                    if (provider.cart.isNotEmpty) _buildMobileCartBar(context, provider),
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
              hintText: 'Search menu...',
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

          // Products Grid
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('No menu items found.', style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      bool hasVars = item.variants.isNotEmpty;

                      return Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (hasVars) {
                              _showSizeSelectorModal(context, provider, item);
                            } else {
                              provider.addToCart(item);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🍽️', style: TextStyle(fontSize: 36)),
                                const SizedBox(height: 8),
                                Text(
                                  item.name,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hasVars ? 'Rs ${item.price.toStringAsFixed(0)}+' : 'Rs ${item.price.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                ),
                                if (hasVars)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${item.variants.length} Sizes',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.purple.shade800),
                                    ),
                                  ),
                              ],
                            ),
                          ),
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
              Chip(
                label: Text('${provider.cart.length} items', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.deepOrange,
              )
            ],
          ),
          const SizedBox(height: 12),

          // Order type selection
          Row(
            children: [
              _orderTypeBtn(provider, 'takeaway', 'Takeaway'),
              const SizedBox(width: 8),
              _orderTypeBtn(provider, 'dine_in', 'Dine In'),
              const SizedBox(width: 8),
              _orderTypeBtn(provider, 'delivery', 'Delivery'),
            ],
          ),
          const SizedBox(height: 12),

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
                        padding: const EdgeInsets.all(12),
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
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Rs ${(item.price * item.qty).toStringAsFixed(2)}', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () => provider.updateCartQty(item.cartKey, -1),
                                ),
                                Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.deepOrange),
                                  onPressed: () => provider.updateCartQty(item.cartKey, 1),
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
              const Text('Subtotal', style: TextStyle(color: Colors.grey)),
              Text('Rs ${provider.subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tax (10%)', style: TextStyle(color: Colors.grey)),
              Text('Rs ${provider.tax.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Rs ${provider.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ],
          ),
          const SizedBox(height: 12),

          // Pay Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: provider.cart.isEmpty
                  ? null
                  : () async {
                      try {
                        var order = await provider.submitOrder();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order #${order.localId.substring(order.localId.length - 4)} completed!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Order failed: $e'), backgroundColor: Colors.red),
                        );
                      }
                    },
              child: const Text('Pay Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _orderTypeBtn(AppProvider provider, String type, String label) {
    bool isSelected = provider.orderType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setOrderType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepOrange : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade700,
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
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => SizedBox(height: MediaQuery.of(context).size.height * 0.8, child: _buildCartSection(context, provider)),
              );
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: const Text('View Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      provider.addVariantToCart(item, v);
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
