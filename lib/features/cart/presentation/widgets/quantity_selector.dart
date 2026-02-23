import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teczaleel/features/cart/domain/entities/cart_item.dart';
import 'package:teczaleel/features/cart/presentation/providers/cart_provider.dart';

class QuantitySelector extends ConsumerWidget {
  final CartItem item;

  const QuantitySelector({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildQtyBtn(
            icon: Icons.remove,
            onPressed: item.quantity > 1
                ? () => ref
                      .read(cartProvider.notifier)
                      .updateQuantity(item.product.id, item.quantity - 1)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _buildQtyBtn(
            icon: Icons.add,
            onPressed: () => ref
                .read(cartProvider.notifier)
                .updateQuantity(item.product.id, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn({required IconData icon, VoidCallback? onPressed}) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      color: onPressed == null ? Colors.grey : const Color(0xFF7b32e8),
    );
  }
}
