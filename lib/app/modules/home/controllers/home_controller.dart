import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vu_routine/app/models/schedule_home_model.dart';
import 'package:vu_routine/app/utils/hive_service.dart';
import 'package:vu_routine/app/utils/html_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vu_routine/app/utils/teacher_list.dart';

class HomeController extends GetxController {
  RxMap<String, dynamic> info = <String, dynamic>{}.obs;
  RxBool isLoading = true.obs;
  final days = [].obs;
  RxInt selectedIndex = 3.obs;
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

  final activeScheduleIndex = (-1).obs;
  final activeScheduleStatus = "".obs;

  Timer? _timer;

  @override
  void onInit() async {
    super.onInit();
    final savedUser = await HiveService.get("user");

    days.assignAll(getDate());
    if (savedUser == null) {
      Get.snackbar("Failed", "Upload a routine first.");
      isLoading.value = false;
      return;
    }
    info.assignAll(Map<String, dynamic>.from(savedUser));
    data.assignAll(convertToScheduleMap(info));
    isLoading.value = false;
    startScheduleTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void updateInfo() async {
    try {
      String? htmlString = await pickHtmlFileAsString();
      if (htmlString == null) {
        return;
      }
      final json = extractRoutineFromHtml(htmlString);
      if (json.isEmpty) {
        Get.snackbar("Failed", "Upload a valid routine file");
        return;
      }
      await HiveService.save("user", json);

      info.assignAll(Map<String, dynamic>.from(json));
      data.assignAll(convertToScheduleMap(info));
      startScheduleTimer();
      Get.snackbar("Success", "Routine update successful");
    } catch (e) {
      Get.snackbar("Failed", e.toString());
    }
  }

  Future<String?> pickHtmlFileAsString() async {
    try {
      List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (files.isEmpty) {
        return null;
      }

      PlatformFile file = files.first;

      final extension = file.extension?.toLowerCase();
      if (extension != 'html' &&
          extension != 'htm' &&
          extension != 'mhtml' &&
          extension != 'mht' &&
          !(file.name.toLowerCase().contains("varendra university"))) {
        Get.snackbar(
          "Invalid Format",
          "The selected file is not an HTML/HTM file.",
        );
        return null;
      }

      final bytes = await file.xFile.readAsBytes();
      return latin1.decode(bytes);
    } catch (e) {
      Get.snackbar("Error", e.toString());
      debugPrint(e.toString());
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
            color: getColorByCourse(value['courseCode']),
            backgroundImage:
                'assets/${getImagePathByCourse(value['courseCode'])}',
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

  Color getColorByCourse(String code) {
    switch (code) {
      case "CSE 2105": // DSD
        return Color(0xFF64748B);
      case "CSE 2106":
        return Color(0xFFD97706);
      case "CSE 2101": // OOP
        return Color(0xFF3B82F6);
      case "CSE 2102":
        return Color(0xFF658A71);
      case "CSE 2103": // DS
        return Color(0xFF8B5CF6);
      case "CSE 2104":
        return Color(0xFF475569);
      case "MAT 2141": // math
        return Color(0xFF0D9488);
      case "ECO 2171": // Eco
        return Color(0xFFD97775);
      default:
        return Color(0xff7F72F8);
    }
  }

  String getImagePathByCourse(String code) {
    switch (code) {
      case "CSE 2105": // DSD
        return "dsd.png";
      case "CSE 2106":
        return "dsdl.png";
      case "CSE 2101": // OOP
        return "opp.png";
      case "CSE 2102":
        return "oppl.png";
      case "CSE 2103": // DS
        return "ds.png";
      case "CSE 2104":
        return "dsl.png";
      case "MAT 2141": // math
        return "math.png";
      case "ECO 2171": // Eco
        return "eco.png";
      default:
        return "image.png";
    }
  }

  void startScheduleTimer() {
    _timer?.cancel();

    _updateScheduleStatus();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateScheduleStatus();
    });
  }

  void _updateScheduleStatus() {
    List<ScheduleModel> schedules = selectedSchedule;
    final now = DateTime.now();

    activeScheduleIndex.value = -1;
    activeScheduleStatus.value = "";

    for (int i = 0; i < schedules.length; i++) {
      final schedule = schedules[i];

      final start = _parseTime(schedule.startTime);
      final end = _parseTime(schedule.endTime);

      // Current class
      if (!now.isBefore(start) && now.isBefore(end)) {
        activeScheduleIndex.value = i;

        final remain = end.difference(now);

        activeScheduleStatus.value = "Ends in ${_formatDuration(remain)}";

        return;
      }

      // Next class
      if (now.isBefore(start)) {
        final remain = start.difference(now);

        activeScheduleStatus.value = "Starts in ${_formatDuration(remain)}";

        return;
      }
    }

    activeScheduleStatus.value = "No more classes today";
  }

  DateTime _parseTime(String time) {
    final t = DateFormat("hh:mm a").parse(time);

    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day, t.hour, t.minute);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    }

    if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    }

    return "${seconds}s";
  }
}
