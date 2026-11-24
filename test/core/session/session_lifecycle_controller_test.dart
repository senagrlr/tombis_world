
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tombis_world/core/session/session_lifecycle_controller.dart';
import 'package:tombis_world/core/session/session_timeout_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionLifecycleController', () {
    late DateTime now;
    late int expirationCount;
    late SessionTimeoutController timeoutController;
    late SessionLifecycleController controller;

    setUp(() {
      now = DateTime.utc(2026, 1, 1, 12);
      expirationCount = 0;

      timeoutController = SessionTimeoutController(
        now: () => now,
      );

      controller = SessionLifecycleController(
        timeoutController: timeoutController,
        onSessionExpired: () => expirationCount++,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('ignores lifecycle events before initialization', () {
      controller.didChangeAppLifecycleState(
        AppLifecycleState.hidden,
      );

      expect(timeoutController.isInBackground, isFalse);
      expect(expirationCount, 0);
    });

    test('hidden and paused preserve the same background period', () {
      controller.initialize();

      controller.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );

      controller.didChangeAppLifecycleState(
        AppLifecycleState.hidden,
      );

      expect(timeoutController.isInBackground, isTrue);

      now = now.add(const Duration(minutes: 30));

      controller.didChangeAppLifecycleState(
        AppLifecycleState.paused,
      );

      now = now.add(const Duration(minutes: 30));

      controller.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );

      expect(expirationCount, 1);
      expect(timeoutController.isInBackground, isFalse);
    });

    test('short background period does not expire session', () {
      controller.initialize();

      controller.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );

      controller.didChangeAppLifecycleState(
        AppLifecycleState.paused,
      );

      now = now.add(const Duration(minutes: 5));

      controller.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );

      expect(expirationCount, 0);
      expect(timeoutController.isInBackground, isFalse);
    });

    test('inactive and detached do not start background tracking', () {
      controller.initialize();

      controller.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );

      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.detached,
      ]) {
        controller.didChangeAppLifecycleState(state);

        expect(timeoutController.isInBackground, isFalse);
      }

      expect(expirationCount, 0);
    });

    test('expiration callback is called only once per background period', () {
      controller.initialize();

      controller.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );

      controller.didChangeAppLifecycleState(
        AppLifecycleState.paused,
      );

      now = now.add(const Duration(hours: 1));

      controller.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );

      controller.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );

      expect(expirationCount, 1);
    });

    test('dispose resets tracking and ignores subsequent events', () {
      controller.initialize();

      controller.didChangeAppLifecycleState(
        AppLifecycleState.hidden,
      );

      controller.dispose();

      expect(timeoutController.isInBackground, isFalse);

      controller.didChangeAppLifecycleState(
        AppLifecycleState.paused,
      );

      now = now.add(const Duration(hours: 2));

      controller.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );

      expect(timeoutController.isInBackground, isFalse);
      expect(expirationCount, 0);
    });
  });
}
