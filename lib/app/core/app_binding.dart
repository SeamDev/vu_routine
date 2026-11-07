import 'package:get/get.dart';
import 'package:vu_routine/app/modules/home/controllers/home_controller.dart';
import 'package:vu_routine/app/modules/schedule/controllers/schedule_controller.dart';
import 'package:vu_routine/app/modules/settings/controllers/settings_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
    );

    Get.lazyPut<HomeController>(
      () => HomeController(),
    );

    Get.lazyPut<ScheduleController>(
      () => ScheduleController(),
    );
  }
}