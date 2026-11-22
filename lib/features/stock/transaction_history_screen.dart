import 'package:flutter/material.dart';

import 'stock_data.dart';

// S11 TRANSACTION HISTORY
class TransactionHistoryScreen extends StatefulWidget {
  final String? productName;

  const TransactionHistoryScreen({super.key, this.productName});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  static const String all = 'All';
  static const List<String> filters = [
    all,
    StockTransaction.addBatch,
    StockTransaction.consume,
    StockTransaction.waste,
    StockTransaction.adjust,
  ];

  String selectedFilter = all;

  List<StockTransaction> get visibleTransactions {
    return StockStore.history()
        .where((t) =>
            widget.productName == null || t.productName == widget.productName)
        .where((t) => selectedFilter == all || t.type == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = visibleTransactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('S11 • Operations', style: TextStyle(color: colors.primary)),
                  const SizedBox(height: 4),
                  Text(
                    widget.productName ?? 'All products',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Filter buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final f in filters)
                        FilterButton(
                          label: f,
                          selected: selectedFilter == f,
                          onPressed: () {
                            setState(() {
                              selectedFilter = f;
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No transactions yet.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return TransactionTile(transaction: items[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGETS
class TransactionTile extends StatelessWidget {
  final StockTransaction transaction;

  const TransactionTile({super.key, required this.transaction});

  IconData iconFor(String type) {
    if (type == StockTransaction.addBatch) return Icons.add_box_outlined;
    if (type == StockTransaction.consume) return Icons.local_cafe_outlined;
    if (type == StockTransaction.waste) return Icons.delete_outline;
    return Icons.tune;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = transaction;
    final isIncoming = t.quantityChange > 0;
    final sign = isIncoming ? '+' : '−';
    final amount = StockUtils.formatQty(t.quantityChange.abs());

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(iconFor(t.type), color: colors.onPrimaryContainer),
        ),
        title: Text('${t.type} • ${t.batchLabel}'),
        subtitle: Text(
          '${t.productName} • ${t.note}\n${StockUtils.formatDateTime(t.date)}',
        ),
        isThreeLine: true,
        trailing: Text(
          '$sign$amount ${t.unit}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isIncoming ? Colors.green.shade700 : colors.error,
          ),
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: selected ? colors.primary : colors.surfaceContainerHighest,
        foregroundColor: selected ? colors.onPrimary : colors.onSurface,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
