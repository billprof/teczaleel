import 'package:hive_flutter/hive_flutter.dart';

abstract class LocalStorageService {
  Future<void> init();
  Future<void> save(
    String boxName,
    String key,
    dynamic value, {
    Duration? cacheDuration,
  });
  Future<dynamic> read(String boxName, String key);
  Future<void> delete(String boxName, String key);
  Future<void> clearBox(String boxName);
}

class HiveLocalStorageService implements LocalStorageService {
  @override
  Future<void> init() async {
    await Hive.initFlutter();
    // Pre-open boxes required immediately at startup
    await Hive.openBox('productsBox');
    await Hive.openBox('categoriesBox');
    await Hive.openBox('cartBox');
  }

  @override
  Future<void> save(
    String boxName,
    String key,
    dynamic value, {
    Duration? cacheDuration,
  }) async {
    final box = await _getBox(boxName);
    if (cacheDuration != null) {
      final expiryTime = DateTime.now()
          .add(cacheDuration)
          .millisecondsSinceEpoch;
      await box.put(key, {'data': value, 'expiry': expiryTime});
    } else {
      await box.put(key, value);
    }
  }

  @override
  Future<dynamic> read(String boxName, String key) async {
    final box = await _getBox(boxName);
    final storedValue = box.get(key);

    if (storedValue is Map &&
        storedValue.containsKey('expiry') &&
        storedValue.containsKey('data')) {
      final expiryTime = storedValue['expiry'] as int;
      if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
        await box.delete(key);
        return null; // Cache expired
      }
      return storedValue['data'];
    }

    return storedValue;
  }

  @override
  Future<void> delete(String boxName, String key) async {
    final box = await _getBox(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clearBox(String boxName) async {
    final box = await _getBox(boxName);
    await box.clear();
  }

  Future<Box> _getBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }
}
