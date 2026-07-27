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
            Card(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
              child: CText("Step 1 : Visit class routine website in any browser.\nStep 2 : Download the routine page.\nStep 3 : Upload the downloaded file in app."),
            ),),

            CText("Developer"),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text("MD. Seam"),
                    subtitle: Text("Developer"),
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
