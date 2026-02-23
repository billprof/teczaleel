import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teczaleel/features/product/domain/entities/product.dart';
import 'package:teczaleel/features/cart/domain/entities/cart_item.dart';
import 'package:teczaleel/features/product/presentation/pages/products_page.dart';
import 'package:teczaleel/features/product/presentation/providers/product_provider.dart';
import 'package:teczaleel/features/cart/presentation/providers/cart_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:teczaleel/core/service_locator.dart';

class MockCategoriesNotifier extends AsyncNotifier<List<String>>
    with Mock
    implements CategoriesNotifier {}

class MockCartNotifier extends Notifier<List<CartItem>>
    with Mock
    implements CartNotifier {
  @override
  List<CartItem> build() => [];
}

class MockSearchQueryNotifier extends Notifier<String>
    with Mock
    implements SearchQueryNotifier {
  @override
  String build() => '';
}

class MockSelectedCategoryNotifier extends Notifier<String?>
    with Mock
    implements SelectedCategoryNotifier {
  @override
  String? build() => null;
}

void main() {
  const tProduct = Product(
    id: 1,
    title: 'Test Product',
    price: 100,
    description: 'Test Description',
    category: 'electronics',
    image: 'image.jpg',
    rating: Rating(rate: 4.5, count: 10),
  );

  testWidgets('should show loading indicator when products are loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filteredProductsProvider.overrideWithValue(const AsyncLoading()),
          connectivityStreamProvider.overrideWithValue(const AsyncData([])),
          categoriesProvider.overrideWith(() => MockCategoriesNotifier()),
          cartProvider.overrideWith(() => MockCartNotifier()),
          searchQueryProvider.overrideWith(() => MockSearchQueryNotifier()),
          selectedCategoryProvider.overrideWith(
            () => MockSelectedCategoryNotifier(),
          ),
        ],
        child: const MaterialApp(home: ProductsPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should show product list when products are loaded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filteredProductsProvider.overrideWithValue(
            const AsyncData([tProduct]),
          ),
          connectivityStreamProvider.overrideWithValue(const AsyncData([])),
          categoriesProvider.overrideWith(() => MockCategoriesNotifier()),
          cartProvider.overrideWith(() => MockCartNotifier()),
          searchQueryProvider.overrideWith(() => MockSearchQueryNotifier()),
          selectedCategoryProvider.overrideWith(
            () => MockSelectedCategoryNotifier(),
          ),
        ],
        child: const MaterialApp(home: ProductsPage()),
      ),
    );

    await tester.pump();

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('should show empty state message when product list is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filteredProductsProvider.overrideWithValue(const AsyncData([])),
          connectivityStreamProvider.overrideWithValue(const AsyncData([])),
          categoriesProvider.overrideWith(() => MockCategoriesNotifier()),
          cartProvider.overrideWith(() => MockCartNotifier()),
          searchQueryProvider.overrideWith(() => MockSearchQueryNotifier()),
          selectedCategoryProvider.overrideWith(
            () => MockSelectedCategoryNotifier(),
          ),
        ],
        child: const MaterialApp(home: ProductsPage()),
      ),
    );

    await tester.pump();

    expect(find.text('No products available'), findsOneWidget);
  });

  testWidgets('should show error message when products fail to load', (
    WidgetTester tester,
  ) async {
    const errorMessage = 'Failed to load products';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filteredProductsProvider.overrideWithValue(
            const AsyncError(errorMessage, StackTrace.empty),
          ),
          connectivityStreamProvider.overrideWithValue(const AsyncData([])),
          categoriesProvider.overrideWith(() => MockCategoriesNotifier()),
          cartProvider.overrideWith(() => MockCartNotifier()),
          searchQueryProvider.overrideWith(() => MockSearchQueryNotifier()),
          selectedCategoryProvider.overrideWith(
            () => MockSelectedCategoryNotifier(),
          ),
        ],
        child: const MaterialApp(home: ProductsPage()),
      ),
    );

    await tester.pump();

    expect(find.textContaining('Error: $errorMessage'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget); // Retry button
  });

  testWidgets('should show offline banner when device is offline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filteredProductsProvider.overrideWithValue(const AsyncData([])),
          connectivityStreamProvider.overrideWithValue(
            const AsyncData([ConnectivityResult.none]),
          ),
          categoriesProvider.overrideWith(() => MockCategoriesNotifier()),
          cartProvider.overrideWith(() => MockCartNotifier()),
          searchQueryProvider.overrideWith(() => MockSearchQueryNotifier()),
          selectedCategoryProvider.overrideWith(
            () => MockSelectedCategoryNotifier(),
          ),
        ],
        child: const MaterialApp(home: ProductsPage()),
      ),
    );

    await tester.pump();

    expect(find.text('No internet connection'), findsOneWidget);
  });
}
