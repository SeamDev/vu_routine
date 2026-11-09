import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:vu_routine/app/core/app_binding.dart';
import 'package:vu_routine/app/core/app_theme.dart';
import 'package:vu_routine/app/routes/app_pages.dart';
import 'package:vu_routine/app/service/notification_service.dart';
import 'package:vu_routine/app/utils/hive_service.dart';
import 'package:vu_routine/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await HiveService.init();

  await Supabase.initialize(
    url: 'https://ixiagiabihtbffheialv.supabase.co',
    publishableKey: 'sb_publishable_ZDEidP5WY5QErmXxNXs-lw_QXgln7Kz',
  );


  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await NotificationService.instance.initialize();

    FlutterNativeSplash.remove();
  });
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
      initialBinding: AppBinding(),
      themeMode: getSavedThemeMode(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

ThemeMode getSavedThemeMode() {
  final value = HiveService.get<String>('theme') ?? '';

  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}
