import 'package:flutter/material.dart';



class Batch {
  final String id;
  final String label;
  final String productName;
  final String unit;
  final double quantity;
  final DateTime expiryDate;
  final DateTime receivedDate;
  final String location;

  const Batch({
    required this.id,
    required this.label,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.expiryDate,
    required this.receivedDate,
    required this.location,
  });

  int get daysLeft => StockUtils.daysUntil(expiryDate);

  bool get isExpired => daysLeft < 0;

  Batch withQuantity(double newQuantity) {
    return Batch(
      id: id,
      label: label,
      productName: productName,
      unit: unit,
      quantity: newQuantity,
      expiryDate: expiryDate,
      receivedDate: receivedDate,
      location: location,
    );
  }
}

class Deduction {
  final Batch batch;
  final double amount;

  const Deduction({required this.batch, required this.amount});
}

class StockTransaction {
  static const String addBatch = 'Add batch';
  static const String consume = 'Consume';
  static const String waste = 'Waste';
  static const String adjust = 'Adjust';

  final String id;
  final String type;
  final String productName;
  final String batchLabel;
  final String unit;

  final double quantityChange;
  final String note;
  final DateTime date;

  const StockTransaction({
    required this.id,
    required this.type,
    required this.productName,
    required this.batchLabel,
    required this.unit,
    required this.quantityChange,
    required this.note,
    required this.date,
  });
}

// UTILS

class StockUtils {
  static String formatQty(double q) {
    if (q == q.roundToDouble()) {
      return q.toInt().toString();
    }
    return q.toStringAsFixed(1);
  }

  static double round2(double v) => double.parse(v.toStringAsFixed(2));

  static String formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  static String formatDateTime(DateTime d) {
    final minute = d.minute < 10 ? '0${d.minute}' : '${d.minute}';
    return '${formatDate(d)} ${d.hour}:$minute';
  }

  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    return day.difference(today).inDays;
  }

  static String daysText(int days) {
    if (days < 0) return 'Expired';
    if (days == 0) return 'Expires today';
    if (days == 1) return '1 day remaining';
    return '$days days remaining';
  }

  static List<Deduction> calculateFefo(
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
      remaining = round2(remaining - take);
    }
    return result;
  }
}

// SHARED DATA

class StockStore {
  static final DateTime _now = DateTime.now();
  static final DateTime _today = DateTime(_now.year, _now.month, _now.day);

  static final List<Batch> batches = [
    Batch(
      id: 'b1',
      label: 'Batch A',
      productName: 'Whole milk',
      unit: 'L',
      quantity: 5,
      expiryDate: _today.add(const Duration(days: 1)),
      receivedDate: _today.subtract(const Duration(days: 5)),
      location: 'Refrigerator',
    ),
    Batch(
      id: 'b2',
      label: 'Batch B',
      productName: 'Whole milk',
      unit: 'L',
      quantity: 7,
      expiryDate: _today.add(const Duration(days: 7)),
      receivedDate: _today.subtract(const Duration(days: 4)),
      location: 'Refrigerator',
    ),
    Batch(
      id: 'b3',
      label: 'Batch C',
      productName: 'Whole milk',
      unit: 'L',
      quantity: 2,
      expiryDate: _today.subtract(const Duration(days: 1)),
      receivedDate: _today.subtract(const Duration(days: 9)),
      location: 'Refrigerator',
    ),
  ];

  static final List<StockTransaction> transactions = [
    StockTransaction(
      id: 't1',
      type: StockTransaction.addBatch,
      productName: 'Whole milk',
      batchLabel: 'Batch C',
      unit: 'L',
      quantityChange: 2,
      note: 'Received • Refrigerator',
      date: _today.subtract(const Duration(days: 9)).add(const Duration(hours: 9, minutes: 30)),
    ),
    StockTransaction(
      id: 't2',
      type: StockTransaction.addBatch,
      productName: 'Whole milk',
      batchLabel: 'Batch A',
      unit: 'L',
      quantityChange: 5,
      note: 'Received • Refrigerator',
      date: _today.subtract(const Duration(days: 5)).add(const Duration(hours: 10, minutes: 15)),
    ),
    StockTransaction(
      id: 't3',
      type: StockTransaction.addBatch,
      productName: 'Whole milk',
      batchLabel: 'Batch B',
      unit: 'L',
      quantityChange: 7,
      note: 'Received • Refrigerator',
      date: _today.subtract(const Duration(days: 4)).add(const Duration(hours: 8, minutes: 45)),
    ),
  ];

  static int _nextBatchNumber = 4;
  static int _nextTransactionNumber = 4;
  static const String _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  // Reading

  static List<Batch> batchesFor(String productName) {
    final list = batches.where((b) => b.productName == productName).toList();
    list.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return list;
  }

  static List<Batch> usableBatchesFor(String productName) {
    return batchesFor(productName).where((b) => !b.isExpired).toList();
  }

  static double availableQuantity(String productName) {
    return usableBatchesFor(productName)
        .fold<double>(0, (sum, b) => sum + b.quantity);
  }

  static List<StockTransaction> history() {
    final list = [...transactions];
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // Changing

  static Batch addBatch({
    required String productName,
    required String unit,
    required double quantity,
    required DateTime expiryDate,
    required DateTime receivedDate,
    required String location,
  }) {
    final batch = Batch(
      id: 'b$_nextBatchNumber',
      label: 'Batch ${_letters[(_nextBatchNumber - 1) % _letters.length]}',
      productName: productName,
      unit: unit,
      quantity: quantity,
      expiryDate: expiryDate,
      receivedDate: receivedDate,
      location: location,
    );
    _nextBatchNumber++;
    batches.add(batch);

    _record(
      type: StockTransaction.addBatch,
      batch: batch,
      change: quantity,
      note: 'Received • $location',
    );
    return batch;
  }

  static void consume(List<Deduction> deductions, {required bool manual}) {
    for (final d in deductions) {
      _setQuantity(d.batch.id, d.batch.quantity - d.amount);
      _record(
        type: StockTransaction.consume,
        batch: d.batch,
        change: -d.amount,
        note: manual ? 'Manual batch choice' : 'FEFO automatic deduction',
      );
    }
  }

  static void waste(Batch batch, double amount, String reason) {
    _setQuantity(batch.id, batch.quantity - amount);
    _record(
      type: StockTransaction.waste,
      batch: batch,
      change: -amount,
      note: reason,
    );
  }

  static void adjust(Batch batch, double countedQuantity, String reason) {
    final change = StockUtils.round2(countedQuantity - batch.quantity);
    _setQuantity(batch.id, countedQuantity);
    _record(
      type: StockTransaction.adjust,
      batch: batch,
      change: change,
      note: reason,
    );
  }

  // Private helpers

  static void _setQuantity(String batchId, double newQuantity) {
    final rounded = StockUtils.round2(newQuantity);
    for (int i = 0; i < batches.length; i++) {
      if (batches[i].id == batchId) {
        if (rounded <= 0) {
          batches.removeAt(i);
        } else {
          batches[i] = batches[i].withQuantity(rounded);
        }
        return;
      }
    }
  }

  static void _record({
    required String type,
    required Batch batch,
    required double change,
    required String note,
  }) {
    transactions.add(
      StockTransaction(
        id: 't$_nextTransactionNumber',
        type: type,
        productName: batch.productName,
        batchLabel: batch.label,
        unit: batch.unit,
        quantityChange: StockUtils.round2(change),
        note: note,
        date: DateTime.now(),
      ),
    );
    _nextTransactionNumber++;
  }
}

// SHARED WIDGET

class BatchPicker extends StatelessWidget {
  final List<Batch> batches;
  final String? selectedBatchId;
  final void Function(String batchId) onSelected;

  const BatchPicker({
    super.key,
    required this.batches,
    required this.selectedBatchId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (batches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No batches available.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final batch in batches)
          Card(
            color: selectedBatchId == batch.id ? colors.primaryContainer : null,
            child: ListTile(
              leading: Icon(
                selectedBatchId == batch.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: colors.primary,
              ),
              title: Text(
                '${batch.label} • ${StockUtils.formatQty(batch.quantity)} ${batch.unit}',
              ),
              subtitle: Text(
                '${StockUtils.daysText(batch.daysLeft)} • ${batch.location}',
                style: TextStyle(color: batch.isExpired ? colors.error : null),
              ),
              onTap: () => onSelected(batch.id),
            ),
          ),
      ],
    );
  }
}
