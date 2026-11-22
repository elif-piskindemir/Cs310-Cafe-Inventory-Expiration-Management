import 'package:flutter/material.dart';
import '../stock/stock_data.dart';
import 'product_info.dart';
import 'product_details_screen.dart';
import 'add_edit_product_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String searchQuery = '';
  String selectedFilter = 'All';
  Future<void> openAddProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditProductScreen(),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> openProduct(ProductInfo product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          product: product,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  List<ProductInfo> get filteredProducts {
    return ProductCatalog.products.where((product) {
      final matchesSearch = product.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchesFilter = selectedFilter == 'All' ||
          product.storageLocation == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: 20,
          ),
          children: [
            Text(
              'Search inventory',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: [
                _buildFilter('All'),
                _buildFilter('Refrigerator'),
                _buildFilter('Freezer'),
                _buildFilter('Shelf'),
              ],
            ),
            const SizedBox(height: 20),
            for (final product in filteredProducts)
              _buildProductCard(product, colors),
            if (filteredProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: Text('No products found.'),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: openAddProduct,
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter(String title) {
    final selected = selectedFilter == title;
    final colors = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(title),
      selected: selected,
      onSelected: (value) {
        setState(() {
          selectedFilter = title;
        });
      },
      selectedColor: colors.primaryContainer,
    );
  }

  Widget _buildProductCard(
      ProductInfo product,
      ColorScheme colors,
      ) {
    final quantity = StockStore.availableQuantity(product.name);
    final batches = StockStore.batchesFor(product.name);
    final isLowStock = quantity < product.minimumStock;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${StockUtils.formatQty(quantity)} ${product.unit}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${product.category} • ${product.storageLocation}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '${batches.length} batches',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (isLowStock) ...[
              const SizedBox(height: 8),
              Text(
                'Low stock',
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => openProduct(product),
                child: const Text('Open product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
