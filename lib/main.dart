import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:vu_routine/app/core/app_theme.dart';
import 'package:vu_routine/app/routes/app_pages.dart';
import 'package:vu_routine/app/utils/hive_service.dart';

void main() async {
  WidgetsBinding widgwtBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgwtBinding);
  await HiveService.init();
  runApp(MyApp());
  //await Future.delayed(const Duration(seconds: 1));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VU Routine',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: getSavedThemeMode(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
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
