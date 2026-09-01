import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/management_providers.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';

class MenuManageView extends StatefulWidget {
  const MenuManageView({super.key});

  @override
  State<MenuManageView> createState() => _MenuManageViewState();
}

class _MenuManageViewState extends State<MenuManageView> {
  final _categoryController = TextEditingController();
  
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _itemCostController = TextEditingController();
  final _itemStockController = TextEditingController(text: '0');
  final _itemImageController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void dispose() {
    _categoryController.dispose();
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _itemCostController.dispose();
    _itemStockController.dispose();
    _itemImageController.dispose();
    super.dispose();
  }

  void _addCategory() async {
    final name = _categoryController.text.trim();
    final controller = Get.find<ManagementController>();
    if (name.isNotEmpty) {
      await controller.addCategory(name);
      _categoryController.clear();
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _addMenuItem() async {
    final name = _itemNameController.text.trim();
    final price = double.tryParse(_itemPriceController.text) ?? 0.0;
    final cost = double.tryParse(_itemCostController.text) ?? 0.0;
    final stock = int.tryParse(_itemStockController.text) ?? 0;
    final imageUrl = _itemImageController.text.trim();
    final controller = Get.find<ManagementController>();

    if (name.isNotEmpty && _selectedCategoryId != null) {
      await controller.addMenuItem(
        name: name,
        categoryId: _selectedCategoryId!,
        price: price,
        costPrice: cost,
        stock: stock,
        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      );
      _itemNameController.clear();
      _itemPriceController.clear();
      _itemCostController.clear();
      _itemStockController.text = '0';
      _itemImageController.clear();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManagementController>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Controls headers
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;
                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu Hierarchy',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _showAddCategoryDialog(),
                            icon: const Icon(Icons.folder_open_outlined, size: 16),
                            label: const Text('Add Category'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddItemDialog(controller.categories),
                            icon: const Icon(Icons.add, size: 16),
                            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                            label: const Text('Add Menu Item'),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Menu Hierarchy',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showAddCategoryDialog(),
                          icon: const Icon(Icons.folder_open_outlined, size: 16),
                          label: const Text('Add Category'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showAddItemDialog(controller.categories),
                          icon: const Icon(Icons.add, size: 16),
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                          label: const Text('Add Menu Item'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Main Listing
            Expanded(
              child: Obx(() {
                // Force GetX to register a dependency on all elements so edits update in real-time
                final categories = controller.categories.toList();
                final items = controller.menuItems.toList();

                if (categories.isEmpty) {
                  return Center(
                    child: Text(
                      'No categories configured. Add a category to get started.',
                      style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, catIdx) {
                    final cat = categories[catIdx];
                    final catItems = items.where((element) => element.categoryId == cat.id).toList();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        shape: const Border(),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cat.name,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor, size: 18),
                                  onPressed: () {
                                    _showEditCategoryDialog(cat);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppTheme.accentRose, size: 18),
                                  onPressed: () {
                                    controller.deleteCategory(cat.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        children: [
                          if (catItems.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'No items in this category.',
                                style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: catItems.length,
                              itemBuilder: (context, itemIdx) {
                                final item = catItems[itemIdx];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                          ? Image.network(
                                              item.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Icon(
                                                Icons.fastfood_outlined,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            )
                                          : Icon(
                                              Icons.fastfood_outlined,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                    ),
                                  ),
                                  title: Text(item.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                                  subtitle: Text(
                                    'Cost: ${Formatters.formatCurrency(item.costPrice)} | Stock: ${item.stockQuantity}',
                                    style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        Formatters.formatCurrency(item.price),
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.accentTeal, fontSize: 15),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor, size: 18),
                                        onPressed: () {
                                          _showEditItemDialog(item, controller.categories);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppTheme.accentRose, size: 18),
                                        onPressed: () {
                                          controller.deleteMenuItem(item.id);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
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

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Add Menu Category', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: 'Category Name', 
            hintText: 'e.g. Appetizers',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Theme.of(context).primaryColor)),
          ),
          ElevatedButton(
            onPressed: _addCategory,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(LocalMenuCategory category) {
    _categoryController.text = category.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Edit Menu Category', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g. Appetizers',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _categoryController.clear();
              Navigator.of(context).pop();
            },
            child: Text('Cancel', style: GoogleFonts.outfit(color: Theme.of(context).primaryColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = _categoryController.text.trim();
              if (newName.isNotEmpty) {
                await Get.find<ManagementController>().updateCategory(category.id, newName);
                _categoryController.clear();
                if (mounted) Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(List<LocalMenuCategory> currentCategories) {
    if (currentCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a category first.')),
      );
      return;
    }

    setState(() {
      _selectedCategoryId = currentCategories.first.id;
    });

    bool hasMultipleSizes = false;
    bool isDeal = false;
    final List<Map<String, dynamic>> selectedDealProducts = [];
    String? currentSelectedProductToAddId;

    final List<_SizeInput> sizeInputs = [
      _SizeInput(name: 'Small'),
      _SizeInput(name: 'Large'),
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final controller = Get.find<ManagementController>();
          final nonDealItems = controller.menuItems.where((i) => !i.isDeal).toList();
          
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text('Add Menu Item', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: currentCategories.map((cat) {
                      return DropdownMenuItem(value: cat.id, child: Text(cat.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        _selectedCategoryId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name', 
                      hintText: 'e.g. Margherita Pizza',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Is Deal Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Is this a Deal / Combo?',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: isDeal,
                        onChanged: (val) {
                          setDialogState(() {
                            isDeal = val;
                            if (isDeal) {
                              hasMultipleSizes = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (!isDeal) ...[
                    // Sizing Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Has Multiple Sizes',
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: hasMultipleSizes,
                          onChanged: (val) {
                            setDialogState(() {
                              hasMultipleSizes = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (isDeal) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Deal Products / Combo Items',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    if (selectedDealProducts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No products added to this deal yet.',
                          style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ...selectedDealProducts.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final dealProd = entry.value;
                      final matchingItem = controller.menuItems.firstWhereOrNull((i) => i.id == dealProd['childItemId']);
                      final name = matchingItem?.name ?? 'Unknown Product';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(name, style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove, size: 16),
                                onPressed: () {
                                  setDialogState(() {
                                    if (dealProd['quantity'] > 1) {
                                      dealProd['quantity']--;
                                    }
                                  });
                                },
                              ),
                              Text('${dealProd['quantity']}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: () {
                                  setDialogState(() {
                                    dealProd['quantity']++;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                onPressed: () {
                                  setDialogState(() {
                                    selectedDealProducts.removeAt(idx);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                    if (nonDealItems.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: currentSelectedProductToAddId ?? nonDealItems.first.id,
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              decoration: const InputDecoration(
                                labelText: 'Select Product to Add',
                                isDense: true,
                              ),
                              items: nonDealItems.map((item) {
                                return DropdownMenuItem(
                                  value: item.id,
                                  child: Text(item.name, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setDialogState(() {
                                  currentSelectedProductToAddId = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final prodId = currentSelectedProductToAddId ?? nonDealItems.first.id;
                              final exists = selectedDealProducts.any((p) => p['childItemId'] == prodId);
                              if (!exists) {
                                setDialogState(() {
                                  selectedDealProducts.add({
                                    'childItemId': prodId,
                                    'quantity': 1,
                                  });
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ] else
                      Text('No products available to add to deal.', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 16),
                  ],

                  if (isDeal || !hasMultipleSizes) ...[
                    TextField(
                      controller: _itemPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Selling Price (Rs.)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _itemCostController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cost Price (Rs.)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _itemStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Initial Stock Qty',
                      ),
                    ),
                  ] else ...[
                    // Dynamic Sizes List
                    ...sizeInputs.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final input = entry.value;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Size Option #${idx + 1}',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                  ),
                                  if (sizeInputs.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppTheme.accentRose, size: 20),
                                      onPressed: () {
                                        setDialogState(() {
                                          input.dispose();
                                          sizeInputs.removeAt(idx);
                                        });
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: input.nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Size Name',
                                  hintText: 'e.g. Small, Medium, Large',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: input.priceController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Price (Rs.)',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: input.costController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Cost (Rs.)',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: input.stockController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Stock',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          sizeInputs.add(_SizeInput());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Size Option'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _itemImageController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      hintText: 'e.g. https://images.unsplash.com/photo-...',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  for (final input in sizeInputs) {
                    input.dispose();
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Cancel', style: GoogleFonts.outfit(color: Theme.of(context).primaryColor)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = _itemNameController.text.trim();
                  final imageUrl = _itemImageController.text.trim();

                  if (name.isNotEmpty && _selectedCategoryId != null) {
                    if (isDeal) {
                      final price = double.tryParse(_itemPriceController.text) ?? 0.0;
                      final cost = double.tryParse(_itemCostController.text) ?? 0.0;
                      final stock = int.tryParse(_itemStockController.text) ?? 0;

                      final newId = await controller.addMenuItem(
                        name: name,
                        categoryId: _selectedCategoryId!,
                        price: price,
                        costPrice: cost,
                        stock: stock,
                        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                        isDeal: true,
                      );
                      if (newId.isNotEmpty) {
                        await controller.saveDealItems(newId, selectedDealProducts);
                      }
                    } else if (hasMultipleSizes) {
                      for (final input in sizeInputs) {
                        final sizeName = input.nameController.text.trim();
                        final price = double.tryParse(input.priceController.text) ?? 0.0;
                        final cost = double.tryParse(input.costController.text) ?? 0.0;
                        final stock = int.tryParse(input.stockController.text) ?? 0;

                        if (sizeName.isNotEmpty) {
                          await controller.addMenuItem(
                            name: '$name ($sizeName)',
                            categoryId: _selectedCategoryId!,
                            price: price,
                            costPrice: cost,
                            stock: stock,
                            imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                          );
                        }
                      }
                    } else {
                      final price = double.tryParse(_itemPriceController.text) ?? 0.0;
                      final cost = double.tryParse(_itemCostController.text) ?? 0.0;
                      final stock = int.tryParse(_itemStockController.text) ?? 0;

                      await controller.addMenuItem(
                        name: name,
                        categoryId: _selectedCategoryId!,
                        price: price,
                        costPrice: cost,
                        stock: stock,
                        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                      );
                    }

                    _itemNameController.clear();
                    _itemPriceController.clear();
                    _itemCostController.clear();
                    _itemStockController.text = '0';
                    _itemImageController.clear();
                    for (final input in sizeInputs) {
                      input.dispose();
                    }
                    if (mounted) Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                child: const Text('Add Menu Item'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditItemDialog(LocalMenuItem item, List<LocalMenuCategory> currentCategories) async {
    final controller = Get.find<ManagementController>();
    
    // Parse base name
    final match = RegExp(r'^(.+?)\s*\(([^)]+)\)$').firstMatch(item.name);
    final baseName = match != null ? match.group(1)!.trim() : item.name;

    // Find all sized items matching this base name
    final existingSizedItems = controller.menuItems.where((i) {
      final itemMatch = RegExp(r'^(.+?)\s*\(([^)]+)\)$').firstMatch(i.name);
      final itemBaseName = itemMatch != null ? itemMatch.group(1)!.trim() : i.name;
      return itemBaseName.toLowerCase() == baseName.toLowerCase();
    }).toList();

    _itemNameController.text = baseName;
    _itemImageController.text = item.imageUrl ?? '';
    _selectedCategoryId = item.categoryId;

    bool hasMultipleSizes = existingSizedItems.length > 1 || (existingSizedItems.length == 1 && match != null);
    bool isDeal = item.isDeal;
    final List<Map<String, dynamic>> selectedDealProducts = [];
    String? currentSelectedProductToAddId;

    if (isDeal) {
      final existingDeals = await controller.getDealItems(item.id);
      for (final di in existingDeals) {
        selectedDealProducts.add({
          'childItemId': di.childItemId,
          'quantity': di.quantity,
        });
      }
    }

    final List<_SizeInput> sizeInputs = [];
    final List<String> deletedIds = [];

    if (hasMultipleSizes) {
      for (final sItem in existingSizedItems) {
        final sMatch = RegExp(r'\(([^)]+)\)$').firstMatch(sItem.name);
        final sizeName = sMatch != null ? sMatch.group(1)! : 'Standard';
        sizeInputs.add(_SizeInput(
          id: sItem.id,
          name: sizeName,
          price: sItem.price.toString(),
          cost: sItem.costPrice.toString(),
          stock: sItem.stockQuantity.toString(),
        ));
      }
    } else {
      _itemPriceController.text = item.price.toString();
      _itemCostController.text = item.costPrice.toString();
      _itemStockController.text = item.stockQuantity.toString();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final nonDealItems = controller.menuItems.where((i) => !i.isDeal && i.id != item.id).toList();

          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text('Edit Menu Item', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: currentCategories.map((cat) {
                      return DropdownMenuItem(value: cat.id, child: Text(cat.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        _selectedCategoryId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      hintText: 'e.g. Margherita Pizza',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Is Deal Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Is this a Deal / Combo?',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: isDeal,
                        onChanged: (val) {
                          setDialogState(() {
                            isDeal = val;
                            if (isDeal) {
                              hasMultipleSizes = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (!isDeal) ...[
                    // Has Multiple Sizes Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Has Multiple Sizes',
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: hasMultipleSizes,
                          onChanged: (val) {
                            setDialogState(() {
                              hasMultipleSizes = val;
                              if (hasMultipleSizes && sizeInputs.isEmpty) {
                                sizeInputs.add(_SizeInput(name: 'Small', price: _itemPriceController.text, cost: _itemCostController.text, stock: _itemStockController.text));
                                sizeInputs.add(_SizeInput(name: 'Large', price: _itemPriceController.text, cost: _itemCostController.text, stock: _itemStockController.text));
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (isDeal) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Deal Products / Combo Items',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    if (selectedDealProducts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No products added to this deal yet.',
                          style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ...selectedDealProducts.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final dealProd = entry.value;
                      final matchingItem = controller.menuItems.firstWhereOrNull((i) => i.id == dealProd['childItemId']);
                      final name = matchingItem?.name ?? 'Unknown Product';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(name, style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove, size: 16),
                                onPressed: () {
                                  setDialogState(() {
                                    if (dealProd['quantity'] > 1) {
                                      dealProd['quantity']--;
                                    }
                                  });
                                },
                              ),
                              Text('${dealProd['quantity']}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: () {
                                  setDialogState(() {
                                    dealProd['quantity']++;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                onPressed: () {
                                  setDialogState(() {
                                    selectedDealProducts.removeAt(idx);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                    if (nonDealItems.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: currentSelectedProductToAddId ?? nonDealItems.first.id,
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              decoration: const InputDecoration(
                                labelText: 'Select Product to Add',
                                isDense: true,
                              ),
                              items: nonDealItems.map((item) {
                                return DropdownMenuItem(
                                  value: item.id,
                                  child: Text(item.name, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setDialogState(() {
                                  currentSelectedProductToAddId = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final prodId = currentSelectedProductToAddId ?? nonDealItems.first.id;
                              final exists = selectedDealProducts.any((p) => p['childItemId'] == prodId);
                              if (!exists) {
                                setDialogState(() {
                                  selectedDealProducts.add({
                                    'childItemId': prodId,
                                    'quantity': 1,
                                  });
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ] else
                      Text('No products available to add to deal.', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 16),
                  ],

                  if (isDeal || !hasMultipleSizes) ...[
                    TextField(
                      controller: _itemPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Selling Price (Rs.)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _itemCostController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cost Price (Rs.)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _itemStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Qty',
                      ),
                    ),
                  ] else ...[
                    // Dynamic Sizes List
                    ...sizeInputs.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final input = entry.value;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Size Option #${idx + 1}',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                  ),
                                  if (sizeInputs.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppTheme.accentRose, size: 20),
                                      onPressed: () {
                                        setDialogState(() {
                                          if (input.id != null) {
                                            deletedIds.add(input.id!);
                                          }
                                          input.dispose();
                                          sizeInputs.removeAt(idx);
                                        });
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: input.nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Size Name',
                                  hintText: 'e.g. Small, Medium, Large',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: input.priceController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Price (Rs.)',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: input.costController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Cost (Rs.)',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: input.stockController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Stock',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          sizeInputs.add(_SizeInput());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Size Option'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _itemImageController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      hintText: 'e.g. https://images.unsplash.com/photo-...',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _itemNameController.clear();
                  _itemPriceController.clear();
                  _itemCostController.clear();
                  _itemStockController.text = '0';
                  _itemImageController.clear();
                  for (final input in sizeInputs) {
                    input.dispose();
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Cancel', style: GoogleFonts.outfit(color: Theme.of(context).primaryColor)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newBaseName = _itemNameController.text.trim();
                  final imageUrl = _itemImageController.text.trim();

                  if (newBaseName.isNotEmpty && _selectedCategoryId != null) {
                    // 1. Process deleted sizes
                    for (final delId in deletedIds) {
                      await controller.deleteMenuItem(delId);
                    }

                    if (isDeal) {
                      final price = double.tryParse(_itemPriceController.text) ?? 0.0;
                      final cost = double.tryParse(_itemCostController.text) ?? 0.0;
                      final stock = int.tryParse(_itemStockController.text) ?? 0;

                      // Update main item
                      await controller.updateMenuItem(
                        id: item.id,
                        name: newBaseName,
                        categoryId: _selectedCategoryId!,
                        price: price,
                        costPrice: cost,
                        stock: stock,
                        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                        isDeal: true,
                      );

                      // Save deal items
                      await controller.saveDealItems(item.id, selectedDealProducts);

                      // Delete any other sized variants that might exist
                      for (final sItem in existingSizedItems) {
                        if (sItem.id != item.id) {
                          await controller.deleteMenuItem(sItem.id);
                        }
                      }
                    } else if (hasMultipleSizes) {
                      // 2. Process size additions and updates
                      for (final input in sizeInputs) {
                        final sizeName = input.nameController.text.trim();
                        final price = double.tryParse(input.priceController.text) ?? 0.0;
                        final cost = double.tryParse(input.costController.text) ?? 0.0;
                        final stock = int.tryParse(input.stockController.text) ?? 0;

                        if (sizeName.isNotEmpty) {
                          if (input.id != null) {
                            // Update existing sized item
                            await controller.updateMenuItem(
                              id: input.id!,
                              name: '$newBaseName ($sizeName)',
                              categoryId: _selectedCategoryId!,
                              price: price,
                              costPrice: cost,
                              stock: stock,
                              imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                              isDeal: false,
                            );
                          } else {
                            // Insert new sized item
                            await controller.addMenuItem(
                              name: '$newBaseName ($sizeName)',
                              categoryId: _selectedCategoryId!,
                              price: price,
                              costPrice: cost,
                              stock: stock,
                              imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                              isDeal: false,
                            );
                          }
                        }
                      }

                      // If main item is no longer matching, and is not inside sizeInputs list, delete it
                      final mainExistsInSizes = sizeInputs.any((si) => si.id == item.id);
                      if (!mainExistsInSizes) {
                        await controller.deleteMenuItem(item.id);
                      }
                    } else {
                      // If turned off sizes, update the original item and delete any other size variants
                      final price = double.tryParse(_itemPriceController.text) ?? 0.0;
                      final cost = double.tryParse(_itemCostController.text) ?? 0.0;
                      final stock = int.tryParse(_itemStockController.text) ?? 0;

                      // Update main item
                      await controller.updateMenuItem(
                        id: item.id,
                        name: newBaseName,
                        categoryId: _selectedCategoryId!,
                        price: price,
                        costPrice: cost,
                        stock: stock,
                        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                        isDeal: false,
                      );

                      // Delete other sized variants
                      for (final sItem in existingSizedItems) {
                        if (sItem.id != item.id) {
                          await controller.deleteMenuItem(sItem.id);
                        }
                      }

                      // Delete deal items if it used to be a deal
                      await controller.saveDealItems(item.id, []);
                    }

                    _itemNameController.clear();
                    _itemPriceController.clear();
                    _itemCostController.clear();
                    _itemStockController.text = '0';
                    _itemImageController.clear();
                    for (final input in sizeInputs) {
                      input.dispose();
                    }
                    if (mounted) Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SizeInput {
  String? id;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController costController;
  final TextEditingController stockController;

  _SizeInput({
    this.id,
    String name = '',
    String price = '',
    String cost = '',
    String stock = '0',
  })  : nameController = TextEditingController(text: name),
        priceController = TextEditingController(text: price),
        costController = TextEditingController(text: cost),
        stockController = TextEditingController(text: stock);

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    costController.dispose();
    stockController.dispose();
  }
}

