
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tombis_world/core/ads/ad_availability.dart';
import 'package:tombis_world/core/ads/ad_coordinator.dart';
import 'package:tombis_world/core/ads/ad_frequency_controller.dart';
import 'package:tombis_world/core/ads/interstitial_ad_service.dart';
import 'package:tombis_world/core/ads/rewarded_ad_service.dart';

class FakeAdBehavior {
  bool ready = true;
  bool showing = false;
  bool throwOnShow = false;

  int loadCount = 0;
  int showCount = 0;

  VoidCallback? onShown;
  VoidCallback? onReward;
  bool Function()? presentationGuard;

  Completer<bool>? pendingShow;

  Future<void> load() async {
    loadCount++;
  }

  Future<bool> show({
    VoidCallback? onAdShown,
    VoidCallback? onRewardEarned,
    bool Function()? canPresentAd,
  }) async {
    showCount++;

    if (throwOnShow) {
      throw StateError('Show failed');
    }

    onShown = onAdShown;
    onReward = onRewardEarned;
    presentationGuard = canPresentAd;

    final completer = Completer<bool>();
    pendingShow = completer;
    showing = true;

    try {
      return await completer.future;
    } finally {
      showing = false;
      pendingShow = null;
    }
  }

  void finish(bool wasShown) {
    pendingShow!.complete(wasShown);
  }
}

class FakeInterstitialService extends InterstitialAdService {
  FakeInterstitialService()
      : super(
    canLoadAds: () => true,
    canRequestAds: () async => true,
  );

  final behavior = FakeAdBehavior();

  @override
  bool get isReady => behavior.ready;

  @override
  bool get isShowing => behavior.showing;

  @override
  Future<void> loadAd() => behavior.load();

  @override
  Future<bool> showAd({
    VoidCallback? onAdShown,
    bool Function()? canPresentAd,
  }) {
    return behavior.show(
      onAdShown: onAdShown,
      canPresentAd: canPresentAd,
    );
  }
}

class FakeRewardedService extends RewardedAdService {
  FakeRewardedService()
      : super(
    canLoadAds: () => true,
    canRequestAds: () async => true,
  );

  final behavior = FakeAdBehavior();

  @override
  bool get isReady => behavior.ready;

  @override
  bool get isShowing => behavior.showing;

  @override
  Future<void> loadAd() => behavior.load();

  @override
  Future<bool> showAd({
    required VoidCallback onRewardEarned,
    VoidCallback? onAdShown,
    bool Function()? canPresentAd,
  }) {
    return behavior.show(
      onAdShown: onAdShown,
      onRewardEarned: onRewardEarned,
      canPresentAd: canPresentAd,
    );
  }
}

void main() {
  group('AdCoordinator', () {
    late AdCoordinator coordinator;
    late AdAvailability availability;
    late AdFrequencyController frequency;

    late FakeInterstitialService interstitial;
    late FakeRewardedService rewarded;

    late bool hasConsent;
    late int initializationCount;

    Completer<void>? initializationGate;

    setUp(() {
      hasConsent = true;
      initializationCount = 0;
      initializationGate = null;

      availability = AdAvailability(
        hasConsent: () => hasConsent,
      );

      availability.markSdkInitialized();

      frequency = AdFrequencyController();

      frequency.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );

      interstitial = FakeInterstitialService();
      rewarded = FakeRewardedService();

      coordinator = AdCoordinator(
        availability: availability,
        frequency: frequency,
        interstitial: interstitial,
        rewarded: rewarded,
        initializeSdk: () async {
          initializationCount++;

          if (initializationGate != null) {
            await initializationGate!.future;
          }
        },
      );
    });

    tearDown(() {
      frequency.dispose();
      interstitial.dispose();
      rewarded.dispose();
    });

    void makeEligible() {
      for (var i = 0; i < 6; i++) {
        coordinator.registerNavigation();
      }
    }

    Future<bool> showRewarded() {
      return coordinator.showRewarded(
        onRewardEarned: () {},
      );
    }

    test('concurrent initialization initializes and preloads only once',
            () async {
          initializationGate = Completer<void>();

          final first = coordinator.initialize();
          final second = coordinator.initialize();

          expect(first, same(second));
          expect(initializationCount, 1);

          initializationGate!.complete();

          await Future.wait([first, second]);

          expect(interstitial.behavior.loadCount, 1);
          expect(rewarded.behavior.loadCount, 1);
        });

    test('preloading and showing are blocked without consent', () async {
      hasConsent = false;
      makeEligible();

      await coordinator.preloadAds();

      expect(interstitial.behavior.loadCount, 0);
      expect(rewarded.behavior.loadCount, 0);

      expect(
        await coordinator.showInterstitialAtNaturalBreak(),
        isFalse,
      );

      expect(await showRewarded(), isFalse);
      expect(coordinator.isRewardedReady, isFalse);

      expect(interstitial.behavior.showCount, 0);
      expect(rewarded.behavior.showCount, 0);
    });

    test('interstitial requires eligibility but rewarded does not', () async {
      expect(frequency.isEligible, isFalse);

      expect(
        await coordinator.showInterstitialAtNaturalBreak(),
        isFalse,
      );

      expect(interstitial.behavior.showCount, 0);

      final result = showRewarded();

      expect(rewarded.behavior.showCount, 1);

      rewarded.behavior.finish(true);

      expect(await result, isTrue);
    });

    test('both ad types are blocked during coloring and background',
            () async {
          makeEligible();

          coordinator.setColoringActive(true);

          expect(
            await coordinator.showInterstitialAtNaturalBreak(),
            isFalse,
          );

          expect(await showRewarded(), isFalse);

          coordinator.setColoringActive(false);

          frequency.didChangeAppLifecycleState(
            AppLifecycleState.paused,
          );

          expect(
            await coordinator.showInterstitialAtNaturalBreak(),
            isFalse,
          );

          expect(await showRewarded(), isFalse);

          expect(interstitial.behavior.showCount, 0);
          expect(rewarded.behavior.showCount, 0);
        });

    test('unavailable ads are loaded instead of being presented', () async {
      makeEligible();

      interstitial.behavior.ready = false;
      rewarded.behavior.ready = false;

      expect(
        await coordinator.showInterstitialAtNaturalBreak(),
        isFalse,
      );

      expect(await showRewarded(), isFalse);

      expect(interstitial.behavior.loadCount, 1);
      expect(rewarded.behavior.loadCount, 1);

      expect(interstitial.behavior.showCount, 0);
      expect(rewarded.behavior.showCount, 0);

      expect(coordinator.isBusy, isFalse);
    });

    test('interstitial presentation guard follows current route and state',
            () async {
          makeEligible();

          var atNaturalBreak = true;

          final result = coordinator.showInterstitialAtNaturalBreak(
            isStillAtNaturalBreak: () => atNaturalBreak,
          );

          final guard = interstitial.behavior.presentationGuard!;

          expect(guard(), isTrue);

          atNaturalBreak = false;
          expect(guard(), isFalse);

          atNaturalBreak = true;
          coordinator.setColoringActive(true);
          expect(guard(), isFalse);

          coordinator.setColoringActive(false);

          frequency.didChangeAppLifecycleState(
            AppLifecycleState.paused,
          );

          expect(guard(), isFalse);

          interstitial.behavior.finish(false);

          expect(await result, isFalse);
          expect(coordinator.isBusy, isFalse);
        });

    test('rewarded presentation guard follows current app state', () async {
      final result = showRewarded();

      final guard = rewarded.behavior.presentationGuard!;

      expect(guard(), isTrue);

      coordinator.setColoringActive(true);
      expect(guard(), isFalse);

      coordinator.setColoringActive(false);

      frequency.didChangeAppLifecycleState(
        AppLifecycleState.paused,
      );

      expect(guard(), isFalse);

      rewarded.behavior.finish(false);

      expect(await result, isFalse);
      expect(coordinator.isBusy, isFalse);
    });

    test('interstitial and rewarded ads cannot overlap', () async {
      makeEligible();

      final first = coordinator.showInterstitialAtNaturalBreak();

      expect(coordinator.isBusy, isTrue);
      expect(frequency.isAdShowing, isTrue);

      expect(await showRewarded(), isFalse);
      expect(rewarded.behavior.showCount, 0);

      interstitial.behavior.finish(false);

      expect(await first, isFalse);
      expect(coordinator.isBusy, isFalse);

      final second = showRewarded();

      expect(coordinator.isBusy, isTrue);

      expect(
        await coordinator.showInterstitialAtNaturalBreak(),
        isFalse,
      );

      expect(interstitial.behavior.showCount, 1);

      rewarded.behavior.finish(false);

      expect(await second, isFalse);
      expect(coordinator.isBusy, isFalse);
      expect(frequency.isAdShowing, isFalse);
    });

    test('both ad types reset counters only when actually shown', () async {
      makeEligible();

      final failed = coordinator.showInterstitialAtNaturalBreak();

      interstitial.behavior.finish(false);

      expect(await failed, isFalse);
      expect(frequency.navigationCount, 6);

      final shown = coordinator.showInterstitialAtNaturalBreak();

      interstitial.behavior.onShown!();

      expect(frequency.navigationCount, 0);
      expect(frequency.activeDuration, Duration.zero);

      interstitial.behavior.finish(true);

      expect(await shown, isTrue);

      makeEligible();

      final rewardedResult = showRewarded();

      rewarded.behavior.onShown!();

      expect(frequency.navigationCount, 0);
      expect(frequency.activeDuration, Duration.zero);

      rewarded.behavior.finish(true);

      expect(await rewardedResult, isTrue);
    });

    test('reward callback is forwarded to the caller', () async {
      var rewardCount = 0;

      final result = coordinator.showRewarded(
        onRewardEarned: () => rewardCount++,
      );

      expect(rewardCount, 0);

      rewarded.behavior.onShown!();

      expect(rewardCount, 0);

      rewarded.behavior.onReward!();

      expect(rewardCount, 1);

      rewarded.behavior.finish(true);

      expect(await result, isTrue);
      expect(rewardCount, 1);
    });

    test('show exception releases busy state and allows retry', () async {
      rewarded.behavior.throwOnShow = true;

      expect(await showRewarded(), isFalse);

      expect(coordinator.isBusy, isFalse);
      expect(frequency.isAdShowing, isFalse);

      rewarded.behavior.throwOnShow = false;

      final retry = showRewarded();

      expect(coordinator.isBusy, isTrue);

      rewarded.behavior.finish(true);

      expect(await retry, isTrue);
      expect(coordinator.isBusy, isFalse);
    });
  });
}
