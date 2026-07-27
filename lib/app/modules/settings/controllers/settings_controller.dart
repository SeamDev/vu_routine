import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vu_routine/app/utils/hive_service.dart';

class SettingsController extends GetxController {

  final reminderTime = 10.obs;
  final selectedTheme = ThemeMode.system.obs;
  final version = "null".obs;



  @override
  void onInit() {
    super.onInit();
    selectedTheme.value = getSavedThemeMode();

    reminderTime.value = HiveService.get("reminder_time") ?? 10;
    loadPackageInfo();
  }



  Future<void> changeTheme(ThemeMode mode) async {
    selectedTheme.value = mode;

    await HiveService.save("theme", mode.name);

    Get.changeThemeMode(mode);
  }

  ThemeMode getSavedThemeMode() {
    final value = HiveService.get<String>("theme") ?? "";

    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    version.value = "${info.version}+${info.buildNumber}";
  }

  void openGithub() {}


}
