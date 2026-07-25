import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/task_controller.dart';

class TaskView extends GetView<TaskController> {
  const TaskView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TaskController());

    return Scaffold(
      appBar: AppBar(title: const Text('TaskView'), centerTitle: true),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => controller.updateInfo(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Update Routine"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 25, 179, 102),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(130, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
