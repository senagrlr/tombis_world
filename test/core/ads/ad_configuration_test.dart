
import 'package:flutter_test/flutter_test.dart';

import 'package:tombis_world/core/ads/ad_config.dart';
import 'package:tombis_world/core/ads/ad_availability.dart';

void main() {
  group('AdConfig', () {
    test('uses official test ad IDs in test environment', () {
      expect(AdConfig.useProductionAds, isFalse);

      expect(
        AdConfig.interstitialAdUnitId,
        'ca-app-pub-3940256099942544/1033173712',
      );

      expect(
        AdConfig.rewardedAdUnitId,
        'ca-app-pub-3940256099942544/5224354917',
      );
    });
  });

  group('AdAvailability', () {
    late bool hasConsent;
    late AdAvailability availability;

    setUp(() {
      hasConsent = false;

      availability = AdAvailability(
        hasConsent: () => hasConsent,
      );
    });

    test('ads cannot load before SDK initialization', () {
      hasConsent = true;

      expect(availability.isSdkInitialized, isFalse);
      expect(availability.canLoadAds, isFalse);
    });

    test('SDK initialization alone does not allow ads', () {
      availability.markSdkInitialized();

      expect(availability.isSdkInitialized, isTrue);
      expect(availability.canLoadAds, isFalse);
    });

    test('ads can load when SDK and consent are ready', () {
      hasConsent = true;
      availability.markSdkInitialized();

      expect(availability.canLoadAds, isTrue);
    });

    test('ad availability follows consent changes', () {
      availability.markSdkInitialized();

      hasConsent = true;
      expect(availability.canLoadAds, isTrue);

      hasConsent = false;
      expect(availability.canLoadAds, isFalse);

      hasConsent = true;
      expect(availability.canLoadAds, isTrue);
    });
  });
}
