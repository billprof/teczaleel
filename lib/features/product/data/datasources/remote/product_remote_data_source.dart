import 'package:teczaleel/core/network/api_client.dart';
import 'package:teczaleel/core/errors/exceptions.dart';
import 'package:teczaleel/features/product/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  // Calls the /products endpoint
  /// Throws a [ServerException] for all error codes.
  Future<List<ProductModel>> getProducts();

  // Calls the /products/categories endpoint
  /// Throws a [ServerException] for all error codes.
  Future<List<String>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await apiClient.dio.get('/products');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await apiClient.dio.get('/products/categories');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((category) => category.toString()).toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
