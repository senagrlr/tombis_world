
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_availability.dart';
import 'ad_consent_service.dart';

class AdInitializer {
  AdInitializer._();

  static Future<void>? _initializationOperation;

  static bool get isInitialized =>
      AdAvailability.instance.isSdkInitialized;

  static bool get canLoadAds =>
      AdAvailability.instance.canLoadAds;

  static Future<void> initialize() {
    if (isInitialized) {
      return Future<void>.value();
    }

    return _initializationOperation ??=
        _initializeInternal().whenComplete(() {
          _initializationOperation = null;
        });
  }

  static Future<void> _initializeInternal() async {
    try {
      final canRequestAds =
      await AdConsentService.instance.gatherConsent();

      if (!canRequestAds) {
        debugPrint(
          'AdMob: Ads cannot be requested yet.',
        );
        return;
      }

      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.g,
        ),
      );

      await MobileAds.instance.initialize();

      AdAvailability.instance.markSdkInitialized();

      debugPrint('AdMob initialization completed.');
    } catch (error) {
      debugPrint('AdMob initialization error: $error');
    }
  }
}
