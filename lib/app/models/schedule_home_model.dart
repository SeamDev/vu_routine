import 'dart:ui';

class ScheduleModel {
  final String startTime;
  final String endTime;
  final String title;
  final String subtitle;
  final String teacher;
  final String room;
  final String number;
  final Color color;
  final String? backgroundImage;

  const ScheduleModel({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.subtitle,
    required this.teacher,
    required this.room,
    required this.number,
    required this.color,
    this.backgroundImage,
  });
}