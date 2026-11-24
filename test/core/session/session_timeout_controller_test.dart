
import 'package:flutter_test/flutter_test.dart';
import 'package:tombis_world/core/session/session_timeout_controller.dart';

void main() {
  group('SessionTimeoutController', () {
    late DateTime now;
    late SessionTimeoutController controller;

    setUp(() {
      now = DateTime.utc(2026, 1, 1, 12);

      controller = SessionTimeoutController(
        now: () => now,
      );
    });

    void advanceTime(Duration duration) {
      now = now.add(duration);
    }

    test('default timeout is one hour', () {
      expect(
        controller.timeout,
        const Duration(hours: 1),
      );
    });

    test('initially is not in background', () {
      expect(controller.isInBackground, isFalse);
    });

    test('resuming without backgrounding does not expire session', () {
      expect(controller.onResumed(), isFalse);
    });

    test('backgrounding marks session as in background', () {
      controller.onBackgrounded();

      expect(controller.isInBackground, isTrue);
    });

    test('immediate resume does not expire session', () {
      controller.onBackgrounded();

      expect(controller.onResumed(), isFalse);
      expect(controller.isInBackground, isFalse);
    });

    test('short background duration does not expire session', () {
      controller.onBackgrounded();

      advanceTime(const Duration(minutes: 5));

      expect(controller.onResumed(), isFalse);
    });

    test('one millisecond before timeout does not expire session', () {
      controller.onBackgrounded();

      advanceTime(
        const Duration(hours: 1) -
            const Duration(milliseconds: 1),
      );

      expect(controller.onResumed(), isFalse);
    });

    test('exactly one hour expires session', () {
      controller.onBackgrounded();

      advanceTime(const Duration(hours: 1));

      expect(controller.onResumed(), isTrue);
    });

    test('one millisecond after timeout expires session', () {
      controller.onBackgrounded();

      advanceTime(
        const Duration(hours: 1, milliseconds: 1),
      );

      expect(controller.onResumed(), isTrue);
    });

    test('long background duration expires session', () {
      controller.onBackgrounded();

      advanceTime(const Duration(hours: 5));

      expect(controller.onResumed(), isTrue);
    });

    test('repeated background events preserve original start time', () {
      controller.onBackgrounded();

      advanceTime(const Duration(minutes: 40));

      controller.onBackgrounded();

      advanceTime(const Duration(minutes: 20));

      expect(controller.onResumed(), isTrue);
    });

    test('successful resume clears background state', () {
      controller.onBackgrounded();

      advanceTime(const Duration(minutes: 10));

      controller.onResumed();

      expect(controller.isInBackground, isFalse);
    });

    test('expired resume clears background state', () {
      controller.onBackgrounded();

      advanceTime(const Duration(hours: 1));

      expect(controller.onResumed(), isTrue);
      expect(controller.isInBackground, isFalse);
    });

    test('repeated resume does not expire session twice', () {
      controller.onBackgrounded();

      advanceTime(const Duration(hours: 1));

      expect(controller.onResumed(), isTrue);
      expect(controller.onResumed(), isFalse);
    });

    test('reset clears background state', () {
      controller.onBackgrounded();

      controller.reset();

      expect(controller.isInBackground, isFalse);
    });

    test('reset cancels pending session expiration', () {
      controller.onBackgrounded();

      advanceTime(const Duration(hours: 2));

      controller.reset();

      expect(controller.onResumed(), isFalse);
    });

    test('separate background periods are not accumulated', () {
      controller.onBackgrounded();

      advanceTime(const Duration(minutes: 40));

      expect(controller.onResumed(), isFalse);

      controller.onBackgrounded();

      advanceTime(const Duration(minutes: 40));

      expect(controller.onResumed(), isFalse);
    });

    test('foreground time is not included in background duration', () {
      controller.onBackgrounded();

      advanceTime(const Duration(minutes: 10));

      expect(controller.onResumed(), isFalse);

      advanceTime(const Duration(hours: 3));

      controller.onBackgrounded();

      advanceTime(const Duration(minutes: 10));

      expect(controller.onResumed(), isFalse);
    });

    test('new background period works after session expiration', () {
      controller.onBackgrounded();

      advanceTime(const Duration(hours: 1));

      expect(controller.onResumed(), isTrue);

      controller.onBackgrounded();

      advanceTime(const Duration(minutes: 5));

      expect(controller.onResumed(), isFalse);
    });

    test('custom timeout is respected', () {
      final customController = SessionTimeoutController(
        timeout: const Duration(minutes: 10),
        now: () => now,
      );

      customController.onBackgrounded();

      advanceTime(const Duration(minutes: 10));

      expect(customController.onResumed(), isTrue);
    });

    test('zero timeout is rejected', () {
      expect(
            () => SessionTimeoutController(
          timeout: Duration.zero,
        ),
        throwsAssertionError,
      );
    });

    test('negative timeout is rejected', () {
      expect(
            () => SessionTimeoutController(
          timeout: const Duration(minutes: -1),
        ),
        throwsAssertionError,
      );
    });
  });
}
