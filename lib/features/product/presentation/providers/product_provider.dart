import 'dart:async';
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

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isRemoteFetching = false;

  @override
  Future<List<Product>> build() async {
    // 1. Setup connectivity listener for future changes
    _listenForConnectivity();

    ref.onDispose(() {
      _connectivitySubscription?.cancel();
    });

    // 2. Try to load from cache
    final getProducts = ref.read(getProductsUseCaseProvider);
    final cacheResult = await getProducts(fromCache: true);
    final cachedData = cacheResult.getOrElse(() => []);

    if (cachedData.isNotEmpty) {
      // If we have cache, return it immediately (AsyncData)
      // and trigger remote update in background.
      _loadFromRemote();
      return cachedData;
    } else {
      // If no cache, return the remote fetch future to keep state in AsyncLoading
      return _fetchRemoteData();
    }
  }

  Future<void> _loadFromRemote() async {
    await _fetchRemoteData();
  }

  Future<List<Product>> _fetchRemoteData() async {
    if (_isRemoteFetching) return state.value ?? [];
    _isRemoteFetching = true;

    try {
      final getProducts = ref.read(getProductsUseCaseProvider);
      final result = await getProducts(fromCache: false);
      return result.fold(
        (failure) => state.value ?? [], // Return current state on failure
        (products) {
          state = AsyncData(products);
          return products;
        },
      );
    } finally {
      _isRemoteFetching = false;
    }
  }

  void _listenForConnectivity() {
    final networkInfo = ref.read(networkInfoProvider);
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((
      isConnected,
    ) {
      if (isConnected) {
        _loadFromRemote();
      }
    });
  }
}

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

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<String>>(
      CategoriesNotifier.new,
    );

class CategoriesNotifier extends AsyncNotifier<List<String>> {
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isRemoteFetching = false;

  @override
  Future<List<String>> build() async {
    _listenForConnectivity();

    ref.onDispose(() {
      _connectivitySubscription?.cancel();
    });

    final useCase = ref.read(getCategoriesUseCaseProvider);
    final cacheResult = await useCase(fromCache: true);
    final cachedData = cacheResult.getOrElse(() => []);

    if (cachedData.isNotEmpty) {
      _loadFromRemote();
      return cachedData;
    } else {
      return _fetchRemoteData();
    }
  }

  Future<void> _loadFromRemote() async {
    await _fetchRemoteData();
  }

  Future<List<String>> _fetchRemoteData() async {
    if (_isRemoteFetching) return state.value ?? [];
    _isRemoteFetching = true;

    try {
      final useCase = ref.read(getCategoriesUseCaseProvider);
      final result = await useCase(fromCache: false);
      return result.fold((failure) => state.value ?? [], (categories) {
        state = AsyncData(categories);
        return categories;
      });
    } finally {
      _isRemoteFetching = false;
    }
  }

  void _listenForConnectivity() {
    final networkInfo = ref.read(networkInfoProvider);
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((
      isConnected,
    ) {
      if (isConnected) {
        _loadFromRemote();
      }
    });
  }
}

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
