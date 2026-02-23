import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teczaleel/core/service_locator.dart';
import 'package:teczaleel/features/cart/data/models/cart_item_model.dart';
import 'package:teczaleel/features/cart/domain/entities/cart_item.dart';
import 'package:teczaleel/features/product/domain/entities/product.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class CartNotifier extends Notifier<List<CartItem>> {
  static const String _cartBox = 'cartBox';
  static const String _cartKey = 'cart_items';

  @override
  List<CartItem> build() {
    _loadCart();
    return [];
  }

  Future<void> _loadCart() async {
    final storage = ref.read(localStorageServiceProvider);
    final data = await storage.read(_cartBox, _cartKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data as String);
      state = decoded
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _saveCart() async {
    final storage = ref.read(localStorageServiceProvider);
    final data = state
        .map((item) => CartItemModel.fromEntity(item).toJson())
        .toList();
    await storage.save(_cartBox, _cartKey, jsonEncode(data));
  }

  // Adds a product to the cart.
  // Returns 'added' if successful, 'duplicate' if already present.
  String addToCart(Product product, int quantity) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      return 'duplicate';
    } else {
      state = [...state, CartItem(product: product, quantity: quantity)];
      _saveCart();
      return 'added';
    }
  }

  void removeFromCart(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
    _saveCart();
  }

  void updateQuantity(int productId, int quantity) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
    _saveCart();
  }

  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => state.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );
}
