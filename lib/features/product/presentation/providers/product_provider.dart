import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teczaleel/core/network/api_client.dart';
import 'package:teczaleel/core/service_locator.dart';
import 'package:teczaleel/features/product/data/datasources/local/product_local_data_source.dart';
import 'package:teczaleel/features/product/data/datasources/remote/product_remote_data_source.dart';
import 'package:teczaleel/features/product/data/repositories/product_repository_impl.dart';
import 'package:teczaleel/features/product/domain/entities/product.dart';
import 'package:teczaleel/features/product/domain/repositories/product_repository.dart';
import 'package:teczaleel/features/product/domain/usecases/get_categories.dart';
import 'package:teczaleel/features/product/domain/usecases/get_products.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  return ProductRemoteDataSourceImpl(
    apiClient: ApiClient(dioOverride: ref.read(dioProvider)),
  );
});

final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  return ProductLocalDataSourceImpl(
    localStorageService: ref.read(localStorageServiceProvider),
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.read(productRemoteDataSourceProvider),
    localDataSource: ref.read(productLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final getProductsUseCaseProvider = Provider<GetProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProducts(repository);
});

final getCategoriesUseCaseProvider = Provider<GetCategories>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetCategories(repository);
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final getProducts = ref.read(getProductsUseCaseProvider);
  final result = await getProducts();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      SelectedCategoryNotifier.new,
    );

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setCategory(String? category) => state = category;
}

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  final result = await useCase();
  return result.fold((failure) => [], (categories) => categories);
});

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsyncValue = ref.watch(productsProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return productsAsyncValue.whenData((products) {
    return products.where((product) {
      final matchesSearch =
          product.title.toLowerCase().contains(searchQuery) ||
          product.description.toLowerCase().contains(searchQuery);
      final matchesCategory =
          selectedCategory == null || product.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  });
});
