import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'package:vu_routine/app/modules/navbar/controllers/navbar_controller.dart';
import 'package:vu_routine/app/routes/app_pages.dart';

class NotificationService extends GetxService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'all_notifications';
  static const String channelName = 'All Notifications';

  bool _initialized = false;
  bool _listenersRegistered = false;

  // Network error Bypass

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _topicSubscribed = false;
  bool _subscribing = false;

  Future<void> _subscribeToTopic() async {
    if (_topicSubscribed || _subscribing) return;

    _subscribing = true;

    try {
      await FirebaseMessaging.instance
          .subscribeToTopic('tall_users')
          .timeout(const Duration(seconds: 5));

      _topicSubscribed = true;

      debugPrint('Subscribed to all_users');
    } catch (e) {
      debugPrint('Topic subscription failed: $e');
    } finally {
      _subscribing = false;
    }
  }

  // Initialize notifications
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('Notification permission: ${settings.authorizationStatus}');

      // Subscribe to global topic

      unawaited(_subscribeToTopic());

      _connectivitySubscription ??= Connectivity().onConnectivityChanged.listen(
        (results) {
          final connected = results.any(
            (result) => result != ConnectivityResult.none,
          );

          if (connected && !_topicSubscribed) {
            unawaited(_subscribeToTopic());
          }
        },
      );

      // Create Android channel
      const channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: 'VU Routine notifications',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // Initialize local notifications
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('notification'),
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleLocalNotificationTap,
      );

      // Register listeners only once
      if (!_listenersRegistered) {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
          try {
            await _showForegroundNotification(message);
            debugPrint('LOCAL NOTIFICATION DISPLAY REQUEST SENT');
          } catch (e, stackTrace) {
            debugPrint('LOCAL NOTIFICATION ERROR: $e');
            debugPrintStack(stackTrace: stackTrace);
          }
        });

        FirebaseMessaging.onMessageOpenedApp.listen((message) {
          _openSchedulePage();
        });

        _listenersRegistered = true;
      }

      // Terminated app opened from FCM notification
      final initialMessage = await messaging.getInitialMessage();

      if (initialMessage != null) {
        _openSchedulePage();
      }

      // Terminated app opened from local notification
      final launchDetails = await _localNotifications
          .getNotificationAppLaunchDetails();

      if (launchDetails?.didNotificationLaunchApp ?? false) {
        if (launchDetails?.notificationResponse?.payload == 'schedule') {
          _openSchedulePage();
        }
      }

      _initialized = true;

      debugPrint('Notification service initialized');
    } catch (e, stackTrace) {
      debugPrint('Notification initialization error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // Foreground FCM -> Local notification
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    debugPrint('Foreground FCM received: ${message.data}');

    final notification = message.notification;

    await _localNotifications.show(
      message.hashCode,
      notification?.title ?? message.data['title'] ?? 'New Schedule',
      notification?.body ??
          message.data['body'] ??
          'Your schedule has been updated.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'VU Routine notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'schedule',
    );
  }

  // Background data-only notification
  @pragma('vm:entry-point')
  static Future<void> showBackgroundNotification(RemoteMessage message) async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('notification'),
    );

    await _localNotifications.initialize(initializationSettings);

    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'VU Routine notifications',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _localNotifications.show(
      message.hashCode,
      message.data['title'] ?? 'New Schedule',
      message.data['body'] ?? 'Your schedule has been updated.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'VU Routine notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      payload: 'schedule',
    );
  }

  // Local notification tap
  void _handleLocalNotificationTap(NotificationResponse response) {
    if (response.payload == 'schedule') {
      _openSchedulePage();
    }
  }

  // Navigate to Schedule tab
  void _openSchedulePage() {
    if (Get.isRegistered<NavbarController>()) {
      final controller = Get.find<NavbarController>();
      controller.currentIndex.value = 1;
      return;
    }

    // Fallback if NavbarController is not available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<NavbarController>()) {
        Get.find<NavbarController>().currentIndex.value = 1;
      } else {
        Get.offAllNamed(Routes.SCHEDULE);
      }
    });
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    super.onClose();
  }
}
