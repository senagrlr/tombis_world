
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_availability.dart';
import 'ad_config.dart';
import 'base_fullscreen_ad_service.dart';

class InterstitialAdService
    extends BaseFullscreenAdService<InterstitialAd> {
  InterstitialAdService({
    required super.canLoadAds,
    required super.canRequestAds,
    super.now,
  });

  static final InterstitialAdService instance =
  InterstitialAdService(
    canLoadAds: () =>
    AdAvailability.instance.canLoadAds,
    canRequestAds: () =>
        ConsentInformation.instance.canRequestAds(),
  );

  @override
  String get adName => 'Interstitial';

  @override
  Future<void> requestAd({
    required void Function(InterstitialAd ad) onLoaded,
    required void Function(Object error) onFailed,
  }) {
    return InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: onFailed,
      ),
    );
  }


  Future<bool> showAd({
    VoidCallback? onAdShown,
    bool Function()? canPresentAd,
  }) {
    return showCachedAd(
      onAdShown: onAdShown,
      canPresentAd: canPresentAd,
      presentAd: (ad, onShown, onDismissed, onFailed) {
        ad.fullScreenContentCallback =
            FullScreenContentCallback<InterstitialAd>(
              onAdShowedFullScreenContent: (_) {
                onShown();
              },
              onAdDismissedFullScreenContent: (_) {
                onDismissed();
              },
              onAdFailedToShowFullScreenContent: (_, error) {
                onFailed(error);
              },
            );

        return ad.show();
      },
    );
  }


  @override
  Future<void> disposeAd(InterstitialAd ad) {
    return ad.dispose();
  }
}
