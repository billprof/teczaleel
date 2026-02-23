import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teczaleel/features/cart/presentation/providers/cart_provider.dart';
import 'package:teczaleel/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:teczaleel/features/cart/presentation/widgets/empty_cart.dart';
import 'package:teczaleel/features/cart/presentation/widgets/order_summary.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartProvider.notifier).totalPrice;

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart'), elevation: 0),
      body: cartItems.isEmpty
          ? EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: CartItemCard(item: item),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                OrderSummary(totalPrice: totalPrice),
              ],
            ),
    );
  }
}
