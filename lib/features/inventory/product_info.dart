
class ProductInfo {
  String name;
  String category;
  String unit;
  String storageLocation;
  double minimumStock;

  ProductInfo({
    required this.name,
    required this.category,
    required this.unit,
    required this.storageLocation,
    required this.minimumStock,
  });
}

class ProductCatalog {
  static final List<ProductInfo> products = [
    ProductInfo(
      name: 'Whole milk',
      category: 'Dairy',
      unit: 'L',
      storageLocation: 'Refrigerator',
      minimumStock: 6,
    ),
    ProductInfo(
      name: 'Coffee beans',
      category: 'Beverages',
      unit: 'kg',
      storageLocation: 'Shelf',
      minimumStock: 3,
    ),
    ProductInfo(
      name: 'Croissants',
      category: 'Bakery',
      unit: 'pcs',
      storageLocation: 'Freezer',
      minimumStock: 10,
    ),
  ];
}
