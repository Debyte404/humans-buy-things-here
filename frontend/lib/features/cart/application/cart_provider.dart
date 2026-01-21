import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/cart_item.dart';
import '../../shop/domain/product.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

class CartNotifier extends Notifier<List<CartItem>> {
  static const _cartKey = 'cart_items';

  @override
  List<CartItem> build() {
    // Ideally load async, but for sync build we start empty and load immediately
    _loadCart();
    return [];
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cartKey);
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      state = decoded.map((itemMap) {
        final productMap = itemMap['product'];
        return CartItem(
          product: Product.fromMap(productMap, productMap['id'] ?? 'unknown'),
          quantity: itemMap['quantity'],
        );
      }).toList();
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> exportState = state.map((item) {
      return {
        'product': item.product.toMap()..addAll({'id': item.product.id}),
        'quantity': item.quantity,
      };
    }).toList();
    await prefs.setString(_cartKey, jsonEncode(exportState));
  }

  void addToCart(Product product) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      final oldItem = state[existingIndex];
      final updatedItem = oldItem.copyWith(quantity: oldItem.quantity + 1);
      
      final newState = [...state];
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      state = [...state, CartItem(product: product)];
    }
    _saveCart();
  }

  void removeFromCart(Product product) {
    state = state.where((item) => item.product.id != product.id).toList();
    _saveCart();
  }

  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      removeFromCart(product);
      return;
    }

    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final newState = [...state];
      newState[index] = newState[index].copyWith(quantity: quantity);
      state = newState;
      _saveCart();
    }
  }

  double get totalAmount => state.fold(0, (sum, item) => sum + item.totalPrice);
}
