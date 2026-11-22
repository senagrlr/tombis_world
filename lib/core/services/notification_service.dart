import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

import '../notifications/notification_messages.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static const int _notificationIdStart = 1000;
  static const int _scheduledDays = 30;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    final timezone = await FlutterTimezone.getLocalTimezone();
    final timezoneName = timezone.identifier;

    const timezoneAliases = {
      'GMT': 'Etc/GMT',
      'UTC': 'Etc/UTC',
      'Etc/UTC': 'Etc/UTC',
    };

    final resolvedTimezone =
        timezoneAliases[timezoneName] ?? timezoneName;

    try {
      tz.setLocalLocation(tz.getLocation(resolvedTimezone));
      debugPrint('Notification timezone: ${tz.local.name}');
    } catch (e) {
      debugPrint(
        'Unsupported timezone: $timezoneName. '
            'Using UTC temporarily. Error: $e',
      );

      tz.setLocalLocation(tz.getLocation('Etc/UTC'));
    }

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings: settings);
  }

  Future<bool> requestPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    return await android?.requestNotificationsPermission() ?? false;
  }

  Future<bool> hasPermission() async {
    return await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled() ??
        false;
  }

  Future<void> cancelDailyNotifications() async {
    for (int i = 0; i < _scheduledDays; i++) {
      await _notifications.cancel(id: _notificationIdStart + i);
    }
  }

  Future<void> scheduleDailyNotifications() async {
    await cancelDailyNotifications();

    if (!await hasPermission()) return;

    final random = Random();
    final messages = List<String>.from(NotificationMessages.messages)
      ..shuffle(random);

    final now = tz.TZDateTime.now(tz.local);

    var firstDay = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18,
    );

    if (!firstDay.isAfter(now)) {
      firstDay = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        18,
      );
    }

    for (int i = 0; i < _scheduledDays; i++) {
      if (i > 0 && i % messages.length == 0) {
        final previous = messages.last;
        messages.shuffle(random);

        if (messages.first == previous) {
          final swapIndex = 1 + random.nextInt(messages.length - 1);
          final temp = messages.first;
          messages[0] = messages[swapIndex];
          messages[swapIndex] = temp;
        }
      }

      final scheduledDate = tz.TZDateTime(
        tz.local,
        firstDay.year,
        firstDay.month,
        firstDay.day + i,
        18,
      );

      await _notifications.zonedSchedule(
        id: _notificationIdStart + i,
        title: NotificationMessages.title,
        body: messages[i % messages.length],
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'tombi_daily_notifications',
            'Daily Tombi Notifications',
            channelDescription: 'Daily coloring reminders from Tombi',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode:
        AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
