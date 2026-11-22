
import 'package:flutter/material.dart';
import 'product_info.dart';
import '../stock/stock_data.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductInfo? product;

  const AddEditProductScreen({
    super.key,
    this.product,
  });

  @override
  State<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState
    extends State<AddEditProductScreen> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController minimumStockController;

  final List<String> categories = [
    'Dairy',
    'Bakery',
    'Beverages',
    'Produce',
    'Meat',
    'Other',
  ];

  final List<String> units = [
    'L',
    'ml',
    'kg',
    'g',
    'pcs',
  ];

  final List<String> storageLocations = [
    'Refrigerator',
    'Freezer',
    'Shelf',
  ];

  late String selectedCategory;
  late String selectedUnit;
  late String selectedStorage;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.product?.name ?? '',
    );

    minimumStockController = TextEditingController(
      text: widget.product?.minimumStock.toString() ?? '6',
    );

    selectedCategory = widget.product?.category ?? 'Dairy';
    selectedUnit = widget.product?.unit ?? 'L';
    selectedStorage =
        widget.product?.storageLocation ?? 'Refrigerator';
  }

  @override
  void dispose() {
    nameController.dispose();
    minimumStockController.dispose();
    super.dispose();
  }

  void saveProduct() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();
    final minimumStock =
    double.parse(minimumStockController.text.trim());

    if (isEditing) {
      final product = widget.product!;

      product.name = name;
      product.category = selectedCategory;
      product.unit = selectedUnit;
      product.storageLocation = selectedStorage;
      product.minimumStock = minimumStock;

      Navigator.pop(context, true);
    } else {
      final newProduct = ProductInfo(
        name: name,
        category: selectedCategory,
        unit: selectedUnit,
        storageLocation: selectedStorage,
        minimumStock: minimumStock,
      );

      ProductCatalog.products.add(newProduct);

      Navigator.pop(context, newProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Product' : 'Add Product',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 24,
            ),
            children: [
              Text(
                'S07 • Product Management',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Product name',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 9),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter product name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a product name.';
                  }
                  if (isEditing &&
                      value.trim() != widget.product!.name &&
                      (StockStore.batchesFor(widget.product!.name).isNotEmpty ||
                          StockStore.history().any(
                                (transaction) =>
                            transaction.productName == widget.product!.name,
                          ))) {
                    return 'Cannot rename a product with existing stock history.';
                  }

                  final duplicate = ProductCatalog.products.any(
                        (product) =>
                    product.name.toLowerCase() ==
                        value.trim().toLowerCase() &&
                        product != widget.product,
                  );

                  if (duplicate) {
                    return 'This product already exists.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 9),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Unit',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 9),
              DropdownButtonFormField<String>(
                initialValue: selectedUnit,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedUnit = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Storage location',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 9),
              DropdownButtonFormField<String>(
                initialValue: selectedStorage,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: storageLocations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStorage = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Minimum stock level',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 9),
              TextFormField(
                controller: minimumStockController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter minimum quantity',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final number = double.tryParse(
                    value?.trim() ?? '',
                  );

                  if (number == null || number < 0) {
                    return 'Enter a valid non-negative number.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: saveProduct,
                  child: Text(
                    isEditing ? 'Save Changes' : 'Add Product',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
