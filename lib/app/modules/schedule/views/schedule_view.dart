import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/schedule_model.dart';
import '../controllers/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─────────────────────────────────────
            // HEADER
            // ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Timeline Schedule',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // FILTER
                      Obx(
                        () => PopupMenuButton<String>(
                          initialValue: controller.selectedFilter.value,
                          onSelected: (value) {
                            controller.selectedFilter.value = value;
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          offset: const Offset(0, 50),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'Upcoming',
                              child: Row(
                                children: [
                                  Icon(Icons.upcoming_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text('Upcoming'),
                                ],
                              ),
                            ),

                            PopupMenuItem(
                              value: 'Past',
                              child: Row(
                                children: [
                                  Icon(Icons.history_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text('Past'),
                                ],
                              ),
                            ),

                            PopupMenuItem(
                              value: 'All',
                              child: Row(
                                children: [
                                  Icon(Icons.list_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text('All'),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDEEF8),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.filter_list_rounded,
                              color: Color(0xFF5148F5),
                              size: 22,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // ADD
                      Obx(() {
                        return controller.settingsController.isAdmin.value
                            ? IconButton(
                                onPressed: () {
                                  _showAddScheduleDialog(context, controller);
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF5148F5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(12),
                                ),
                                icon: const Icon(Icons.add_rounded),
                              )
                            : SizedBox();
                      }),
                    ],
                  ),
                ],
              ),
            ),
            // ─────────────────────────────────────
            // SCHEDULES
            // ─────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.schedules.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF5148F5)),
                  );
                }
                final now = DateTime.now();

                controller.filteredSchedules.value =
                    switch (controller.selectedFilter.value) {
                      'Past' =>
                        controller.schedules
                            .where((item) => item.scheduledAt.isBefore(now))
                            .toList(),

                      'All' => controller.schedules.toList(),

                      _ =>
                        controller.schedules
                            .where(
                              (item) =>
                                  item.scheduledAt.isAfter(now) ||
                                  item.scheduledAt.isAtSameMomentAs(now),
                            )
                            .toList(),
                    };

                final grouped = controller.groupedSchedules;

                if (grouped.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_note_rounded,
                            size: 60,
                            color: Color(0xFF5148F5),
                          ),

                          SizedBox(height: 16),

                          Text(
                            'No Upcoming Schedules',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF20222D),
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Tap the + button to add a schedule.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8D94A5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final dates = grouped.keys.toList();

                return RefreshIndicator(
                  color: const Color(0xFF5148F5),
                  onRefresh: controller.fetchSchedules,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: dates.length,
                    itemBuilder: (context, dateIndex) {
                      final date = dates[dateIndex];
                      final items = grouped[date]!;

                      return Column(
                        children: [
                          ...List.generate(items.length, (index) {
                            final item = items[index];

                            return _scheduleCard(
                              context,
                              controller,
                              item,
                              date,
                              index == 0,
                            );
                          }),
                        ],
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SCHEDULE CARD
  // ─────────────────────────────────────────────

  Widget _scheduleCard(
    BuildContext context,
    ScheduleController controller,
    ScheduleModel item,
    DateTime date,
    bool isFirst,
  ) {
    final bool highlighted = isFirst && item.hasSpecificTime;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DATE
          SizedBox(
            width: 48,
            child: isFirst
                ? Column(
                    children: [
                      const SizedBox(height: 10),

                      Text(
                        DateFormat('dd').format(date),
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        DateFormat('EEE').format(date).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 165, 174, 197),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),

          // SIMPLE TIMELINE DOT
          SizedBox(
            width: 24,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: highlighted ? const Color(0xFF5148F5) : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // CARD
          Expanded(
            child: GestureDetector(
              onTap: () {
                _showScheduleDetails(context, item);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: highlighted
                      ? const LinearGradient(
                          colors: [Color(0xFF6259FF), Color(0xFF4238ED)],
                        )
                      : null,
                  color: highlighted ? null : const Color(0xFFEDEEF3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: highlighted
                      ? [
                          BoxShadow(
                            color: const Color(0xFF5148F5)
                                .withValues(alpha: 0.22),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.topic,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: highlighted
                              ? Colors.white
                              : const Color(0xFF4D5062),
                        ),
                      ),
                    ),

                    if (item.hasSpecificTime) ...[
                      const SizedBox(width: 10),

                      Text(
                        DateFormat('h:mm a').format(item.scheduledAt),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: highlighted
                              ? Colors.white
                              : const Color(0xFF74788A),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // READ / DETAILS
  // ─────────────────────────────────────────────

  void _showScheduleDetails(BuildContext context, ScheduleModel item) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.event_note_rounded,
                      color: Color(0xFF5148F5),
                      size: 26,
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        item.topic,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 17,
                      color: Color(0xFF5148F5),
                    ),
                    const SizedBox(width: 7),

                    Expanded(
                      child: Text(
                        item.hasSpecificTime
                            ? DateFormat('EEE, dd MMM yyyy • h:mm a')
                                  .format(item.scheduledAt)
                            : DateFormat('EEE, dd MMM yyyy')
                                  .format(item.scheduledAt),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5148F5),
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 30, color: Color(0xFFECEEF4)),

                Text(
                  item.detail.isEmpty
                      ? 'No additional details provided.'
                      : item.detail,
                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),

                const SizedBox(height: 25),

                Obx(() {
                  return controller.settingsController.isAdmin.value
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Get.back();

                                  _showEditScheduleDialog(
                                    context,
                                    controller,
                                    item,
                                  );
                                },
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF5148F5),
                                  side: const BorderSide(
                                    color: Color(0xFF5148F5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showDeleteConfirmDialog(
                                    context,
                                    controller,
                                    item,
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                ),
                                label: const Text('Delete'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFE9E9),
                                  foregroundColor: const Color(0xFFE53935),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox();
                }),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Color(0xFF777C8C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ─────────────────────────────────────────────
  // ADD SCHEDULE
  // ─────────────────────────────────────────────

  void _showAddScheduleDialog(
    BuildContext context,
    ScheduleController controller,
  ) {
    final topicController = TextEditingController();
    final detailController = TextEditingController();

    DateTime selectedDateTime = DateTime.now();
    bool includeTime = true;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Add New Schedule',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // TOPIC
                    TextField(
                      controller: topicController,
                      decoration: InputDecoration(
                        labelText: 'Topic',
                        hintText: 'e.g. Meeting with Alex',
                        prefixIcon: const Icon(Icons.title_rounded),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // DETAILS
                    TextField(
                      controller: detailController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Details & Links',
                        hintText: 'https://...',
                        alignLabelWithHint: true,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // TIME SWITCH
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Use specific time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: includeTime,
                      //activeThumbColor: const Color(0xFF5148F5),
                      onChanged: (value) {
                        setState(() {
                          includeTime = value;
                        });
                      },
                    ),

                    const SizedBox(height: 4),

                    // DATE
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Color(0xFFE0E3ED)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.calendar_month_rounded,
                        color: Color(0xFF5148F5),
                      ),
                      label: Text(
                        includeTime
                            ? DateFormat('EEE, dd MMM yyyy • h:mm a')
                                  .format(selectedDateTime)
                            : DateFormat('EEE, dd MMM yyyy')
                                  .format(selectedDateTime),
                        style: const TextStyle(
                          //color: Color(0xFF252733),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDateTime,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2035),
                        );

                        if (date == null) return;

                        if (includeTime && context.mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              selectedDateTime,
                            ),
                          );

                          if (time != null) {
                            setState(() {
                              selectedDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        } else {
                          setState(() {
                            selectedDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                            );
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // ADD
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5148F5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          if (topicController.text.trim().isEmpty) {
                            Get.snackbar('Required', 'Please enter a topic');
                            return;
                          }

                          controller.addSchedule(
                            topic: topicController.text.trim(),
                            detail: detailController.text.trim(),
                            scheduledAt: selectedDateTime,
                            hasSpecificTime: includeTime,
                          );

                          Get.back();
                        },
                        child: const Text(
                          'Add Schedule',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showEditScheduleDialog(
    BuildContext context,
    ScheduleController controller,
    ScheduleModel item,
  ) {
    final topicController = TextEditingController(text: item.topic);

    final detailController = TextEditingController(text: item.detail);

    DateTime selectedDateTime = item.scheduledAt;
    bool includeTime = item.hasSpecificTime;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Edit Schedule',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: topicController,
                      decoration: InputDecoration(
                        labelText: 'Topic',
                        prefixIcon: const Icon(Icons.title_rounded),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: detailController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Details & Links',
                        alignLabelWithHint: true,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const SizedBox(height: 8),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Use specific time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: includeTime,
                      onChanged: (value) {
                        setState(() {
                          includeTime = value;
                        });
                      },
                    ),

                    const SizedBox(height: 4),

                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Color(0xFFE0E3ED)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.calendar_month_rounded,
                        color: Color(0xFF5148F5),
                      ),
                      label: Text(
                        includeTime
                            ? DateFormat('EEE, dd MMM yyyy • h:mm a')
                                  .format(selectedDateTime)
                            : DateFormat('EEE, dd MMM yyyy')
                                  .format(selectedDateTime),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDateTime,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2035),
                        );

                        if (date == null) return;

                        if (includeTime && context.mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              selectedDateTime,
                            ),
                          );

                          if (time != null) {
                            setState(() {
                              selectedDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        } else {
                          setState(() {
                            selectedDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                            );
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5148F5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          if (topicController.text.trim().isEmpty) {
                            Get.snackbar('Required', 'Please enter a topic');
                            return;
                          }

                          controller.updateSchedule(
                            id: item.id,
                            topic: topicController.text.trim(),
                            detail: detailController.text.trim(),
                            scheduledAt: selectedDateTime,
                            hasSpecificTime: includeTime,
                          );

                          Get.back();
                        },
                        child: const Text(
                          'Update Schedule',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    ScheduleController controller,
    ScheduleModel item,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Schedule?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to delete "${item.topic}"?',
          style: const TextStyle(color: Color(0xFF666B7A), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF777C8C)),
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              controller.deleteSchedule(id: item.id);

              Get.back(); // close confirmation
              Get.back(); // close details dialog
            },
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
