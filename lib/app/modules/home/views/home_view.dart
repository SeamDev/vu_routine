import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:vu_routine/app/modules/home/views/schedule_time.dart';
import 'package:vu_routine/app/widgets/custom_text.dart';
import 'package:intl/intl.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: SingleChildScrollView(
            child: Obx(
              () => controller.isLoading.value
                  ? Center(child: SingleChildScrollView())
                  : Column(
                      spacing: 20,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CText(
                                  DateFormat('d MMMM').format(DateTime.now()),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                                CText(
                                  controller.days[controller
                                      .selectedIndex
                                      .value]["label"],
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                                if (controller.selectedIndex.value == 3)
                                  CText(
                                    controller.activeScheduleStatus.value,
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => controller.updateInfo(),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("Upload Routine"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  25,
                                  179,
                                  102,
                                ),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(130, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // week
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(controller.days.length, (
                              index,
                            ) {
                              final selected =
                                  index == controller.selectedIndex.value;

                              return GestureDetector(
                                onTap: () =>
                                    controller.selectedIndex.value = index,
                                behavior: HitTestBehavior.opaque,
                                child: Column(
                                  children: [
                                    Text(
                                      controller.days[index]["day"]!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: selected
                                            ? const Color(0xFF53C68C)
                                            : Colors.grey,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.days[index]["date"]!,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: selected
                                            ? const Color(0xFF53C68C)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      height: 3,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? const Color(0xFF53C68C)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),

                        // Routine
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragEnd: (details) {
                            // Detect swipe direction based on velocity
                            if (details.primaryVelocity! < 0) {
                              // Swipe Right-to-Left (Next)
                              if (controller.selectedIndex.value <
                                  controller.days.length - 1) {
                                controller.selectedIndex.value++;
                              } else {
                                controller.selectedIndex.value = 0;
                              }
                            } else if (details.primaryVelocity! > 0) {
                              // Swipe Left-to-Right (Previous)
                              if (controller.selectedIndex.value > 0) {
                                controller.selectedIndex.value--;
                              } else {
                                controller.selectedIndex.value =
                                    controller.data.length - 1;
                              }
                            }
                          },
                          child: controller.info.isEmpty
                              ? Center(
                                  child: Column(
                                    children: [
                                      Lottie.asset("assets/empty.json"),
                                    ],
                                  ),
                                )
                              : controller.selectedSchedule.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 50,
                                      left: 30,
                                      right: 30,
                                    ),
                                    child: Lottie.asset("assets/vacation.json"),
                                  ),
                                )
                              : ScheduleTimeline(
                                  schedules: controller.selectedSchedule,
                                  activeScheduleIndex:
                                      controller.activeScheduleIndex.value,
                                ),
                        ),

                        //
                        const SizedBox(height: 50),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
