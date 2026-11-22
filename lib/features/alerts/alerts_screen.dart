
import 'package:flutter/material.dart';

import '../stock/stock_data.dart';
import '../inventory/product_info.dart';
import '../inventory/product_details_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  Future<void> openProduct(String productName) async {
    final matches = ProductCatalog.products.where(
          (p) => p.name == productName,
    ).toList();

    if (matches.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          product: matches.first,
        ),
      ),
    );

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final batches = StockStore.batches.where(
          (b) => b.quantity > 0 && b.daysLeft <= 2,
    ).toList();

    final lowStock = ProductCatalog.products.where(
          (p) => StockStore.availableQuantity(p.name) <
          p.minimumStock,
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: ListView(
        children: [
          for (final batch in batches)
            ListTile(
              leading: Icon(
                batch.isExpired
                    ? Icons.error_outline
                    : Icons.warning_amber_outlined,
              ),
              title: Text(batch.productName),
              subtitle: Text(
                batch.isExpired
                    ? 'Expired'
                    : StockUtils.daysText(batch.daysLeft),
              ),
              onTap: () => openProduct(batch.productName),
            ),

          for (final product in lowStock)
            ListTile(
              leading: const Icon(Icons.inventory_outlined),
              title: Text(product.name),
              subtitle: const Text('Low stock'),
              onTap: () => openProduct(product.name),
            ),
        ],
      ),
    );
  }
}
