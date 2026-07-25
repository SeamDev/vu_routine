import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;

Map<String, dynamic> extractRoutineFromHtml(String html) {
  final document = parser.parse(html);

  final Map<String, dynamic> result = {};

  // TimeSlot
  final th = document
      .querySelectorAll('.table-dark-head')[0]
      .querySelectorAll("th");

  result.addAll({"time_slot": formatTimeSlot(th)});
  // week
  final tb = document.querySelectorAll("tbody tr");

  result.addAll(formatRoutine(tb));
  //print(result);
  return result;
}

List<Map<String, String>> formatTimeSlot(List<Element> data) {
  List<Map<String, String>> result = [];

  for (int i = 1; i < data.length; i++) {
    String time = data[i].querySelector("small")!.text;
    result.add({
      "start": time.split("-")[0].trim(),
      "end": time.split("-")[1].trim(),
    });
  }

  return result;
}

Map<String, Map<String, dynamic>> formatRoutine(List<Element> data) {
  Map<String, Map<String, dynamic>> result = {};

  for (int i = 0; i < data.length; i++) {
    String key = data[i].querySelector("th")!.text.trim();
    final td = data[i].querySelectorAll("td");
    Map<String, dynamic> info = {};
    for (int j = 0; j < td.length; j++) {
      if (td[j].text.trim().isEmpty) continue;
      info.putIfAbsent(
        j.toString(),
        () => {
          "courseCode": td[j].querySelectorAll('div')[2].text.trim(),
          "courseTitle": td[j].querySelectorAll('div')[4].text.trim(),

          "teacher": td[j].querySelectorAll('div')[5].text.trim(),

          "room":
              td[j].querySelector('span')?.text.replaceAll('Room:', '').trim(),
        },
      );
    }
    result.putIfAbsent(key, () => info);
  }

  return result;
}
