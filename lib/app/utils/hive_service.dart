import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _infoBoxName = "info";
  static const String _taskBoxName = "setting";

  static late Box _info_box;
  // ignore: unused_field
  static late Box _task_box;

  /// Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    _info_box = await Hive.openBox(_infoBoxName);
    _task_box = await Hive.openBox(_taskBoxName);
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