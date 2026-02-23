import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teczaleel/features/cart/presentation/providers/cart_provider.dart';
import 'package:teczaleel/features/cart/presentation/pages/cart_page.dart';

class MiniCart extends ConsumerWidget {
  const MiniCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalItems = ref.watch(
      cartProvider.select(
        (items) => items.fold(0, (sum, item) => sum + item.quantity),
      ),
    );

    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        );
      },
      icon: Badge(
        label: Text('$totalItems', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1fc2f0),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
