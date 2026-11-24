import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/pref_keys.dart';
import '../models/setting_key.dart';
import '../models/settings_state.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
      (ref) => SettingsRepository(),
);

class SettingsRepository {
  Future<SettingsState> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return SettingsState(
      music: prefs.getBool(PrefKeys.music) ?? true,
      sound: prefs.getBool(PrefKeys.sound) ?? true,
      notification:
      prefs.getBool(PrefKeys.notification) ?? false,
    );
  }

  Future<bool> getSetting(SettingKey key) async {
    final prefs = await SharedPreferences.getInstance();

    final defaultValue = switch (key) {
      SettingKey.music => true,
      SettingKey.sound => true,
      SettingKey.notification => false,
    };

    return prefs.getBool(key.prefKey) ?? defaultValue;
  }

  Future<void> saveSetting(
      SettingKey key,
      bool value,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(key.prefKey, value);
  }

  Future<bool> hasAskedNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(
      PrefKeys.notificationPermissionAsked,
    ) ??
        false;
  }

  Future<void> markNotificationPermissionAsked() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      PrefKeys.notificationPermissionAsked,
      true,
    );
  }
}
