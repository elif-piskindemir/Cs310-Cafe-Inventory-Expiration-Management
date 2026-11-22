import 'package:flutter/material.dart';

import 'stock_data.dart';
import 'transaction_history_screen.dart';

// S10 WASTE / ADJUST
class WasteAdjustScreen extends StatefulWidget {
  final String productName;
  final String unit;

  const WasteAdjustScreen({
    super.key,
    this.productName = 'Whole milk',
    this.unit = 'L',
  });

  @override
  State<WasteAdjustScreen> createState() => _WasteAdjustScreenState();
}

class _WasteAdjustScreenState extends State<WasteAdjustScreen> {
  static const String wasteMode = 'Waste';
  static const String adjustMode = 'Adjust';

  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  String mode = wasteMode;
  String? selectedBatchId;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  List<Batch> get batches => StockStore.batchesFor(widget.productName);

  Batch? get selectedBatch {
    for (final b in batches) {
      if (b.id == selectedBatchId) return b;
    }
    return null;
  }

  double? get enteredQty => double.tryParse(_quantityController.text.trim());

  String? get preview {
    final batch = selectedBatch;
    final qty = enteredQty;
    if (batch == null || qty == null) return null;

    final newQty = mode == wasteMode ? batch.quantity - qty : qty;
    if (newQty < 0) return null;
    return '${batch.label}: ${StockUtils.formatQty(batch.quantity)} ${widget.unit} '
        '→ ${StockUtils.formatQty(StockUtils.round2(newQty))} ${widget.unit}';
  }

  void changeMode(String newMode) {
    setState(() {
      mode = newMode;
      _quantityController.clear();
    });
  }

  void save() {
    final batch = selectedBatch;
    if (batch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose the affected batch first')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final qty = double.parse(_quantityController.text.trim());
    final reason = _reasonController.text.trim();
    final String message;

    if (mode == wasteMode) {
      message = 'Wasted ${StockUtils.formatQty(qty)} ${widget.unit} from ${batch.label}';
    } else {
      message = '${batch.label} adjusted to ${StockUtils.formatQty(qty)} ${widget.unit}';
    }

    setState(() {
      if (mode == wasteMode) {
        StockStore.waste(batch, qty, reason);
      } else {
        StockStore.adjust(batch, qty, reason);
      }
      _quantityController.clear();
      _reasonController.clear();
      selectedBatchId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
    final isWaste = mode == wasteMode;
    final previewText = preview;

    return Scaffold(
      appBar: AppBar(title: const Text('Waste / Adjust')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('S10 • Operations', style: TextStyle(color: colors.primary)),
                const SizedBox(height: 12),

                // Product summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.productName}   '
                    '${StockUtils.formatQty(StockStore.availableQuantity(widget.productName))} ${widget.unit} usable',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Waste- Adjust modee
                Row(
                  children: [
                    Expanded(
                      child: ModeButton(
                        label: wasteMode,
                        selected: isWaste,
                        onPressed: () => changeMode(wasteMode),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModeButton(
                        label: adjustMode,
                        selected: !isWaste,
                        onPressed: () => changeMode(adjustMode),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isWaste
                      ? 'Record ingredients that were thrown away.'
                      : 'Correct a batch to the quantity you counted.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 20),

                // Affected batch
                const Text(
                  'Affected batch',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                BatchPicker(
                  batches: batches,
                  selectedBatchId: selectedBatchId,
                  onSelected: (id) {
                    setState(() {
                      selectedBatchId = id;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Quantity
                TextFormField(
                  controller: _quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: isWaste ? 'Quantity to discard' : 'Counted quantity',
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
                    final batch = selectedBatch;
                    if (isWaste) {
                      if (qty <= 0) {
                        return 'Quantity must be greater than 0';
                      }
                      if (batch != null && qty > batch.quantity) {
                        return 'Only ${StockUtils.formatQty(batch.quantity)} ${widget.unit} in ${batch.label}';
                      }
                    } else {
                      if (qty < 0) {
                        return 'Counted quantity cannot be negative';
                      }
                      if (batch != null && qty == batch.quantity) {
                        return 'This is already the current quantity';
                      }
                    }
                    return null;
                  },
                ),
                if (previewText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(previewText, style: TextStyle(color: colors.primary)),
                  ),
                const SizedBox(height: 16),

                // Reason
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    hintText: isWaste
                        ? 'Expired, spilled, spoiled...'
                        : 'Inventory count, data entry mistake...',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a reason';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWaste ? colors.error : colors.primary,
                    foregroundColor: isWaste ? colors.onError : colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: save,
                  child: Text(isWaste ? 'Record Waste' : 'Save Adjustment'),
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
class ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const ModeButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? colors.primary : colors.surface,
        foregroundColor: selected ? colors.onPrimary : colors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
