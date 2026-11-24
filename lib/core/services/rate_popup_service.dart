import 'package:shared_preferences/shared_preferences.dart';

import '../constants/pref_keys.dart';

class RatePopupService {
  RatePopupService._();

  static const int paintingsRequired = 3;
  static const Duration retryDelay = Duration(days: 7);

  static Future<bool> onPaintingCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(PrefKeys.ratePopupAccepted) ?? false) {
      return false;
    }

    final count =
        (prefs.getInt(PrefKeys.ratePopupCompletedCount) ?? 0) + 1;

    await prefs.setInt(
      PrefKeys.ratePopupCompletedCount,
      count,
    );

    if (count < paintingsRequired) {
      return false;
    }

    final lastShownText =
    prefs.getString(PrefKeys.ratePopupLastShown);

    if (lastShownText != null) {
      final lastShown = DateTime.tryParse(lastShownText);

      if (lastShown != null &&
          DateTime.now().difference(lastShown) < retryDelay) {
        return false;
      }
    }

    // Gösterim kaydedilir ve yeni boyamalar için sayaç sıfırlanır.
    await prefs.setString(
      PrefKeys.ratePopupLastShown,
      DateTime.now().toIso8601String(),
    );

    await prefs.setInt(
      PrefKeys.ratePopupCompletedCount,
      0,
    );

    return true;
  }

  static Future<void> markAccepted() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      PrefKeys.ratePopupAccepted,
      true,
    );
  }
}
