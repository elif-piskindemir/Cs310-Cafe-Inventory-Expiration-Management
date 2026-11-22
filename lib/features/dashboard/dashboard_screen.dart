
import 'package:flutter/material.dart';

import '../stock/stock_data.dart';
import '../inventory/product_info.dart';
import 'stock_watchlist_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = ProductCatalog.products;

    final expiringSoon = StockStore.batches.where(
          (b) =>
      b.quantity > 0 &&
          b.daysLeft >= 0 &&
          b.daysLeft <= 2,
    ).toList();

    final expired = StockStore.batches.where(
          (b) => b.quantity > 0 && b.isExpired,
    ).toList();

    final lowStock = products.where(
          (p) =>
      StockStore.availableQuantity(p.name) <
          p.minimumStock,
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TOTAL PRODUCTS
          Card(
            child: ListTile(
              title: const Text('Total Products'),
              trailing: Text('${products.length}'),
            ),
          ),

          // EXPIRING SOON
          Card(
            child: ListTile(
              title: const Text('Expiring Soon'),
              trailing: Text('${expiringSoon.length}'),
            ),
          ),

          // EXPIRED BATCHES
          Card(
            child: ListTile(
              title: const Text('Expired Batches'),
              trailing: Text('${expired.length}'),
            ),
          ),

          // LOW STOCK PRODUCTS
          Card(
            child: ListTile(
              title: const Text('Low Stock Products'),
              trailing: Text('${lowStock.length}'),
            ),
          ),

          const SizedBox(height: 24),

          // LOCAL IMAGE
          const Text(
            'Our Cafe',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/cafe_banner.jpg',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 150,
                  child: Center(
                    child: Text('Local image could not be loaded'),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // NETWORK IMAGE
          const Text(
            'Coffee Inspiration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) {
                  return child;
                }

                return const SizedBox(
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 150,
                  child: Center(
                    child: Text('Network image could not be loaded'),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // STOCK WATCHLIST
          const StockWatchlistSection(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
