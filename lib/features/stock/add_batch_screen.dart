import 'package:flutter/material.dart';

import 'stock_data.dart';

// S08 ADD BATCH
class AddBatchScreen extends StatefulWidget {
  final String productName;
  final String unit;

  const AddBatchScreen({
    super.key,
    this.productName = 'Whole milk',
    this.unit = 'L',
  });

  @override
  State<AddBatchScreen> createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends State<AddBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController(text: 'Refrigerator');
  final _expiryController = TextEditingController();
  final _receivedController = TextEditingController();

  DateTime? expiryDate;
  DateTime receivedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _receivedController.text = StockUtils.formatDate(receivedDate);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _locationController.dispose();
    _expiryController.dispose();
    _receivedController.dispose();
    super.dispose();
  }

  Future<void> pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: expiryDate ?? now.add(const Duration(days: 7)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked == null) return;

    setState(() {
      expiryDate = picked;
      _expiryController.text = StockUtils.formatDate(picked);
    });
  }

  Future<void> pickReceivedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: receivedDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (picked == null) return;

    setState(() {
      receivedDate = picked;
      _receivedController.text = StockUtils.formatDate(picked);
    });
  }

  bool isBeforeDay(DateTime a, DateTime b) {
    final dayA = DateTime(a.year, a.month, a.day);
    final dayB = DateTime(b.year, b.month, b.day);
    return dayA.isBefore(dayB);
  }

  void saveBatch() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final batch = StockStore.addBatch(
      productName: widget.productName,
      unit: widget.unit,
      quantity: double.parse(_quantityController.text.trim()),
      expiryDate: expiryDate!,
      receivedDate: receivedDate,
      location: _locationController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${batch.label} saved: ${StockUtils.formatQty(batch.quantity)} ${batch.unit} '
          'of ${batch.productName}, expires ${StockUtils.formatDate(batch.expiryDate)}',
        ),
      ),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      setState(() {
        _quantityController.clear();
        _expiryController.clear();
        expiryDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final existing = StockStore.batchesFor(widget.productName);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Batch')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('S08 • Inventory', style: TextStyle(color: colors.primary)),
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
                        widget.productName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${existing.length} existing batches • '
                        '${StockUtils.formatQty(StockStore.availableQuantity(widget.productName))} ${widget.unit} usable',
                        style: TextStyle(color: colors.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quantity
                TextFormField(
                  controller: _quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Quantity received',
                    suffixText: widget.unit,
                    border: const OutlineInputBorder(),
                  ),
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
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Expiration date
                TextFormField(
                  controller: _expiryController,
                  readOnly: true,
                  onTap: pickExpiryDate,
                  decoration: const InputDecoration(
                    labelText: 'Expiration date',
                    hintText: 'Tap to choose a date',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (expiryDate == null) {
                      return 'Choose an expiration date';
                    }
                    if (isBeforeDay(expiryDate!, receivedDate)) {
                      return 'Expiration date must be after the receiving date';
                    }
                    return null;
                  },
                ),
                if (expiryDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      StockUtils.daysText(StockUtils.daysUntil(expiryDate!)),
                      style: TextStyle(color: colors.primary),
                    ),
                  ),
                const SizedBox(height: 16),

                // Receiving date
                TextFormField(
                  controller: _receivedController,
                  readOnly: true,
                  onTap: pickReceivedDate,
                  decoration: const InputDecoration(
                    labelText: 'Receiving date',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Storage location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Storage location',
                    hintText: 'Refrigerator, Freezer, Shelf...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a storage location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: saveBatch,
                  child: const Text('Save Batch'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
