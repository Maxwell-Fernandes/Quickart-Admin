class Product {
  final String id;
  final String productName;
  final double price;
  final String categoryId;

  Product({
    required this.id,
    required this.productName,
    required this.price,
    required this.categoryId,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      productName: data['product_name'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      categoryId: data['category_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_name': productName,
      'price': price,
      'category_id': categoryId,
    };
  }
}
