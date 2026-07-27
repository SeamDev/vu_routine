import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _infoBoxName = "info";

  // ignore: non_constant_identifier_names
  static late Box _info_box;


  /// Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    _info_box = await Hive.openBox(_infoBoxName);
  }

  /// Save data
  static Future<void> save<T>(String key, T value) async {
    await _info_box.put(key, value);
  }

  /// Get data
  static T? get<T>(String key) {
    return _info_box.get(key) as T?;
  }

  /// Check key exists
  static bool has(String key) {
    return _info_box.containsKey(key);
  }

  /// Delete specific data
  static Future<void> remove(String key) async {
    await _info_box.delete(key);
  }

  /// Clear all data
  static Future<void> clear() async {
    await _info_box.clear();
  }

  /// Close Hive box
  static Future<void> close() async {
    await _info_box.close();
  }
}