import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

bool isVersionNewer(String latest, String current) {
  List<int> latestParts =
      latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  List<int> currentParts =
      current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

  for (int i = 0; i < 3; i++) {
    int latestNum = i < latestParts.length ? latestParts[i] : 0;
    int currentNum = i < currentParts.length ? currentParts[i] : 0;
    if (latestNum > currentNum) return true;
    if (latestNum < currentNum) return false;
  }

  return false; // same version
}

Future<void> checkForUpdate(BuildContext context, String currentVersion) async {
  final box = Hive.box('updateBox');

  // If user chose "Don't show again", skip
  if (box.get('dontShowAgain') == true) return;

  try {
    final url = Uri.parse(
      'https://raw.githubusercontent.com/SeamDev/VU-Routine/refs/heads/main/info.json',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      String latestVersion = data['update_version'] ?? "";
      String text = data['text'] ?? "";
      Map<String, dynamic> links = data['update_link'] ?? {};

      // Compare versions (simple string comparison, or parse as int if needed)
      if (isVersionNewer(latestVersion, currentVersion)) {
        if (!context.mounted) return;
        // Show dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Update Available: $latestVersion'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text),
                    SizedBox(height: 16),
                    for (var entry in links.entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            final linkUrl = entry.value.toString();
                            if (await canLaunchUrl(Uri.parse(linkUrl))) {
                              await launchUrl(
                                Uri.parse(linkUrl),
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          child: Text(entry.key),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    box.put('dontShowAgain', true);
                    Navigator.pop(context);
                  },
                  child: Text("Don't Show Again"),
                ),
              ],
            );
          },
        );
      }
    }
  } catch (e) {
    debugPrint("Error checking update: $e");
  }
}
