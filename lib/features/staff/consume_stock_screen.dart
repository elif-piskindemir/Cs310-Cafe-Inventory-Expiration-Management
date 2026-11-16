
import 'package:flutter/material.dart';


class Batch {
  final String id;
  final String label;
  final double quantity;
  final int daysLeft;

  const Batch({
    required this.id,
    required this.label,
    required this.quantity,
    required this.daysLeft,
  });

  bool get isExpired => daysLeft < 0;
}


class Deduction {
  final Batch batch;
  final double amount;

  const Deduction({required this.batch, required this.amount});
}


class StockUtils {
  static String formatQty(double q) {
    if (q == q.roundToDouble()) {
      return q.toInt().toString();
    }
    return q.toStringAsFixed(1);
  }

  static double round2(double v) => double.parse(v.toStringAsFixed(2));

  static String daysText(int days) {
    if (days == 1) {
      return '1 day remaining';
    }
    return '$days days remaining';
  }


  static List<Deduction> calculate(
      List<Batch> batches,
      double quantity,
      String? firstBatchId,
      ) {
    final available = batches.where((b) => !b.isExpired).toList();
    available.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

    if (firstBatchId != null) {
      final chosen = available.where((b) => b.id == firstBatchId).toList();
      if (chosen.isNotEmpty) {
        available.remove(chosen.first);
        available.insert(0, chosen.first);
      }
    }

    final result = <Deduction>[];
    double remaining = quantity;

    for (final batch in available) {
      if (remaining <= 0) break;
      final take = remaining < batch.quantity ? remaining : batch.quantity;
      result.add(Deduction(batch: batch, amount: take));
      remaining -= take;
    }
    return result;
  }
}


class ConsumeStockScreen extends StatefulWidget {
  const ConsumeStockScreen({super.key});

  @override
  State<ConsumeStockScreen> createState() => _ConsumeStockScreenState();
}

class _ConsumeStockScreenState extends State<ConsumeStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '6');

  // Sample data
  final String productName = 'Whole milk';
  final String unit = 'L';
  List<Batch> batches = const [
    Batch(id: 'A', label: 'Batch A', quantity: 5, daysLeft: 1),
    Batch(id: 'B', label: 'Batch B', quantity: 7, daysLeft: 7),
    Batch(id: 'C', label: 'Batch C', quantity: 2, daysLeft: -1), // expired
  ];

  bool manualChoice = false;
  String? selectedBatchId;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  List<Batch> get availableBatches {
    final list = batches.where((b) => !b.isExpired).toList();
    list.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return list;
  }

  List<Batch> get expiredBatches => batches.where((b) => b.isExpired).toList();

  double get availableQty =>
      availableBatches.fold<double>(0, (sum, b) => sum + b.quantity);


  double get enteredQty =>
      double.tryParse(_quantityController.text.trim()) ?? 0;

  List<Deduction> get deductions {
    final qty = enteredQty;
    if (qty <= 0 || qty > availableQty) {
      return [];
    }
    return StockUtils.calculate(
      batches,
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
    '${d.batch.label} −${StockUtils.formatQty(d.amount)} $unit')
        .join(', ');

    setState(() {
      batches = batches
          .map((b) {
        double taken = 0;
        for (final d in used) {
          if (d.batch.id == b.id) {
            taken = d.amount;
          }
        }
        return Batch(
          id: b.id,
          label: b.label,
          quantity: StockUtils.round2(b.quantity - taken),
          daysLeft: b.daysLeft,
        );
      })
          .where((b) => b.isExpired || b.quantity > 0) // drop
          .toList();

      _quantityController.clear();
      manualChoice = false;
      selectedBatchId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Consumed ${StockUtils.formatQty(consumed)} $unit of $productName\n$summary',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final list = deductions;
    final firstExpiryDays =
    availableBatches.isEmpty ? 0 : availableBatches.first.daysLeft;

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

                //Product summary (in cAWse to make difference need to remember :)
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
                        '$productName   ${StockUtils.formatQty(availableQty)} $unit available',
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


                TextFormField(
                  controller: _quantityController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Quantity to consume',
                    suffixText: unit,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {}); // rebuild so the deduction updates live
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
                      return 'Only ${StockUtils.formatQty(availableQty)} $unit available';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                const Text(
                  'Automatic batch deduction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (availableQty == 0)
                  Text('No stock left for $productName.')
                else if (list.isEmpty)
                  const Text('Enter a valid quantity to see the deduction.'),
                for (int i = 0; i < list.length; i++)
                  DeductionCard(
                    order: i + 1,
                    deduction: list[i],
                    unit: unit,
                    expiresFirst: list[i].batch.daysLeft == firstExpiryDays,
                  ),
                const SizedBox(height: 8),

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
                if (manualChoice) buildManualPicker(colors),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: confirmConsumption, // no () -> pass the function
                  child: const Text('Confirm Consumption'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CafeBottomBar(selected: 'Inventory'),
    );
  }

  Widget buildManualPicker(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 4),
          child: Text('Tap a batch to consume it first:'),
        ),
        for (final batch in availableBatches)
          ListTile(
            leading: Icon(
              selectedBatchId == batch.id
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: colors.primary,
            ),
            title: Text(
                '${batch.label} • ${StockUtils.formatQty(batch.quantity)} $unit'),
            subtitle: Text(StockUtils.daysText(batch.daysLeft)),
            onTap: () {
              setState(() {
                selectedBatchId = batch.id;
              });
            },
          ),
      ],
    );
  }
}


class DeductionCard extends StatelessWidget {
  final int order;
  final Deduction deduction;
  final String unit;
  final bool expiresFirst;

  const DeductionCard({
    super.key,
    required this.order,
    required this.deduction,
    required this.unit,
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
            '$order. ${batch.label}   −${StockUtils.formatQty(deduction.amount)} $unit',
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

class CafeBottomBar extends StatelessWidget {
  final String selected;

  const CafeBottomBar({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomTab(label: 'Home', icon: Icons.home_outlined, selected: selected == 'Home'),
            BottomTab(label: 'Inventory', icon: Icons.inventory_2_outlined, selected: selected == 'Inventory'),
            BottomTab(label: 'Alerts', icon: Icons.notifications_outlined, selected: selected == 'Alerts'),
            BottomTab(label: 'More', icon: Icons.more_horiz, selected: selected == 'More'),
          ],
        ),
      ),
    );
  }
}

class BottomTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;

  const BottomTab({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? colors.primaryContainer : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? colors.onPrimaryContainer : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? colors.onPrimaryContainer : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}