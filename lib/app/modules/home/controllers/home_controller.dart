import 'dart:convert';
import 'dart:io' as io;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vu_routine/app/models/schedule_model.dart';
import 'package:vu_routine/app/utils/hive_service.dart';
import 'package:vu_routine/app/utils/html_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vu_routine/app/utils/teacher_list.dart';

class HomeController extends GetxController {
  RxMap<String, dynamic> info = <String, dynamic>{}.obs;
  RxBool isLoading = true.obs;
  final days = [].obs;
  Map<String, List<ScheduleModel>> data = <String, List<ScheduleModel>>{}.obs;
  List<ScheduleModel> get selectedSchedule {
    final dayName = days[selectedIndex.value]["day"];

    final fullDayName =
        {
          "Mon": "Monday",
          "Tue": "Tuesday",
          "Wed": "Wednesday",
          "Thu": "Thursday",
          "Fri": "Friday",
          "Sat": "Saturday",
          "Sun": "Sunday",
        }[dayName];

    return data[fullDayName] ?? [];
  }

  RxInt selectedIndex = 3.obs;

  @override
  void onInit() async {
    super.onInit();
    final savedUser = await HiveService.get("user");

    if (savedUser == null) {
      Get.snackbar("Failed", "ReLoad Routine");
      return;
    }
    days.assignAll(getDate());
    info.assignAll(Map<String, dynamic>.from(savedUser));
    data.assignAll(convertToScheduleMap(info));
    isLoading.value = false;
  }

  void updateInfo() async {
    try {
      String? htmlString = await pickHtmlFileAsString();
      if (htmlString == null) {
        return;
      }
      final json = extractRoutineFromHtml(htmlString);
      await HiveService.save("user", json);
      Get.snackbar("Success", "Routine update successful");
    } catch (e) {
      Get.snackbar("Failed", e.toString());
    }
  }

  Future<String?> pickHtmlFileAsString() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['html', 'htm'],
        withData: true,
      );
      // 2. Return null if the user cancels the picker
      if (result == null || result.files.isEmpty) {
        return null;
      }

      PlatformFile file = result.files.first;

      final extension = file.extension?.toLowerCase();
      if (extension != 'html' && extension != 'htm') {
        Get.snackbar(
          "Invalid Format",
          "The selected file is not an HTML/HTM file.",
        );
        return null;
      }

      // Web path: Read directly from bytes
      if (kIsWeb && file.bytes != null) {
        return utf8.decode(file.bytes!);
      }

      // Mobile / Desktop path: Read from the local device storage path
      if (!kIsWeb && file.path != null) {
        final ioFile = io.File(file.path!);
        return await ioFile.readAsString();
      }
      return null;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return null;
    }
  }

  List getDate() {
    final now = DateTime.now();

    final days = List.generate(7, (index) {
      final date = now.add(Duration(days: index - 3));

      return {
        "day": _weekDay(date.weekday),
        "date": date.day.toString(),
        "label": _dayLabel(index - 3),
      };
    });
    return days;
  }

  String _weekDay(int weekday) {
    const names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return names[weekday - 1];
  }

  String _dayLabel(int offset) {
    switch (offset) {
      case -3:
        return "3 Days Ago";
      case -2:
        return "2 Days Ago";
      case -1:
        return "Yesterday";
      case 0:
        return "Today";
      case 1:
        return "Tomorrow";
      case 2:
        return "In 2 Days";
      case 3:
        return "In 3 Days";
      default:
        return "";
    }
  }

  // Format to MOdel list
  Map<String, List<ScheduleModel>> convertToScheduleMap(
    Map<String, dynamic> json,
  ) {
    final Map<String, List<ScheduleModel>> result = {};

    final timeSlots =
        (json['time_slot'] as List)
            .map((e) => Map<String, dynamic>.from(Map.from(e)))
            .toList();

    const weekDays = [
      'Saturday',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
    ];

    for (final day in weekDays) {
      final dayData = Map<String, dynamic>.from(json[day] ?? {});

      final schedules = <ScheduleModel>[];

      dayData.forEach((slot, value) {
        final index = int.parse(slot);

        schedules.add(
          ScheduleModel(
            startTime: timeSlots[index]['start'],
            endTime: timeSlots[index]['end'],
            title: value['courseCode'],
            subtitle: value['courseTitle'],
            teacher: value['teacher'],
            room: value['room'],
            number: findTeacher(value['teacher']) ?? "Not Found",
            // Optional
            color: const Color(0xff7F72F8),
            backgroundImage: 'image.png',
          ),
        );
      });

      // Sort by class time
      // schedules.sort((a, b) {
      //   final aIndex = timeSlots.indexWhere((e) => e['start'] == a.startTime);
      //   final bIndex = timeSlots.indexWhere((e) => e['start'] == b.startTime);
      //   return aIndex.compareTo(bIndex);
      // });

      result[day] = schedules;
    }

    return result;
  }
}
