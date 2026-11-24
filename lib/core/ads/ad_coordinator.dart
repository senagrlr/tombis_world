
import 'package:flutter/foundation.dart';

import 'ad_availability.dart';
import 'ad_initializer.dart';
import 'ad_frequency_controller.dart';
import 'interstitial_ad_service.dart';
import 'rewarded_ad_service.dart';

class AdCoordinator {
  AdCoordinator({
    required AdAvailability availability,
    required AdFrequencyController frequency,
    required InterstitialAdService interstitial,
    required RewardedAdService rewarded,
    required Future<void> Function() initializeSdk,
  })  : _availability = availability,
        _frequency = frequency,
        _interstitial = interstitial,
        _rewarded = rewarded,
        _initializeSdk = initializeSdk;

  static final AdCoordinator instance = AdCoordinator(
    availability: AdAvailability.instance,
    frequency: AdFrequencyController.instance,
    interstitial: InterstitialAdService.instance,
    rewarded: RewardedAdService.instance,
    initializeSdk: AdInitializer.initialize,
  );

  final AdAvailability _availability;
  final AdFrequencyController _frequency;
  final InterstitialAdService _interstitial;
  final RewardedAdService _rewarded;
  final Future<void> Function() _initializeSdk;

  bool _isFullScreenAdInProgress = false;

  Future<void>? _initializationOperation;

  bool get isBusy =>
      _isFullScreenAdInProgress ||
          _interstitial.isShowing ||
          _rewarded.isShowing;

  bool get _canShowAds =>
      _availability.canLoadAds &&
          _frequency.isAppActive &&
          !isBusy;

  bool get isRewardedReady =>
      _canShowAds && _rewarded.isReady;

  Future<void> initialize() {
    return _initializationOperation ??=
        _initializeInternal().whenComplete(() {
          _initializationOperation = null;
        });
  }

  Future<void> _initializeInternal() async {
    await _initializeSdk();
    await preloadAds();
  }

  Future<void> preloadAds() async {
    if (!_availability.canLoadAds) return;

    await Future.wait([
      _interstitial.loadAd(),
      _rewarded.loadAd(),
    ]);
  }

  void registerNavigation() {
    _frequency.registerNavigation();
  }

  void setColoringActive(bool active) {
    _frequency.setColoringActive(active);
  }

  Future<bool> showInterstitialAtNaturalBreak({
    bool Function()? isStillAtNaturalBreak,
  }) async {
    if (!_canShowAds || !_frequency.isEligible) {
      return false;
    }

    if (!_interstitial.isReady) {
      await _interstitial.loadAd();
      return false;
    }

    return _runFullScreenAd(
          () => _interstitial.showAd(
        onAdShown: _frequency.onAdShown,
        canPresentAd: () {
          return _frequency.isAppActive &&
              !_frequency.isColoring &&
              (isStillAtNaturalBreak?.call() ?? true);
        },
      ),
    );
  }

  Future<bool> showRewarded({
    required VoidCallback onRewardEarned,
  }) async {
    if (!_canShowAds || _frequency.isColoring) {
      return false;
    }

    if (!_rewarded.isReady) {
      await _rewarded.loadAd();
      return false;
    }

    return _runFullScreenAd(
          () => _rewarded.showAd(
        onRewardEarned: onRewardEarned,
        onAdShown: _frequency.onAdShown,
        canPresentAd: () {
          return _frequency.isAppActive &&
              !_frequency.isColoring;
        },
      ),
    );
  }

  Future<bool> _runFullScreenAd(
      Future<bool> Function() showAd,
      ) async {
    if (!_canShowAds) return false;

    _isFullScreenAdInProgress = true;
    _frequency.setAdShowing(true);

    try {
      return await showAd();
    } catch (error) {
      debugPrint('AdCoordinator show error: $error');
      return false;
    } finally {
      _frequency.setAdShowing(false);
      _isFullScreenAdInProgress = false;
    }
  }
}
