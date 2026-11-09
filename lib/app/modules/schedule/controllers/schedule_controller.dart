import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vu_routine/app/modules/settings/controllers/settings_controller.dart';
import 'package:vu_routine/app/utils/hive_service.dart';

import '../../../models/schedule_model.dart';

class ScheduleController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxList<ScheduleModel> schedules = <ScheduleModel>[].obs;
  final RxList<ScheduleModel> filteredSchedules = <ScheduleModel>[].obs;
  final RxBool isLoading = false.obs;

  final selectedFilter = 'Upcoming'.obs;

  RxBool deleting = false.obs;

  SettingsController get settingsController => Get.find<SettingsController>();

  @override
  void onInit() {
    super.onInit();

    fetchSchedules();

    settingsController.isAdmin.value =
        HiveService.get<bool>("isAdmin") ?? false;
  }

  /// 1. READ: Fetch all schedules ordered by date and time
  Future<void> fetchSchedules() async {
    try {
      isLoading.value = true;

      final response = await _supabase
          .from('schedules')
          .select()
          .order('scheduled_at', ascending: true);

      final List<ScheduleModel> fetched = (response as List)
          .map((item) => ScheduleModel.fromJson(item))
          .toList();

      // Update observable list
      schedules.assignAll(fetched);

      // Save to Hive
      await HiveService.save(
        'schedules',
        fetched.map((e) => e.toJson()).toList(),
      );
    } catch (e) {
      debugPrint('Fetch schedules error: $e');

      Get.snackbar(
        'Connection Error',
        'Failed to load schedules. Showing saved data.',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      // Load cached data if network fetch failed
      if (schedules.isEmpty) {
        final savedData = await HiveService.get('schedules');

        if (savedData != null) {
          schedules.assignAll(
            (savedData as List)
                .map(
                  (item) =>
                      ScheduleModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList(),
          );
        }
      }

      isLoading.value = false;
    }
  }

  /// 2. INSERT: Add new schedule with extra field `adminKey`
  Future<void> addSchedule({
    required String topic,
    required String detail,
    required DateTime scheduledAt,
    required bool hasSpecificTime,
  }) async {
    try {
      isLoading.value = true;

      await _supabase.rpc(
        'insert_schedule_with_key',
        params: {
          'p_key': settingsController.pKey.trim(),
          'p_topic': topic,
          'p_detail': detail,
          'p_scheduled_at': scheduledAt.toUtc().toIso8601String(),
          'p_has_specific_time': hasSpecificTime,
        },
      );

      await fetchSchedules();
      Get.back(); // Close bottom sheet
      Get.snackbar(
        'Success',
        'Schedule added & global notification triggered!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4238FF),
        colorText: Colors.white,
      );
    } on PostgrestException catch (e) {
      Get.snackbar(
        'Access Denied',
        e.message, // Shows "Invalid Admin Key! Operation denied." if key != 1234
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not add schedule: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 3. UPDATE: Edit existing schedule with extra field `adminKey`
  Future<void> updateSchedule({
    required String id,
    required String topic,
    required String detail,
    required DateTime scheduledAt,
    required bool hasSpecificTime,
  }) async {
    try {
      isLoading.value = true;

      await _supabase.rpc(
        'update_schedule_with_key',
        params: {
          'p_key': settingsController.pKey.trim(),
          'p_id': id,
          'p_topic': topic,
          'p_detail': detail,
          'p_scheduled_at': scheduledAt.toUtc().toIso8601String(),
          'p_has_specific_time': hasSpecificTime,
        },
      );

      await fetchSchedules();
      Get.back(); // Close bottom sheet
      Get.snackbar(
        'Updated',
        'Schedule updated successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4238FF),
        colorText: Colors.white,
      );
    } on PostgrestException catch (e) {
      Get.snackbar(
        'Access Denied',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not update schedule: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 4. DELETE: Delete schedule with extra field `adminKey`
  Future<void> deleteSchedule({required String id}) async {
    try {
      isLoading.value = true;

      await _supabase.rpc(
        'delete_schedule_with_key',
        params: {'p_key': settingsController.pKey.trim(), 'p_id': id},
      );

      await fetchSchedules();
      Get.back(); // Close delete dialog
      Get.snackbar(
        'Deleted',
        'Schedule removed successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } on PostgrestException catch (e) {
      Get.snackbar(
        'Access Denied',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete schedule: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Groups schedules by calendar date (YYYY-MM-DD) for the left-side timeline
  Map<DateTime, List<ScheduleModel>> get groupedSchedules {
    final Map<DateTime, List<ScheduleModel>> map = {};
    for (final item in filteredSchedules) {
      final dateKey = DateTime(
        item.scheduledAt.year,
        item.scheduledAt.month,
        item.scheduledAt.day,
      );
      if (!map.containsKey(dateKey)) {
        map[dateKey] = [];
      }
      map[dateKey]!.add(item);
    }
    return map;
  }

  /// Opens clicked URLs from the detail dialog
  Future<void> openUrl(String rawUrl) async {
    final formatted = rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl';
    final Uri uri = Uri.parse(formatted);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Could not open $rawUrl');
    }
  }
}
