
import 'package:flutter/material.dart';
import '../stock/stock_data.dart';
import '../inventory/product_info.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = ProductCatalog.products;

    final expiringSoon = StockStore.batches.where(
          (b) => b.quantity > 0 &&
          b.daysLeft >= 0 &&
          b.daysLeft <= 2,
    ).toList();

    final expired = StockStore.batches.where(
          (b) => b.quantity > 0 && b.isExpired,
    ).toList();

    final lowStock = products.where(
          (p) => StockStore.availableQuantity(p.name) <
          p.minimumStock,
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Total Products'),
              trailing: Text('${products.length}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Expiring Soon'),
              trailing: Text('${expiringSoon.length}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Expired Batches'),
              trailing: Text('${expired.length}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Low Stock Products'),
              trailing: Text('${lowStock.length}'),
            ),
          ),
        ],
      ),
    );
  }
}
