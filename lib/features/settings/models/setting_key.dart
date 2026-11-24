import '../../../core/constants/pref_keys.dart';

enum SettingKey {
  music(PrefKeys.music),
  sound(PrefKeys.sound),
  notification(PrefKeys.notification);

  const SettingKey(this.prefKey);

  final String prefKey;
}