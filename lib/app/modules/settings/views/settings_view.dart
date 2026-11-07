import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:vu_routine/app/utils/call.dart';
import 'package:vu_routine/app/widgets/custom_text.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CText("General"),
            Card(
              child: Obx(
                () => ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text("Theme Mode"),
                  trailing: DropdownButton<ThemeMode>(
                    value: controller.selectedTheme.value,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text("System"),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text("Light"),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text("Dark"),
                      ),
                    ],
                    onChanged: (mode) {
                      if (mode != null) {
                        controller.changeTheme(mode);
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            CText("# Note"),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                child: CText(
                  "Step 1 : Visit class routine website in any browser.\nStep 2 : Download the routine page.\nStep 3 : Upload the downloaded file in app.",
                ),
              ),
            ),

            CText("Developer"),
            Card(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.tapCount++;

                      controller.tapTimer?.cancel();

                      if (controller.tapCount < 5) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${5 - controller.tapCount} remaining',
                              textAlign: TextAlign.center,
                            ),
                            duration: const Duration(milliseconds: 700),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color.fromARGB(
                              255,
                              87,
                              86,
                              86,
                            ),
                          ),
                        );
                      }

                      controller.tapTimer = Timer(
                        const Duration(seconds: 2),
                        () {
                          controller.tapCount = 0;
                        },
                      );

                      if (controller.tapCount == 5) {
                        controller.tapCount = 0;
                        controller.tapTimer?.cancel();

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();

                        showDialog(
                          context: context,
                          builder: (context) {
                            final textController = TextEditingController();

                            return AlertDialog(
                              title: const Text('Developer Mode'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('You unlocked developer mode!'),
                                  const SizedBox(height: 16),

                                  TextField(
                                    controller: textController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Enter number',
                                      hintText: 'e.g. 12345',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final number = int.tryParse(
                                      textController.text,
                                    );

                                    if (number != null) {
                                      // use number here
                                      controller.setAdmin(number.toString());
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text("MD. Seam"),
                      subtitle: Text("Developer"),
                      trailing: controller.isAdmin.value
                          ? Switch(
                              value: true,
                              onChanged: (value) =>
                                  controller.isAdmin.value = false,
                            )
                          : null,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text("Email"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => sendEmail("shseam01@gmail.com"),
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text("Version"),
                    trailing: Text(controller.version.value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
