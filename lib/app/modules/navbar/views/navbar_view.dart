import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vu_routine/app/modules/home/views/home_view.dart';
import 'package:vu_routine/app/modules/settings/views/settings_view.dart';

import '../controllers/navbar_controller.dart';

class NavbarView extends GetView<NavbarController> {
  const NavbarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBody: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeView(),
            SettingsView(),
            //Center(child: Text("Classroom")),
            //Center(child: Text("Chat")),
          ],
        ),

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Get.isDarkMode ? const Color(0xFF23252B) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(icon: Icons.home_rounded, label: "Home", index: 0),
                _item(icon: Icons.settings, label: "Settings", index: 1),
                /*
                _item(
                  icon: Icons.school_rounded,
                  label: "Class",
                  index: 2,
                ),
                _item(
                  icon: Icons.chat_bubble_rounded,
                  label: "Chat",
                  index: 3,
                ),
                */
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = controller.currentIndex.value == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => controller.currentIndex.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                selected
                    ? const Color(0xFF53C68C).withOpacity(.15)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 26,
                color: selected ? const Color(0xFF53C68C) : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? const Color(0xFF53C68C) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
