import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/local_storage_service.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Teczaleel E-Commerce App')),
      ),
    );
  }
}
