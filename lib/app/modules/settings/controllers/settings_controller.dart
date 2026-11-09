import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vu_routine/app/modules/home/controllers/home_controller.dart';
import 'package:vu_routine/app/utils/hive_service.dart';

class SettingsController extends GetxController {
  final reminderTime = 10.obs;
  final selectedTheme = ThemeMode.system.obs;
  final version = "null".obs;

  int tapCount = 0;
  Timer? tapTimer;

  final isAdmin = false.obs;
  String pKey = "";

  final supabase = Supabase.instance.client;
  String bucket = 'files';
  String filePath = 'index.html';

  final lastUP = "--:--:--".obs;

  HomeController get homeController => Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    selectedTheme.value = getSavedThemeMode();

    reminderTime.value = HiveService.get("reminder_time") ?? 10;
    isAdmin.value = HiveService.get<bool>("isAdmin") ?? false;
    pKey = HiveService.get<String>("pKey") ?? "";
    loadPackageInfo();
    getLastUpdatedFile();
  }

  void setAdmin(String s) {
    isAdmin.value = true;
    pKey = s;
    HiveService.save("isAdmin", true);
    HiveService.save("pKey", s);
  }

  void offAdmin() {
    isAdmin.value = false;
    HiveService.save("isAdmin", false);
    pKey = "";
    HiveService.remove("pKey");
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

  // Supabase Storage

  Future<void> uploadFile(Uint8List bytes) async {
    try {
      await supabase.storage
          .from(bucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
    } catch (e) {
      debugPrint("Upload Error : $e");
    }
  }

  Future<void> getLastUpdatedFile() async {
    FileObject? file;

    DateTime lastTime = DateTime.parse(
      HiveService.get("lastUP") ?? "2000-01-01T17:24:24.906Z",
    ).toLocal();

    try {
      final files = await supabase.storage.from(bucket).list(path: '');

      file = files.firstWhere(
        (file) => file.name == filePath,
        orElse: () => throw Exception('File not found: $filePath'),
      );
    } catch (e) {
      debugPrint("get Update Error : $e");
      Get.snackbar(
        'Connection Error',
        'Failed to load routine. Showing saved data.',
        snackPosition: SnackPosition.TOP,
      );

      lastUP.value = DateFormat('dd MMM yyyy, hh:mm a').format(lastTime);
      return;
    }

    final dateTime = DateTime.parse(
      file.updatedAt ?? "2000-01-01T17:24:24.906Z",
    ).toLocal();

    if (dateTime.isAfter(lastTime)) {
      lastTime = dateTime;
      print(true);
      await HiveService.save("lastUP", file.updatedAt);

      Uint8List htmlFile = await getFile();
      homeController.updateInfo(htmlFile);
      Get.snackbar(
        'Success',
        'Updated new routine',
        snackPosition: SnackPosition.TOP,
      );
    }

    print(dateTime.isAfter(lastTime));
    print(lastTime.isAfter(dateTime));

    debugPrint("File updated: ${file.updatedAt}");
    debugPrint("Hive updated: ${await HiveService.get("lastUP")}");
    lastUP.value = DateFormat('dd MMM yyyy, hh:mm a').format(lastTime);
  }

  Future<Uint8List> getFile() async {
    return await supabase.storage.from(bucket).download(filePath);
  }
}
