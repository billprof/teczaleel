import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/local_storage_service.dart';
import 'features/product/presentation/pages/products_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = HiveLocalStorageService();
  await storageService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teczaleel E-Commerce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7b32e8)),
        useMaterial3: true,
      ),
      home: const ProductsPage(),
    );
  }
}
