import 'dart:convert';
import 'package:teczaleel/core/services/local_storage_service.dart';
import 'package:teczaleel/core/utils/constants.dart';
import 'package:teczaleel/core/errors/exceptions.dart';
import 'package:teczaleel/features/product/data/models/product_model.dart';

abstract class ProductLocalDataSource {
  /// Gets the cached [List<ProductModel>] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<List<ProductModel>> getLastProducts();

  /// Caches the given [List<ProductModel>] into the local storage.
  Future<void> cacheProducts(List<ProductModel> productsToCache);

  /// Gets the cached [List<String>] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<List<String>> getLastCategories();

  /// Caches the given [List<String>] into the local storage.
  Future<void> cacheCategories(List<String> categoriesToCache);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final LocalStorageService localStorageService;

  ProductLocalDataSourceImpl({required this.localStorageService});

  @override
  Future<List<ProductModel>> getLastProducts() async {
    final jsonStringList = await localStorageService.read(
      AppConstants.productsBox,
      AppConstants.cachedProductsKey,
    );

    if (jsonStringList != null) {
      List<dynamic> jsonList = jsonDecode(jsonStringList);
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> productsToCache) async {
    final List<Map<String, dynamic>> jsonList = productsToCache
        .map((product) => product.toJson())
        .toList();
    final String jsonStringList = jsonEncode(jsonList);

    await localStorageService.save(
      AppConstants.productsBox,
      AppConstants.cachedProductsKey,
      jsonStringList,
      cacheDuration: AppConstants.productCacheDuration,
    );
  }

  @override
  Future<List<String>> getLastCategories() async {
    final jsonStringList = await localStorageService.read(
      AppConstants.categoriesBox,
      AppConstants.cachedCategoriesKey,
    );

    if (jsonStringList != null) {
      List<dynamic> jsonList = jsonDecode(jsonStringList);
      return jsonList.map((item) => item.toString()).toList();
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheCategories(List<String> categoriesToCache) async {
    final String jsonStringList = jsonEncode(categoriesToCache);

    await localStorageService.save(
      AppConstants.categoriesBox,
      AppConstants.cachedCategoriesKey,
      jsonStringList,
      cacheDuration: AppConstants.categoryCacheDuration,
    );
  }
}
