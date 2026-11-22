
import 'package:flutter/material.dart';
import '../stock/stock_data.dart';
import '../stock/add_batch_screen.dart';
import '../stock/consume_stock_screen.dart';
import 'product_info.dart';
import 'add_edit_product_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductInfo product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  double get totalQuantity =>
      StockStore.availableQuantity(widget.product.name);

  List<Batch> get orderedBatches {
    final batches = StockStore.batchesFor(widget.product.name);

    batches.sort(
          (a, b) => a.daysLeft.compareTo(b.daysLeft),
    );

    return batches;
  }

  Future<void> addBatch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBatchScreen(
          productName: widget.product.name,
          unit: widget.product.unit,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> consumeStock() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsumeStockScreen(
          productName: widget.product.name,
          unit: widget.product.unit,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }
  Future<void> editProduct() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen(
          product: widget.product,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  String formatQuantity(double quantity) {
    return StockUtils.formatQty(quantity);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: 24,
          ),
          children: [
            Text(
              'S06 • Inventory',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            _buildProductSummary(colors),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: editProduct,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Product'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Expiration batches',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            if (orderedBatches.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 16),
                child: Center(
                  child: Text('No batches available.'),
                ),
              ),
            for (int i = 0; i < orderedBatches.length; i++)
              _buildBatchCard(
                orderedBatches[i],
                i,
                colors,
              ),
            const SizedBox(height: 12),
            SizedBox(
              height: 55,
              child: FilledButton(
                onPressed: consumeStock,
                child: const Text('Consume Stock'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 55,
              child: OutlinedButton.icon(
                onPressed: addBatch,
                icon: const Icon(Icons.add),
                label: const Text('Add Batch'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSummary(ColorScheme colors) {
    final batches = orderedBatches;

    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  '${formatQuantity(totalQuantity)} ${widget.product.unit}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Category: ${widget.product.category}'),
            const SizedBox(height: 5),
            Text('Storage: ${widget.product.storageLocation}'),
            const SizedBox(height: 5),
            Text(
              'Minimum stock: '
                  '${formatQuantity(widget.product.minimumStock)} '
                  '${widget.product.unit}',
            ),
            const SizedBox(height: 16),
            Text(
              '${batches.length} batches available',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (totalQuantity < widget.product.minimumStock) ...[
              const SizedBox(height: 8),
              Text(
                'Low stock',
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBatchCard(
      Batch batch,
      int index,
      ColorScheme colors,
      ) {
    final expiringSoon = batch.daysLeft <= 2;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: expiringSoon
          ? colors.errorContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    batch.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${formatQuantity(batch.quantity)} ${batch.unit}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              batch.isExpired
                  ? 'Expired'
                  : batch.daysLeft == 0
                  ? 'Expires today'
                  : 'Expires in ${batch.daysLeft} days',
            ),
            const SizedBox(height: 5),
            Text(
              'Expiry date: ${StockUtils.formatDate(batch.expiryDate)}',
            ),
            const SizedBox(height: 5),
            Text(
              'Received: ${StockUtils.formatDate(batch.receivedDate)}',
            ),
            const SizedBox(height: 12),
            Text(
              'Priority ${index + 1} • FEFO',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
