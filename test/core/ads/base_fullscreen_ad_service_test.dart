
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tombis_world/core/ads/base_fullscreen_ad_service.dart';

class FakeAd {
  int disposeCount = 0;
}

class FakeFullscreenAdService
    extends BaseFullscreenAdService<FakeAd> {
  FakeFullscreenAdService({
    required super.canLoadAds,
    required super.canRequestAds,
    super.now,
  });

  int requestCount = 0;
  int presentationCount = 0;

  void Function(FakeAd)? completeLoad;
  void Function(Object)? failLoad;

  VoidCallback? reportShown;
  VoidCallback? reportDismissed;
  void Function(Object)? reportShowFailure;

  bool throwOnRequest = false;
  bool throwOnPresentation = false;

  FakeAd? presentedAd;

  @override
  String get adName => 'Fake';

  @override
  Future<void> requestAd({
    required void Function(FakeAd ad) onLoaded,
    required void Function(Object error) onFailed,
  }) async {
    requestCount++;

    if (throwOnRequest) {
      throw StateError('Request failed');
    }

    completeLoad = onLoaded;
    failLoad = onFailed;
  }

  @override
  Future<void> disposeAd(FakeAd ad) async {
    ad.disposeCount++;
  }

  Future<bool> show({
    VoidCallback? onAdShown,
    bool Function()? canPresentAd,
  }) {
    return showCachedAd(
      onAdShown: onAdShown,
      canPresentAd: canPresentAd,
      presentAd: (
          ad,
          onShown,
          onDismissed,
          onFailed,
          ) async {
        presentationCount++;

        if (throwOnPresentation) {
          throw StateError('Presentation failed');
        }

        presentedAd = ad;

        reportShown = onShown;
        reportDismissed = onDismissed;
        reportShowFailure = onFailed;
      },
    );
  }
}

void main() {
  group('BaseFullscreenAdService', () {
    late FakeFullscreenAdService service;
    late DateTime now;

    late bool canLoad;
    late bool hasConsent;

    Completer<bool>? consentGate;

    setUp(() {
      now = DateTime.utc(2026, 1, 1, 12);

      canLoad = true;
      hasConsent = true;
      consentGate = null;

      service = FakeFullscreenAdService(
        canLoadAds: () => canLoad,
        canRequestAds: () async {
          if (consentGate != null) {
            return consentGate!.future;
          }

          return hasConsent;
        },
        now: () => now,
      );
    });

    tearDown(() {
      service.dispose();
    });

    Future<void> flushAsync() async {
      await Future<void>.delayed(Duration.zero);
    }

    Future<FakeAd> loadReadyAd() async {
      await service.loadAd();

      final ad = FakeAd();

      service.completeLoad!(ad);

      return ad;
    }

    test('loading is blocked when ads or consent are unavailable', () async {
      canLoad = false;

      await service.loadAd();

      expect(service.requestCount, 0);
      expect(service.isLoading, isFalse);

      canLoad = true;
      hasConsent = false;

      await service.loadAd();

      expect(service.requestCount, 0);
      expect(service.isLoading, isFalse);
      expect(service.isReady, isFalse);
    });

    test('concurrent loading and valid cache prevent duplicate requests', () async {
      await Future.wait([
        service.loadAd(),
        service.loadAd(),
        service.loadAd(),
      ]);

      expect(service.requestCount, 1);
      expect(service.isLoading, isTrue);
      expect(service.isReady, isFalse);

      service.completeLoad!(FakeAd());

      expect(service.isLoading, isFalse);
      expect(service.isReady, isTrue);

      await service.loadAd();

      expect(service.requestCount, 1);
    });

    test('cache expires at exactly 55 minutes and is replaced', () async {
      final ad = await loadReadyAd();

      now = now.add(
        const Duration(minutes: 54, seconds: 59),
      );

      expect(service.isReady, isTrue);

      now = now.add(const Duration(seconds: 1));

      expect(service.isReady, isFalse);

      await service.loadAd();

      expect(ad.disposeCount, 1);
      expect(service.requestCount, 2);

      service.completeLoad!(FakeAd());

      expect(service.isReady, isTrue);
    });

    test('load failure releases loading state and permits retry', () async {
      await service.loadAd();

      service.failLoad!(StateError('Load failed'));

      expect(service.isLoading, isFalse);
      expect(service.isReady, isFalse);

      await loadReadyAd();

      expect(service.requestCount, 2);
      expect(service.isReady, isTrue);
    });

    test('request exception does not leave service stuck loading', () async {
      service.throwOnRequest = true;

      await service.loadAd();

      expect(service.isLoading, isFalse);
      expect(service.isReady, isFalse);

      service.throwOnRequest = false;

      await loadReadyAd();

      expect(service.isReady, isTrue);
    });

    test('ad arriving after availability is revoked is discarded', () async {
      await service.loadAd();

      canLoad = false;

      final ad = FakeAd();

      service.completeLoad!(ad);

      expect(ad.disposeCount, 1);
      expect(service.isLoading, isFalse);
      expect(service.isReady, isFalse);
    });

    test('dispose clears and releases cached ad', () async {
      final ad = await loadReadyAd();

      service.dispose();

      expect(ad.disposeCount, 1);
      expect(service.isReady, isFalse);
      expect(service.isLoading, isFalse);

      service.dispose();

      expect(ad.disposeCount, 1);
    });

    test('callbacks from invalidated loads cannot affect new loads', () async {
      await service.loadAd();

      final oldSuccess = service.completeLoad!;
      final oldFailure = service.failLoad!;

      service.dispose();

      await service.loadAd();

      final staleAd = FakeAd();

      oldSuccess(staleAd);
      oldFailure(StateError('Old request failed'));

      expect(staleAd.disposeCount, 1);
      expect(service.isLoading, isTrue);
      expect(service.isReady, isFalse);

      service.completeLoad!(FakeAd());

      expect(service.isLoading, isFalse);
      expect(service.isReady, isTrue);
    });

    test('showing without cached ad returns false and starts loading', () async {
      expect(await service.show(), isFalse);

      await flushAsync();

      expect(service.presentationCount, 0);
      expect(service.requestCount, 1);
      expect(service.isLoading, isTrue);
    });

    test('consent is checked again before presenting cached ad', () async {
      final ad = await loadReadyAd();

      hasConsent = false;

      expect(await service.show(), isFalse);

      expect(service.presentationCount, 0);
      expect(service.isShowing, isFalse);
      expect(service.isReady, isFalse);
      expect(ad.disposeCount, 1);
    });

    test('presentation guard is checked after asynchronous consent', () async {
      await loadReadyAd();

      var canPresent = true;

      consentGate = Completer<bool>();

      final result = service.show(
        canPresentAd: () => canPresent,
      );

      canPresent = false;

      consentGate!.complete(true);

      expect(await result, isFalse);

      expect(service.presentationCount, 0);
      expect(service.isShowing, isFalse);
      expect(service.isReady, isTrue);
    });

    test('throwing presentation guard releases showing state', () async {
      await loadReadyAd();

      final result = await service.show(
        canPresentAd: () {
          throw StateError('Guard failed');
        },
      );

      expect(result, isFalse);
      expect(service.presentationCount, 0);
      expect(service.isShowing, isFalse);
      expect(service.isReady, isTrue);
    });

    test('ad expiring during consent check is not presented', () async {
      final ad = await loadReadyAd();

      consentGate = Completer<bool>();

      final result = service.show();

      now = now.add(const Duration(minutes: 55));

      consentGate!.complete(true);

      expect(await result, isFalse);

      await flushAsync();

      expect(ad.disposeCount, 1);
      expect(service.presentationCount, 0);
      expect(service.isShowing, isFalse);
      expect(service.requestCount, 2);
    });

    test('successful show prevents concurrent ads and reloads after dismissal', () async {
      final ad = await loadReadyAd();

      var shownCount = 0;

      final result = service.show(
        onAdShown: () => shownCount++,
      );

      await flushAsync();

      expect(service.isShowing, isTrue);
      expect(service.isReady, isFalse);
      expect(service.presentedAd, same(ad));

      expect(await service.show(), isFalse);

      await service.loadAd();

      expect(service.presentationCount, 1);
      expect(service.requestCount, 1);

      service.reportShown!();
      service.reportShown!();

      expect(shownCount, 1);

      service.reportDismissed!();

      expect(await result, isTrue);

      await flushAsync();

      expect(service.isShowing, isFalse);
      expect(ad.disposeCount, 1);
      expect(service.requestCount, 2);
    });

    test('show failure releases ad and ignores duplicate terminal callbacks', () async {
      final ad = await loadReadyAd();

      var shownCount = 0;

      final result = service.show(
        onAdShown: () => shownCount++,
      );

      await flushAsync();

      service.reportShowFailure!(
        StateError('Show failed'),
      );

      service.reportDismissed!();
      service.reportShown!();

      expect(await result, isFalse);

      await flushAsync();

      expect(shownCount, 0);
      expect(ad.disposeCount, 1);
      expect(service.isShowing, isFalse);
      expect(service.requestCount, 2);
    });

    test('presentation exception releases state and reloads', () async {
      final ad = await loadReadyAd();

      service.throwOnPresentation = true;

      expect(await service.show(), isFalse);

      await flushAsync();

      expect(service.isShowing, isFalse);
      expect(ad.disposeCount, 1);
      expect(service.requestCount, 2);
    });

    test('throwing onAdShown callback does not break dismissal', () async {
      final ad = await loadReadyAd();

      final result = service.show(
        onAdShown: () {
          throw StateError('Callback failed');
        },
      );

      await flushAsync();

      service.reportShown!();
      service.reportDismissed!();

      expect(await result, isTrue);
      expect(service.isShowing, isFalse);
      expect(ad.disposeCount, 1);
    });

    test('disposing during presentation prevents automatic reload', () async {
      final ad = await loadReadyAd();

      final result = service.show();

      await flushAsync();

      service.reportShown!();

      service.dispose();

      service.reportDismissed!();

      expect(await result, isTrue);

      await flushAsync();

      expect(ad.disposeCount, 1);
      expect(service.isShowing, isFalse);
      expect(service.requestCount, 1);
    });
  });
}
