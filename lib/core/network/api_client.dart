import 'package:dio/dio.dart';
import 'package:teczaleel/core/utils/constants.dart';

class ApiClient {
  final Dio dio;

  ApiClient({Dio? dioOverride})
    : dio =
          dioOverride ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Content-Type': 'application/json'},
            ),
          ) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    );
  }
}
