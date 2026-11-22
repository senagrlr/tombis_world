
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/controllers/settings_controller.dart';
import 'notification_service.dart';

class NotificationStartupService {
  NotificationStartupService._();

  static Future<void> initialize(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();

    final notificationService = NotificationService.instance;

    final permissionAsked =
        prefs.getBool('notification_permission_asked') ?? false;

    if (!permissionAsked) {
      final granted = await notificationService.requestPermission();

      await prefs.setBool('notification_permission_asked', true);

      if (!ref.context.mounted) return;

      await ref.read(settingsProvider.future);

      if (!ref.context.mounted) return;

      await ref
          .read(settingsProvider.notifier)
          .updateSetting('notification', granted);

      return;
    }

    final settings = await ref.read(settingsProvider.future);

    if (!ref.context.mounted) return;

    if (settings.notification &&
        await notificationService.hasPermission()) {
      await notificationService.scheduleDailyNotifications();
    }
  }
}
