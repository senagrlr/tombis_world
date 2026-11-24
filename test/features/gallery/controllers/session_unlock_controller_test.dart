
import 'package:flutter_test/flutter_test.dart';

import 'package:tombis_world/features/gallery/controllers/session_unlock_controller.dart';
import 'package:tombis_world/features/gallery/models/coloring_page.dart';

void main() {
  group('SessionUnlockController', () {
    late SessionUnlockController controller;

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
      controller = SessionUnlockController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('free pages are unlocked and rewarded pages are locked initially', () {
      expect(controller.isUnlocked(freePage), isTrue);
      expect(controller.isLocked(freePage), isFalse);

      expect(controller.isUnlocked(rewardedPage), isFalse);
      expect(controller.isLocked(rewardedPage), isTrue);

      expect(controller.sessionVersion, 0);
    });

    test('unlocking a rewarded page does not unlock other pages', () {
      controller.unlockPage(rewardedPage);

      expect(controller.isUnlocked(rewardedPage), isTrue);
      expect(controller.isLocked(anotherRewardedPage), isTrue);
      expect(controller.sessionVersion, 0);
    });

    test('listeners are notified only when a new page is unlocked', () {
      var notificationCount = 0;

      controller.addListener(() {
        notificationCount++;
      });

      controller.unlockPage(freePage);
      expect(notificationCount, 0);

      controller.unlockPage(rewardedPage);
      expect(notificationCount, 1);

      controller.unlockPage(rewardedPage);
      expect(notificationCount, 1);

      controller.unlockPage(anotherRewardedPage);
      expect(notificationCount, 2);
    });

    test('reset locks all rewarded pages and preserves free pages', () {
      controller.unlockPage(rewardedPage);
      controller.unlockPage(anotherRewardedPage);

      var notificationCount = 0;

      controller.addListener(() {
        notificationCount++;
      });

      controller.resetSession();

      expect(controller.isLocked(rewardedPage), isTrue);
      expect(controller.isLocked(anotherRewardedPage), isTrue);
      expect(controller.isUnlocked(freePage), isTrue);

      expect(controller.sessionVersion, 1);
      expect(notificationCount, 1);
    });

    test('reset increments session version even without unlocked pages', () {
      var notificationCount = 0;

      controller.addListener(() {
        notificationCount++;
      });

      controller.resetSession();
      expect(controller.sessionVersion, 1);

      controller.resetSession();
      expect(controller.sessionVersion, 2);

      expect(notificationCount, 0);
    });

    test('rewarded pages can be unlocked again in a new session', () {
      controller.unlockPage(rewardedPage);

      controller.resetSession();

      expect(controller.isLocked(rewardedPage), isTrue);

      controller.unlockPage(rewardedPage);

      expect(controller.isUnlocked(rewardedPage), isTrue);
      expect(controller.sessionVersion, 1);
    });

    test('unlocked state is not shared between controller instances', () {
      final anotherController = SessionUnlockController();
      addTearDown(anotherController.dispose);

      controller.unlockPage(rewardedPage);

      expect(controller.isUnlocked(rewardedPage), isTrue);
      expect(anotherController.isLocked(rewardedPage), isTrue);
    });
  });
}
