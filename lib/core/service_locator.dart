import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network/api_client.dart';
import 'network/network_info.dart';
import 'services/local_storage_service.dart';

// Dependencies
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.read(connectivityProvider));
});

final dioProvider = Provider<Dio>((ref) {
  return ApiClient().dio;
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return HiveLocalStorageService();
});
