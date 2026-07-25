import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vu_routine/module/check_update.dart';
import 'package:vu_routine/utils/hive_service.dart';
import 'package:vu_routine/utils/teacher_list.dart';
import 'package:vu_routine/utils/toast.dart';
import 'google_sheet_csv.dart';
import 'package:package_info_plus/package_info_plus.dart';


class SheetDataScreen extends StatefulWidget {
  const SheetDataScreen({super.key});

  @override
  State<SheetDataScreen> createState() => _SheetDataScreenState();
}

class _SheetDataScreenState extends State<SheetDataScreen> {
  List<List<dynamic>> _rows = [];
  bool isNetAvailable = true;
  bool isLoading = true;
  List<String> slot = [];
  Map<String, dynamic> routine = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // Check for update
      if(mounted) checkForUpdate(context, currentVersion);
    });
    //print(routine.isEmpty);
    //loadCsv("0"); //1st
    //loadCsv("1739684797"); //2nd
    //loadCsv("1812971555"); //3rd
    //loadCsv("1642366900"); //4th
    //loadCsv("1698922910"); //5th
    //loadCsv("1687685897"); //6th
    //loadCsv("2130237812"); //7th
    //loadCsv("1780568258"); //8th
    //loadCsv("614628609"); //9th
    loadAllSheets();
  }

  Future<void> setOffline() async {
    //print(routine.isEmpty);
    if (routine.isNotEmpty) {
      saveRoutine(routine);
    } else {
      routine = getRoutine();
    }
    //print(routine.isEmpty);
    setState(() {});
  }

  Future<void> loadAllSheets() async {
    List<String> gids = [
      "0",
      "1739684797",
      "1812971555",
      "1642366900",
      "1698922910",
      "1687685897",
      "2130237812",
      "1780568258",
      "614628609",
    ];

    try {
      final futures = gids.map((id) {
        var url =
            'https://docs.google.com/spreadsheets/d/1Sdmr60rcZeBCa2ofswUr9mxIreIj71W9HYM1RRhvfMM/export?format=csv&gid=$id';
        return GoogleSheetCsv(url).fetchAndParse();
      });

      final results = await Future.wait(futures);

      _rows = results.expand((e) => e).toList();

      formatSheet(_rows);
      await setOffline();
    } catch (e) {
      isNetAvailable = false;
      await setOffline();
    }

    isLoading = false;
    setState(() {});
  }

  void addToRoutine({
    required String preWeek,
    required String rawSubject, // "EEE 1231 (2nd Sem. A Sec)"
    required String time,
    required String room,
    required String name,
  }) {
    // Extract semester and section from rawSubject
    final regex = RegExp(r'\(([^)]+)\)');
    String semesterSection = "";
    if (regex.hasMatch(rawSubject)) {
      semesterSection =
          regex.firstMatch(rawSubject)!.group(1)!; // "2nd Sem. A Sec"
    }

    // Split semesterSection
    final semMatch = RegExp(r'(\d+(st|nd|rd|th))').firstMatch(semesterSection);
    final sem = semMatch?.group(1) ?? "";

    // section
    final secMatch = RegExp(r'Sem\.\s*(.+?)\s*Sec').firstMatch(semesterSection);
    List<String> sections = [];

    if (secMatch != null) {
      sections = secMatch.group(1)!.split(',').map((e) => e.trim()).toList();
    }

    // Initialize nested structure if null
    routine[sem] ??= {};
    // loop for section
    routine[sem] ??= {};

    for (var sec in sections) {
      routine[sem][sec] ??= {};
      routine[sem][sec][preWeek] ??= [];

      routine[sem][sec][preWeek].add([
        name,
        rawSubject.trim().split(" ").sublist(0, 2).join(" "),
        time,
        room,
      ]);
    }
  }

  void formatSheet(List<List<dynamic>> rows) {
    if (!mounted || rows.isEmpty) return;

    List<String> localSlot = [];

    // HEADER
    for (int j = 0; j < rows[0].length; j++) {
      final cell = rows[0][j].toString();
      if (cell.contains(":")) {
        localSlot.add(cell.split(" ").sublist(2).join(" "));
      }
    }

    String preWeek = "";

    for (int i = 1; i < rows.length; i++) {
      for (int j = 0; j < rows[i].length; j++) {
        final raw = rows[i][j].toString().trim();
        if (raw.isEmpty) continue;

        final data = raw.split("\n");

        if ([
          "Sunday",
          "Monday",
          "Tuesday",
          "Wednesday",
          "Thursday",
        ].contains(data[0])) {
          preWeek = data[0];
        } else if (data.length >= 3 && j > 0 && j - 1 < localSlot.length) {
          addToRoutine(
            preWeek: preWeek,
            rawSubject: data[1],
            name: data[0],
            room: data[2],
            time: localSlot[j - 1],
          );
        }
      }
    }
  }

  String semisterName = getSemister();
  int week = DateTime.now().weekday;
  String sectionName = getSection();
  List secList = [];

  @override
  Widget build(BuildContext context) {
    final weekdayNames = [
      "", // index 0 placeholder
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    int timeToMinutes(String time) {
      // Example: "11:50 AM"
      final parts = time.split(' ');
      final hm = parts[0].split(':');
      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);
      String period = parts[1];

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      return hour * 60 + minute;
    }

    //int weekday = DateTime.now().weekday;
    String today = weekdayNames[week];

    var data = routine[semisterName]?[sectionName]?[today] ?? [];
    data.sort((a, b) {
      int timeA = timeToMinutes(a[2]);
      int timeB = timeToMinutes(b[2]);
      return timeA.compareTo(timeB);
    });
    //print(routine);
    secList = routine[semisterName]?.keys.toList() ?? [];
    secList.sort();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: GestureDetector(
          onTap: () async {
            const url = "fb://profile/100077018623838";
            const url1 = "https://www.facebook.com/sh.seam.0";
            try {
              bool launched = await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
              if (!launched) {
                await launchUrl(
                  Uri.parse(url1),
                  mode: LaunchMode.externalApplication,
                );
              }
            } catch (e) {
              await launchUrl(
                Uri.parse(url1),
                mode: LaunchMode.externalApplication,
              );
            }
          },
          child: Row(
            children: [
              Text("VU CSE ", style: TextStyle(color: Colors.white)),
              Icon(Icons.info_outline, color: Colors.white),
            ],
          ),
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton(
              value: week,
              style: TextStyle(color: Colors.white, fontSize: 18),
              iconSize: 35,
              iconEnabledColor: Colors.white,
              dropdownColor: Colors.deepPurple,
              items: [
                DropdownMenuItem(value: 7, child: Text("Sunday")),
                DropdownMenuItem(value: 1, child: Text("Monday")),
                DropdownMenuItem(value: 2, child: Text("Tuesday")),
                DropdownMenuItem(value: 3, child: Text("Wednesday")),
                DropdownMenuItem(value: 4, child: Text("Thursday")),
                DropdownMenuItem(value: 5, child: Text("Friday")),
                DropdownMenuItem(value: 6, child: Text("Saturday")),
              ],
              onChanged: (value) {
                setState(() {
                  week = value!;
                });
              },
            ),
          ),
          SizedBox(width: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton(
              value: semisterName,
              style: TextStyle(color: Colors.white, fontSize: 18),
              iconSize: 35,
              iconEnabledColor: Colors.white,
              dropdownColor: Colors.deepPurple,
              items: [
                DropdownMenuItem(value: "1st", child: Text("1st")),
                DropdownMenuItem(value: "2nd", child: Text("2nd")),
                DropdownMenuItem(value: "3rd", child: Text("3rd")),
                DropdownMenuItem(value: "4th", child: Text("4th")),
                DropdownMenuItem(value: "5th", child: Text("5th")),
                DropdownMenuItem(value: "6th", child: Text("6th")),
                DropdownMenuItem(value: "7th", child: Text("7th")),
                DropdownMenuItem(value: "8th", child: Text("8th")),
                DropdownMenuItem(value: "9th", child: Text("9th")),
              ],
              onChanged: (value) {
                setState(() {
                  sectionName = "A";
                  semisterName = value!;
                  saveSemister(value);
                });
              },
            ),
          ),
          SizedBox(width: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton(
              value: sectionName,
              style: TextStyle(color: Colors.white, fontSize: 18),
              iconSize: 35,
              iconEnabledColor: Colors.white,
              dropdownColor: Colors.deepPurple,
              items:
                  secList.map<DropdownMenuItem<String>>((ele) {
                    return DropdownMenuItem(value: ele, child: Text(ele));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  sectionName = value!;
                  saveSection(value);
                });
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            isNetAvailable
                ? isLoading
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Updating", style: TextStyle(color: Colors.green)),
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(),
                        ),
                        Text("Routine", style: TextStyle(color: Colors.green)),
                      ],
                    )
                    : SizedBox()
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Network Not Available . Showing in offline mode .",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
            Expanded(
              child:
                  data.isEmpty
                      ? Center(child: Text("No Class Found"))
                      : ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return MyCard(data: data[index]);
                        },
                      ),
            ),
            GestureDetector(
              onTap: () async {
                const url = "fb://profile/100077018623838";
                const url1 = "https://www.facebook.com/sh.seam.0";
                try {
                  bool launched = await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                  if (!launched) {
                    await launchUrl(
                      Uri.parse(url1),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                } catch (e) {
                  await launchUrl(
                    Uri.parse(url1),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "M A D E",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "B Y",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "S E A M",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String addTime(String startTime, {String duration = "01:25"}) {
  // Parse start time
  final timeParts = startTime.split(' '); // ["10:25", "AM"]
  final hm = timeParts[0].split(':'); // ["10", "25"]
  int hour = int.parse(hm[0]);
  int minute = int.parse(hm[1]);
  String period = timeParts[1].toUpperCase();

  // Convert to 24-hour format
  if (period == 'PM' && hour != 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;

  // Parse duration
  final durParts = duration.split(':'); // ["01","25"]
  int durHour = int.parse(durParts[0]);
  int durMinute = int.parse(durParts[1]);

  // Add duration
  hour += durHour;
  minute += durMinute;

  // Handle minute overflow
  if (minute >= 60) {
    hour += minute ~/ 60;
    minute = minute % 60;
  }

  // Convert back to 12-hour format
  period = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) hour = 12;

  // Format minutes with leading zero
  String minuteStr = minute.toString().padLeft(2, '0');

  return '$hour:$minuteStr $period';
}

class MyCard extends StatelessWidget {
  const MyCard({super.key, required this.data});
  final List<String> data;
  final Color color = Colors.white;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${data[2]} - ${addTime(data[2])}",
              style: TextStyle(color: color, fontSize: 18),
            ),

            SizedBox(width: double.infinity, height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Course", style: TextStyle(color: color)),
                Text(data[1], style: TextStyle(color: color)),
              ],
            ),
            for (String n in data[0].split(","))
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Teacher", style: TextStyle(color: color)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(n, style: TextStyle(color: color)),
                      Row(
                        children: [
                          GestureDetector(
                            child: Icon(Icons.copy, color: color),
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: (findTeacher(n) ?? "Not Found"),
                                ),
                              );
                              toast(context, "${teacherData[n]}");
                            },
                          ),
                          Text(
                            (findTeacher(n) ?? "Not Found"),
                            style: TextStyle(color: color, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Room", style: TextStyle(color: color)),
                Text(
                  data[3].replaceAll("Room: ", ""),
                  style: TextStyle(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
