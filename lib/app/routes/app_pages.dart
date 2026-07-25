import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/navbar/bindings/navbar_binding.dart';
import '../modules/navbar/views/navbar_view.dart';
import '../modules/task/bindings/task_binding.dart';
import '../modules/task/views/task_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: constant_identifier_names
  static const INITIAL = Routes.NAVBAR;

  static final routes = [
    GetPage(
      name: _Paths.NAVBAR,
      page: () => const NavbarView(),
      binding: NavbarBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.TASK,
      page: () => const TaskView(),
      binding: TaskBinding(),
    ),
  ];
}
