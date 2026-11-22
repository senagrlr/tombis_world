
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/notification_service.dart';
import '../models/settings_state.dart';

final settingsProvider =
AsyncNotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);

class SettingsController extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();

    var settings = SettingsState(
      music: prefs.getBool('music') ?? true,
      sound: prefs.getBool('sound') ?? true,
      notification: prefs.getBool('notification') ?? false,
    );

    if (settings.notification) {
      final hasPermission =
      await NotificationService.instance.hasPermission();

      if (!hasPermission) {
        settings = settings.copyWith(notification: false);
        await prefs.setBool('notification', false);
        await NotificationService.instance.cancelDailyNotifications();
      }
    }

    return settings;
  }

  Future<void> updateSetting(String key, bool value) async {
    final current = state.asData?.value;

    if (current == null ||
        !const ['music', 'sound', 'notification'].contains(key)) {
      return;
    }

    if (key == 'notification') {
      final notificationService = NotificationService.instance;

      if (value) {
        var hasPermission = await notificationService.hasPermission();

        if (!hasPermission) {
          hasPermission = await notificationService.requestPermission();
        }

        if (!hasPermission) {
          state = AsyncData(
            current.copyWith(notification: false),
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('notification', false);
          return;
        }

        await notificationService.scheduleDailyNotifications();
      } else {
        await notificationService.cancelDailyNotifications();
      }
    }

    final updated = switch (key) {
      'music' => current.copyWith(music: value),
      'sound' => current.copyWith(sound: value),
      'notification' => current.copyWith(notification: value),
      _ => current,
    };

    state = AsyncData(updated);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
