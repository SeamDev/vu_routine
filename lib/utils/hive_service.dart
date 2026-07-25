import 'package:hive_flutter/hive_flutter.dart';

final box = Hive.box("HiveBox");

Future<void> saveRoutine(Map<String, dynamic> data) async {
  await box.put("key", data);
}

Map<String, dynamic> getRoutine() {
  return Map<String, dynamic>.from(box.get('key') ?? {});
}

void saveTimeslot(List data) {
  box.put("timeslot", data);
}

List getTimeslot() {
  return box.get("timeslot", defaultValue: []);
}

void saveSemister(String value) {
  box.put("semisterName", value);
}

String getSemister() {
  return box.get("semisterName", defaultValue: "1st");
}

void saveSection(String value) {
  box.put("sectionName", value);
}

String getSection() {
  return box.get("sectionName", defaultValue: "A");
}
