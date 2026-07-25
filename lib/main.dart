import 'package:flutter/material.dart';
import 'package:vu_routine/module/screen.dart';
import 'package:vu_routine/widgets/exit_conformation.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgwtBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgwtBinding);
  await Hive.initFlutter();
  await Hive.openBox("HiveBox");
  await Hive.openBox('updateBox');
  runApp(MyApp());
  await Future.delayed(const Duration(seconds: 2));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExitConfirmationWrapper(child: SheetDataScreen()),
    );
  }
}
