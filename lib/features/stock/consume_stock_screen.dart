import 'package:flutter/material.dart';

import 'stock_data.dart';
import 'transaction_history_screen.dart';

// S09 CONSUME STOCK
class ConsumeStockScreen extends StatefulWidget {
  final String productName;
  final String unit;

  const ConsumeStockScreen({
    super.key,
    this.productName = 'Whole milk',
    this.unit = 'L',
  });

  @override
  State<ConsumeStockScreen> createState() => _ConsumeStockScreenState();
}

class _ConsumeStockScreenState extends State<ConsumeStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  bool manualChoice = false;
  String? selectedBatchId;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  List<Batch> get usableBatches =>
      StockStore.usableBatchesFor(widget.productName);

  List<Batch> get expiredBatches => StockStore.batchesFor(widget.productName)
      .where((b) => b.isExpired)
      .toList();

  double get availableQty => StockStore.availableQuantity(widget.productName);

  double get enteredQty =>
      double.tryParse(_quantityController.text.trim()) ?? 0;

  List<Deduction> get deductions {
    final qty = enteredQty;
    if (qty <= 0 || qty > availableQty) {
      return [];
    }
    return StockUtils.calculateFefo(
      usableBatches,
      qty,
      manualChoice ? selectedBatchId : null,
    );
  }

  void confirmConsumption() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final used = deductions;
    final consumed = enteredQty;
    final summary = used
        .map((d) =>
            '${d.batch.label} −${StockUtils.formatQty(d.amount)} ${widget.unit}')
        .join(', ');

    setState(() {
      StockStore.consume(used, manual: manualChoice);
      _quantityController.clear();
      manualChoice = false;
      selectedBatchId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Consumed ${StockUtils.formatQty(consumed)} ${widget.unit} of ${widget.productName}\n$summary',
        ),
      ),
    );
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TransactionHistoryScreen(productName: widget.productName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final list = deductions;
    final usable = usableBatches;
    final firstExpiryDays = usable.isEmpty ? 0 : usable.first.daysLeft;

    return Scaffold(
      appBar: AppBar(title: const Text('Consume Stock')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('S09 • Operations', style: TextStyle(color: colors.primary)),
                const SizedBox(height: 12),

                // Product summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.productName}   ${StockUtils.formatQty(availableQty)} ${widget.unit} available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'FEFO rule is applied to non-expired batches',
                        style: TextStyle(color: colors.onPrimaryContainer),
                      ),
                      for (final b in expiredBatches)
                        Text(
                          '${b.label} is expired and will not be used',
                          style: TextStyle(color: colors.error),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quantity input
                TextFormField(
                  controller: _quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Quantity to consume',
                    suffixText: widget.unit,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a quantity';
                    }
                    final qty = double.tryParse(value.trim());
                    if (qty == null) {
                      return 'Enter a valid number';
                    }
                    if (qty <= 0) {
                      return 'Quantity must be greater than 0';
                    }
                    if (qty > availableQty) {
                      return 'Only ${StockUtils.formatQty(availableQty)} ${widget.unit} available';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Automatic batch deduction
                const Text(
                  'Automatic batch deduction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (availableQty == 0)
                  Text('No stock left for ${widget.productName}.')
                else if (list.isEmpty)
                  const Text('Enter a valid quantity to see the deduction.'),
                for (int i = 0; i < list.length; i++)
                  DeductionCard(
                    order: i + 1,
                    deduction: list[i],
                    expiresFirst: list[i].batch.daysLeft == firstExpiryDays,
                  ),
                const SizedBox(height: 8),

                // Manual override
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: manualChoice,
                        onChanged: (bool? value) {
                          setState(() {
                            manualChoice = value ?? false;
                            if (!manualChoice) {
                              selectedBatchId = null;
                            }
                          });
                        },
                      ),
                      const Expanded(
                        child: Text('Manually choose a different batch'),
                      ),
                    ],
                  ),
                ),
                if (manualChoice) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 4),
                    child: Text('Tap a batch to consume it first:'),
                  ),
                  BatchPicker(
                    batches: usable,
                    selectedBatchId: selectedBatchId,
                    onSelected: (id) {
                      setState(() {
                        selectedBatchId = id;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 20),

                // Confirm
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: confirmConsumption,
                  child: const Text('Confirm Consumption'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: openHistory,
                  child: const Text('View transaction history'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// WIDGETS
class DeductionCard extends StatelessWidget {
  final int order;
  final Deduction deduction;
  final bool expiresFirst;

  const DeductionCard({
    super.key,
    required this.order,
    required this.deduction,
    required this.expiresFirst,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isFirst = order == 1;
    final batch = deduction.batch;
    final expiryLabel = expiresFirst ? 'Expires first' : 'Expires later';
    final roleLabel = isFirst ? 'Consumed first' : 'Remainder';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFirst ? Colors.amber.shade50 : Colors.white,
        border: Border.all(
          color: isFirst ? Colors.amber.shade200 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$order. ${batch.label}   −${StockUtils.formatQty(deduction.amount)} ${batch.unit}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '$expiryLabel • ${StockUtils.daysText(batch.daysLeft)}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            roleLabel,
            style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
