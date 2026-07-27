class AlarmModel {
  int id;
  String day; // Sunday
  String title;
  String body;
  DateTime classTime;
  bool enabled;

  AlarmModel({
    required this.id,
    required this.day,
    required this.title,
    required this.body,
    required this.classTime,
    required this.enabled,
  });
}
