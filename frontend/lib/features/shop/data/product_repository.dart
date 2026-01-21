import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

class ProductRepository {
  // Mock In-Memory Database
  final List<Product> _mockProducts = [
    Product(
      id: '1',
      name: 'Limitless Sneaker',
      description: 'A revolutionary sneaker with adaptive fit.',
      price: 299.0,
      modelUrl: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/MaterialsVariantsShoe/glTF-Binary/MaterialsVariantsShoe.glb',
      thumbnailUrl: 'https://via.placeholder.com/150',
      category: 'Footwear',
    ),
    Product(
      id: '2',
      name: 'Cyberpunk Helmet',
      description: 'High-tech protective gear for the urban jungle.',
      price: 450.0,
      modelUrl: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/DamagedHelmet/glTF-Binary/DamagedHelmet.glb',
      thumbnailUrl: 'https://via.placeholder.com/150',
      category: 'Accessories',
    ),
  ];

  ProductRepository();

  Stream<List<Product>> getProducts() {
    // Return stream of mock data
    return Stream.value(_mockProducts);
  }

  Future<Product?> getProduct(String id) async {
    try {
      return _mockProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> seedInitialData() async {
    // No-op for mock repo
  }
}
