import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teczaleel/features/cart/domain/entities/cart_item.dart';
import 'package:teczaleel/features/cart/presentation/providers/cart_provider.dart';

void showDeletePrompt(BuildContext context, WidgetRef ref, CartItem item) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove Item'),
      content: const Text(
        'Are you sure you want to remove this item from your cart?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            ref.read(cartProvider.notifier).removeFromCart(item.product.id);
            Navigator.pop(context);
          },
          child: const Text('Remove', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
