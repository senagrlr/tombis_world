import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/services/background_music_service.dart';
import '../../../core/services/button_sound_service.dart';
import '../models/settings_state.dart';
import '../models/setting_key.dart';
import '../repositories/settings_repository.dart';

final settingsProvider =
AsyncNotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);

class SettingsController extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final repository = ref.watch(settingsRepositoryProvider);

    var settings = await repository.loadSettings();

    // Kayıtlı ses ayarlarını uygula.
    await ButtonSoundService.setEnabled(settings.sound);
    await BackgroundMusicService.setEnabled(settings.music);

    if (settings.notification) {
      final hasPermission =
      await NotificationService.instance.hasPermission();

      if (!hasPermission) {
        settings = settings.copyWith(notification: false);

        await repository.saveSetting(
          SettingKey.notification,
          false,
        );

        await NotificationService.instance
            .cancelDailyNotifications();
      }
    }

    return settings;
  }

  Future<void> updateSetting(SettingKey key, bool value) async {
    final current = state.asData?.value;

    if (current == null) {
      return;
    }

    final repository = ref.read(settingsRepositoryProvider);

    if (key == SettingKey.notification) {
      final notificationService = NotificationService.instance;

      if (value) {
        var hasPermission =
        await notificationService.hasPermission();

        if (!hasPermission) {
          hasPermission =
          await notificationService.requestPermission();
        }

        if (!hasPermission) {
          state = AsyncData(
            current.copyWith(notification: false),
          );

          await repository.saveSetting(
            SettingKey.notification,
            false,
          );

          return;
        }

        await notificationService.scheduleDailyNotifications();
      } else {
        await notificationService.cancelDailyNotifications();
      }
    }

    // Music ayarı
    if (key == SettingKey.music) {
      await BackgroundMusicService.setEnabled(value);
    }

    // Sound ayarı
    if (key == SettingKey.sound) {
      await ButtonSoundService.setEnabled(value);
    }

    final updated = switch (key) {
      SettingKey.music => current.copyWith(music: value),
      SettingKey.sound => current.copyWith(sound: value),
      SettingKey.notification =>
          current.copyWith(notification: value),
    };

    state = AsyncData(updated);

    await repository.saveSetting(key, value);
  }
}
