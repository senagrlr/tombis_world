
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_availability.dart';
import 'ad_config.dart';
import 'base_fullscreen_ad_service.dart';

class RewardedAdService
    extends BaseFullscreenAdService<RewardedAd> {
  RewardedAdService({
    required super.canLoadAds,
    required super.canRequestAds,
    super.now,
  });

  static final RewardedAdService instance =
  RewardedAdService(
    canLoadAds: () =>
    AdAvailability.instance.canLoadAds,
    canRequestAds: () =>
        ConsentInformation.instance.canRequestAds(),
  );

  @override
  String get adName => 'Rewarded';

  @override
  Future<void> requestAd({
    required void Function(RewardedAd ad) onLoaded,
    required void Function(Object error) onFailed,
  }) {
    return RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: onFailed,
      ),
    );
  }

  Future<bool> showAd({
    required VoidCallback onRewardEarned,
    VoidCallback? onAdShown,
    bool Function()? canPresentAd,
  }) {
    bool rewardEarned = false;

    return showCachedAd(
      onAdShown: onAdShown,
      canPresentAd: canPresentAd,
      presentAd: (
          ad,
          onShown,
          onDismissed,
          onFailed,
          ) {
        ad.fullScreenContentCallback =
            FullScreenContentCallback<RewardedAd>(
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

        return ad.show(
          onUserEarnedReward: (_, reward) {
            if (rewardEarned) return;

            rewardEarned = true;

            debugPrint(
              'Reward earned: ${reward.amount} ${reward.type}',
            );

            try {
              onRewardEarned();
            } catch (error) {
              debugPrint(
                'Rewarded onRewardEarned error: $error',
              );
            }
          },
        );
      },
    );
  }

  @override
  Future<void> disposeAd(RewardedAd ad) {
    return ad.dispose();
  }
}
