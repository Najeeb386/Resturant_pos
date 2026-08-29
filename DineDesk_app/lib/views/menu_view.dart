import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: provider.menuItems.length,
        itemBuilder: (context, index) {
          final item = provider.menuItems[index];
          bool hasVars = item.variants.isNotEmpty;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 44,
                  height: 44,
                  color: Colors.deepOrange.shade50,
                  child: item.image != null && item.image!.isNotEmpty
                      ? Image.network(
                          ApiService.getImageUrl(item.image),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(child: Text('🍽️', style: TextStyle(fontSize: 20))),
                        )
                      : const Center(child: Text('🍽️', style: TextStyle(fontSize: 20))),
                ),
              ),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                hasVars
                    ? 'Sizes: ${item.variants.map((v) => v.name).join(", ")}'
                    : 'Stock: ${item.stockQuantity}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs ${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepOrange),
                  ),
                  if (hasVars)
                    Text(
                      '${item.variants.length} Sizes',
                      style: TextStyle(fontSize: 10, color: Colors.purple.shade700, fontWeight: FontWeight.bold),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
