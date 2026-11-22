import 'package:shared_preferences/shared_preferences.dart';

class RatePopupService {
  RatePopupService._();

  static const int paintingsRequired = 3;
  static const Duration retryDelay = Duration(days: 7);

  static const String _countKey = 'rate_popup_completed_count';
  static const String _lastShownKey = 'rate_popup_last_shown';
  static const String _acceptedKey = 'rate_popup_accepted';

  static Future<bool> onPaintingCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_acceptedKey) ?? false) {
      return false;
    }

    final count = (prefs.getInt(_countKey) ?? 0) + 1;
    await prefs.setInt(_countKey, count);

    if (count < paintingsRequired) {
      return false;
    }

    final lastShownText = prefs.getString(_lastShownKey);

    if (lastShownText != null) {
      final lastShown = DateTime.tryParse(lastShownText);

      if (lastShown != null &&
          DateTime.now().difference(lastShown) < retryDelay) {
        return false;
      }
    }

    // Gösterim kaydedilir ve yeni boyamalar için sayaç sıfırlanır.
    await prefs.setString(
      _lastShownKey,
      DateTime.now().toIso8601String(),
    );

    await prefs.setInt(_countKey, 0);

    return true;
  }

  static Future<void> markAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_acceptedKey, true);
  }
}
