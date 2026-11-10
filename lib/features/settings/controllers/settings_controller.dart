
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider =
AsyncNotifierProvider<SettingsController, Map<String, bool>>(
  SettingsController.new,
);

class SettingsController extends AsyncNotifier<Map<String, bool>> {
  static const defaults = {
    'music': true,
    'sound': true,
    'notification': false,
  };

  @override
  Future<Map<String, bool>> build() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      for (final key in defaults.keys)
        key: prefs.getBool(key) ?? defaults[key]!,
    };
  }

  Future<void> updateSetting(String key, bool value) async {
    final current = state.asData?.value;

    if (current == null || !defaults.containsKey(key)) {
      return;
    }

    state = AsyncData({...current, key: value});

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
