import 'dart:convert';
import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vu_routine/app/utils/hive_service.dart';
import 'package:vu_routine/app/utils/html_parser.dart';

class TaskController extends GetxController {
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
}
