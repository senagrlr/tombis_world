import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tombis_world/core/constants/pref_keys.dart';
import 'package:tombis_world/features/settings/models/setting_key.dart';
import 'package:tombis_world/features/settings/repositories/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = SettingsRepository();
  });

  group('SettingsRepository', () {
    test('returns correct default settings', () async {
      final settings = await repository.loadSettings();

      expect(settings.music, isTrue);
      expect(settings.sound, isTrue);
      expect(settings.notification, isFalse);
    });

    test('loads previously saved settings', () async {
      SharedPreferences.setMockInitialValues({
        PrefKeys.music: false,
        PrefKeys.sound: false,
        PrefKeys.notification: true,
      });

      final settings = await repository.loadSettings();

      expect(settings.music, isFalse);
      expect(settings.sound, isFalse);
      expect(settings.notification, isTrue);
    });

    test('returns default music setting', () async {
      final value =
      await repository.getSetting(SettingKey.music);

      expect(value, isTrue);
    });

    test('returns default sound setting', () async {
      final value =
      await repository.getSetting(SettingKey.sound);

      expect(value, isTrue);
    });

    test('returns default notification setting', () async {
      final value =
      await repository.getSetting(SettingKey.notification);

      expect(value, isFalse);
    });

    test('saves and reads music setting', () async {
      await repository.saveSetting(SettingKey.music, false);

      expect(
        await repository.getSetting(SettingKey.music),
        isFalse,
      );

      await repository.saveSetting(SettingKey.music, true);

      expect(
        await repository.getSetting(SettingKey.music),
        isTrue,
      );
    });

    test('saves and reads sound setting', () async {
      await repository.saveSetting(SettingKey.sound, false);

      expect(
        await repository.getSetting(SettingKey.sound),
        isFalse,
      );

      await repository.saveSetting(SettingKey.sound, true);

      expect(
        await repository.getSetting(SettingKey.sound),
        isTrue,
      );
    });

    test('saves and reads notification setting', () async {
      await repository.saveSetting(
        SettingKey.notification,
        true,
      );

      expect(
        await repository.getSetting(SettingKey.notification),
        isTrue,
      );

      await repository.saveSetting(
        SettingKey.notification,
        false,
      );

      expect(
        await repository.getSetting(SettingKey.notification),
        isFalse,
      );
    });

    test('updating one setting preserves other settings', () async {
      SharedPreferences.setMockInitialValues({
        PrefKeys.music: true,
        PrefKeys.sound: false,
        PrefKeys.notification: true,
      });

      await repository.saveSetting(SettingKey.music, false);

      final settings = await repository.loadSettings();

      expect(settings.music, isFalse);
      expect(settings.sound, isFalse);
      expect(settings.notification, isTrue);
    });

    test('loadSettings reflects saved changes', () async {
      await repository.saveSetting(SettingKey.music, false);
      await repository.saveSetting(SettingKey.sound, false);
      await repository.saveSetting(
        SettingKey.notification,
        true,
      );

      final settings = await repository.loadSettings();

      expect(settings.music, isFalse);
      expect(settings.sound, isFalse);
      expect(settings.notification, isTrue);
    });

    test('notification permission is not asked by default', () async {
      final asked =
      await repository.hasAskedNotificationPermission();

      expect(asked, isFalse);
    });

    test('marks notification permission as asked', () async {
      await repository.markNotificationPermissionAsked();

      final asked =
      await repository.hasAskedNotificationPermission();

      expect(asked, isTrue);
    });

    test('reads previously saved notification permission flag', () async {
      SharedPreferences.setMockInitialValues({
        PrefKeys.notificationPermissionAsked: true,
      });

      expect(
        await repository.hasAskedNotificationPermission(),
        isTrue,
      );
    });

    test('saved settings survive repository recreation', () async {
      await repository.saveSetting(SettingKey.music, false);
      await repository.saveSetting(SettingKey.sound, false);
      await repository.saveSetting(
        SettingKey.notification,
        true,
      );

      await repository.markNotificationPermissionAsked();

      final newRepository = SettingsRepository();
      final settings = await newRepository.loadSettings();

      expect(settings.music, isFalse);
      expect(settings.sound, isFalse);
      expect(settings.notification, isTrue);

      expect(
        await newRepository.hasAskedNotificationPermission(),
        isTrue,
      );
    });

    test('remains compatible with legacy preference keys', () async {
      SharedPreferences.setMockInitialValues({
        'music': false,
        'sound': false,
        'notification': true,
        'notification_permission_asked': true,
      });

      final settings = await repository.loadSettings();

      expect(settings.music, isFalse);
      expect(settings.sound, isFalse);
      expect(settings.notification, isTrue);

      expect(
        await repository.hasAskedNotificationPermission(),
        isTrue,
      );
    });

    test('writes settings using original preference keys', () async {
      await repository.saveSetting(SettingKey.music, false);
      await repository.saveSetting(SettingKey.sound, false);
      await repository.saveSetting(
        SettingKey.notification,
        true,
      );

      await repository.markNotificationPermissionAsked();

      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getBool('music'), isFalse);
      expect(prefs.getBool('sound'), isFalse);
      expect(prefs.getBool('notification'), isTrue);

      expect(
        prefs.getBool('notification_permission_asked'),
        isTrue,
      );
    });
  });
}
