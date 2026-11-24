import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/controllers/settings_controller.dart';
import '../../features/settings/models/setting_key.dart';
import '../../features/settings/repositories/settings_repository.dart';
import 'notification_service.dart';

class NotificationStartupService {
  NotificationStartupService._();

  static Future<void> initialize(WidgetRef ref) async {
    final repository = ref.read(settingsRepositoryProvider);

    final notificationService = NotificationService.instance;

    final permissionAsked =
    await repository.hasAskedNotificationPermission();

    if (!ref.context.mounted) return;

    if (!permissionAsked) {
      final granted = await notificationService.requestPermission();

      await repository.markNotificationPermissionAsked();

      if (!ref.context.mounted) return;

      await ref.read(settingsProvider.future);

      if (!ref.context.mounted) return;

      await ref
          .read(settingsProvider.notifier)
          .updateSetting(SettingKey.notification, granted);

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
