
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tombis_world/core/ads/ad_coordinator.dart';
import 'package:tombis_world/features/gallery/controllers/gallery_unlock_controller.dart';
import 'package:tombis_world/features/gallery/controllers/session_unlock_controller.dart';
import 'package:tombis_world/features/gallery/models/coloring_page.dart';

class FakeAdCoordinator extends Fake implements AdCoordinator {
  bool busy = false;
  int showCount = 0;

  VoidCallback? rewardCallback;
  Completer<bool>? pendingShow;

  @override
  bool get isBusy => busy;

  @override
  Future<bool> showRewarded({
    required VoidCallback onRewardEarned,
  }) {
    showCount++;

    rewardCallback = onRewardEarned;
    pendingShow = Completer<bool>();

    return pendingShow!.future;
  }

  void earnReward() {
    rewardCallback!();
  }

  void finish(bool wasShown) {
    pendingShow!.complete(wasShown);
  }
}

void main() {
  group('GalleryUnlockController', () {
    late FakeAdCoordinator ads;
    late SessionUnlockController session;
    late GalleryUnlockController controller;

    const freePage = ColoringPage(
      id: 'free_page',
      title: 'Free Page',
      thumbnailPath: 'free_thumbnail.svg',
      imagePath: 'free.svg',
    );

    const rewardedPage = ColoringPage(
      id: 'rewarded_page',
      title: 'Rewarded Page',
      thumbnailPath: 'rewarded_thumbnail.svg',
      imagePath: 'rewarded.svg',
      isRewarded: true,
    );

    const anotherRewardedPage = ColoringPage(
      id: 'another_rewarded_page',
      title: 'Another Rewarded Page',
      thumbnailPath: 'another_thumbnail.svg',
      imagePath: 'another.svg',
      isRewarded: true,
    );

    setUp(() {
      ads = FakeAdCoordinator();
      session = SessionUnlockController();

      controller = GalleryUnlockController(
        ads: ads,
        session: session,
      );
    });

    tearDown(() {
      session.dispose();
    });

    test('free and previously unlocked pages do not require ads',
            () async {
          expect(controller.isLocked(freePage), isFalse);

          expect(
            await controller.unlockPage(freePage),
            GalleryUnlockResult.unlocked,
          );

          session.unlockPage(rewardedPage);

          expect(controller.isLocked(rewardedPage), isFalse);

          expect(
            await controller.unlockPage(rewardedPage),
            GalleryUnlockResult.unlocked,
          );

          expect(ads.showCount, 0);
          expect(controller.isUnlocking, isFalse);
        });

    test('earned reward unlocks only the selected page', () async {
      final result = controller.unlockPage(rewardedPage);

      expect(controller.isUnlocking, isTrue);
      expect(controller.isLocked(rewardedPage), isTrue);
      expect(ads.showCount, 1);

      ads.earnReward();
      ads.finish(true);

      expect(await result, GalleryUnlockResult.unlocked);

      expect(controller.isLocked(rewardedPage), isFalse);
      expect(controller.isLocked(anotherRewardedPage), isTrue);
      expect(controller.isUnlocking, isFalse);
    });

    test('closing an ad without reward keeps the page locked',
            () async {
          final result = controller.unlockPage(rewardedPage);

          ads.finish(true);

          expect(
            await result,
            GalleryUnlockResult.rewardNotEarned,
          );

          expect(controller.isLocked(rewardedPage), isTrue);
          expect(controller.isUnlocking, isFalse);
        });

    test('unavailable ad returns the correct result and allows retry',
            () async {
          final result = controller.unlockPage(rewardedPage);

          ads.finish(false);

          expect(
            await result,
            GalleryUnlockResult.adUnavailable,
          );

          expect(controller.isLocked(rewardedPage), isTrue);
          expect(controller.isUnlocking, isFalse);

          final retry = controller.unlockPage(rewardedPage);

          ads.earnReward();
          ads.finish(true);

          expect(await retry, GalleryUnlockResult.unlocked);
          expect(ads.showCount, 2);
        });

    test('busy ad coordinator prevents another ad request', () async {
      ads.busy = true;

      expect(
        await controller.unlockPage(rewardedPage),
        GalleryUnlockResult.busy,
      );

      expect(ads.showCount, 0);
      expect(controller.isUnlocking, isFalse);
      expect(controller.isLocked(rewardedPage), isTrue);
    });

    test('concurrent unlock requests cannot start multiple ads',
            () async {
          final first = controller.unlockPage(rewardedPage);

          expect(
            await controller.unlockPage(rewardedPage),
            GalleryUnlockResult.busy,
          );

          expect(
            await controller.unlockPage(anotherRewardedPage),
            GalleryUnlockResult.busy,
          );

          expect(ads.showCount, 1);

          ads.earnReward();
          ads.finish(true);

          expect(await first, GalleryUnlockResult.unlocked);
          expect(controller.isUnlocking, isFalse);
          expect(controller.isLocked(anotherRewardedPage), isTrue);
        });

    test('duplicate reward callbacks do not grant duplicate unlocks',
            () async {
          var notificationCount = 0;

          session.addListener(() {
            notificationCount++;
          });

          final result = controller.unlockPage(rewardedPage);

          ads.earnReward();
          ads.earnReward();

          ads.finish(true);

          expect(await result, GalleryUnlockResult.unlocked);
          expect(notificationCount, 1);
          expect(controller.isLocked(rewardedPage), isFalse);
        });

    test('reward arriving after session reset is ignored', () async {
      final result = controller.unlockPage(rewardedPage);

      session.resetSession();

      ads.earnReward();
      ads.finish(true);

      expect(
        await result,
        GalleryUnlockResult.rewardNotEarned,
      );

      expect(controller.isLocked(rewardedPage), isTrue);
      expect(controller.isUnlocking, isFalse);
    });

    test('session reset after reward prevents stale unlock result',
            () async {
          final result = controller.unlockPage(rewardedPage);

          ads.earnReward();

          expect(controller.isLocked(rewardedPage), isFalse);

          session.resetSession();

          ads.finish(true);

          expect(
            await result,
            GalleryUnlockResult.rewardNotEarned,
          );

          expect(controller.isLocked(rewardedPage), isTrue);
          expect(controller.isUnlocking, isFalse);
        });

    test('expired session does not return ad unavailable', () async {
      final result = controller.unlockPage(rewardedPage);

      session.resetSession();

      ads.finish(false);

      expect(
        await result,
        GalleryUnlockResult.rewardNotEarned,
      );

      expect(controller.isLocked(rewardedPage), isTrue);
      expect(controller.isUnlocking, isFalse);
    });

    test('late reward from previous session cannot affect new request',
            () async {
          final first = controller.unlockPage(rewardedPage);

          final oldRewardCallback = ads.rewardCallback!;

          session.resetSession();

          ads.finish(true);

          expect(
            await first,
            GalleryUnlockResult.rewardNotEarned,
          );

          final second = controller.unlockPage(anotherRewardedPage);

          oldRewardCallback();

          expect(controller.isLocked(rewardedPage), isTrue);
          expect(controller.isLocked(anotherRewardedPage), isTrue);

          ads.earnReward();
          ads.finish(true);

          expect(await second, GalleryUnlockResult.unlocked);

          expect(controller.isLocked(rewardedPage), isTrue);
          expect(controller.isLocked(anotherRewardedPage), isFalse);
          expect(controller.isUnlocking, isFalse);
        });

    test('unexpected exception releases unlocking state', () async {
      final result = controller.unlockPage(rewardedPage);

      final expectation = expectLater(
        result,
        throwsStateError,
      );

      ads.pendingShow!.completeError(
        StateError('Unexpected ad error'),
      );

      await expectation;

      expect(controller.isUnlocking, isFalse);
      expect(controller.isLocked(rewardedPage), isTrue);

      final retry = controller.unlockPage(rewardedPage);

      ads.earnReward();
      ads.finish(true);

      expect(await retry, GalleryUnlockResult.unlocked);
    });
  });
}
