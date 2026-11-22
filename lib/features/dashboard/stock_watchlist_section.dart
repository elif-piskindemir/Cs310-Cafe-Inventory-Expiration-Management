
import 'package:flutter/material.dart';

// Product model
class WatchlistProduct {
  final String name;
  final String note;

  const WatchlistProduct({
    required this.name,
    required this.note,
  });
}

class StockWatchlistSection extends StatefulWidget {
  const StockWatchlistSection({super.key});

  @override
  State<StockWatchlistSection> createState() =>
      _StockWatchlistSectionState();
}

class _StockWatchlistSectionState
    extends State<StockWatchlistSection> {

  final List<WatchlistProduct> products = [
    const WatchlistProduct(
      name: 'Milk',
      note: 'Check expiration date',
    ),
    const WatchlistProduct(
      name: 'Coffee Beans',
      note: 'Check remaining stock',
    ),
    const WatchlistProduct(
      name: 'Vanilla Syrup',
      note: 'Check next delivery',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stock Watchlist',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        if (products.isEmpty)
          const Text('No products in watchlist.'),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            return Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text(product.name),
                subtitle: Text(product.note),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove product',
                  onPressed: () {
                    setState(() {
                      products.removeAt(index);
                    });

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          '${product.name} removed',
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
