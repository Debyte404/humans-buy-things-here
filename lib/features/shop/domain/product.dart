class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String modelUrl;
  final String thumbnailUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.modelUrl,
    required this.thumbnailUrl,
    required this.category,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      modelUrl: map['modelUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      category: map['category'] ?? 'Uncategorized',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'modelUrl': modelUrl,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
    };
  }
}
