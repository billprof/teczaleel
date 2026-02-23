import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:teczaleel/core/service_locator.dart';
import 'package:teczaleel/features/product/presentation/providers/product_provider.dart';
import 'package:teczaleel/features/product/presentation/widgets/category_filter.dart';
import 'package:teczaleel/features/product/presentation/widgets/empty_list.dart';
import 'package:teczaleel/features/product/presentation/widgets/mini_cart.dart';
import 'package:teczaleel/features/product/presentation/widgets/product_card.dart';
import 'package:teczaleel/features/product/presentation/widgets/search_field.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(filteredProductsProvider);
    final connectivityAsyncValue = ref.watch(connectivityStreamProvider);

    final isOffline = connectivityAsyncValue.maybeWhen(
      data: (results) => results.contains(ConnectivityResult.none),
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Products'), actions: [MiniCart()]),
      body: Column(
        children: [
          if (isOffline)
            Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'No internet connection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SearchField(),
          const CategoryFilter(),
          Expanded(
            child: productsAsyncValue.when(
              data: (products) {
                if (products.isEmpty) {
                  return EmptyList(title: 'No products available');
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    // ignore: unused_result
                    ref.refresh(productsProvider);
                  },
                  child: AnimationLimiter(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 400),
                          columnCount: products.length,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: ProductCard(product: product),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${error.toString()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // ignore: unused_result
                        ref.refresh(productsProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
