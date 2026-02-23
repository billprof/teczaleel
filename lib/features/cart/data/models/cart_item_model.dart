import 'package:teczaleel/features/cart/domain/entities/cart_item.dart';
import 'package:teczaleel/features/product/data/models/product_model.dart';

class CartItemModel extends CartItem {
  const CartItemModel({required super.product, required super.quantity});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': (product as ProductModel).toJson(),
      'quantity': quantity,
    };
  }

  static CartItemModel fromEntity(CartItem entity) {
    return CartItemModel(product: entity.product, quantity: entity.quantity);
  }
}
