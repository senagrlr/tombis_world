
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tombis_world/core/ads/ad_frequency_controller.dart';

class FakeStopwatch implements Stopwatch {
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;

  @override
  Duration get elapsed => _elapsed;

  @override
  bool get isRunning => _isRunning;

  @override
  int get elapsedMilliseconds => _elapsed.inMilliseconds;

  @override
  int get elapsedMicroseconds => _elapsed.inMicroseconds;

  @override
  int get elapsedTicks => _elapsed.inMicroseconds;

  @override
  int get frequency => 1000000;

  @override
  void start() => _isRunning = true;

  @override
  void stop() => _isRunning = false;

  @override
  void reset() => _elapsed = Duration.zero;

  void advance(Duration duration) {
    if (_isRunning) {
      _elapsed += duration;
    }
  }
}

void main() {
  group('AdFrequencyController', () {
    late FakeStopwatch stopwatch;
    late AdFrequencyController controller;

    setUp(() {
      stopwatch = FakeStopwatch();

      controller = AdFrequencyController(
        stopwatch: stopwatch,
      );

      controller.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    void navigate(int count) {
      for (var i = 0; i < count; i++) {
        controller.registerNavigation();
      }
    }

    test('initially is not eligible for an ad', () {
      expect(controller.activeDuration, Duration.zero);
      expect(controller.navigationCount, 0);
      expect(controller.isEligible, isFalse);
    });

    test('four minutes alone makes an ad eligible', () {
      stopwatch.advance(
        const Duration(minutes: 3, seconds: 59, milliseconds: 999),
      );

      expect(controller.isEligible, isFalse);

      stopwatch.advance(const Duration(milliseconds: 1));

      expect(controller.navigationCount, 0);
      expect(controller.isEligible, isTrue);
    });

    test('six navigations alone make an ad eligible', () {
      navigate(5);

      expect(controller.isEligible, isFalse);

      navigate(1);

      expect(controller.activeDuration, Duration.zero);
      expect(controller.navigationCount, 6);
      expect(controller.isEligible, isTrue);
    });

    test('coloring blocks ads without resetting eligibility', () {
      navigate(6);

      expect(controller.isEligible, isTrue);

      controller.setColoringActive(true);

      expect(controller.isColoring, isTrue);
      expect(controller.isEligible, isFalse);

      stopwatch.advance(const Duration(minutes: 2));

      expect(
        controller.activeDuration,
        const Duration(minutes: 2),
      );

      controller.setColoringActive(false);

      expect(controller.isEligible, isTrue);
      expect(controller.navigationCount, 6);
    });

    test('inactive lifecycle states pause tracking and block ads', () {
      navigate(6);

      stopwatch.advance(const Duration(minutes: 2));

      for (final state in AppLifecycleState.values) {
        if (state == AppLifecycleState.resumed) continue;

        controller.didChangeAppLifecycleState(state);

        stopwatch.advance(const Duration(minutes: 10));
        controller.registerNavigation();

        expect(controller.isAppActive, isFalse);
        expect(controller.isEligible, isFalse);
        expect(stopwatch.isRunning, isFalse);
        expect(controller.navigationCount, 6);

        expect(
          controller.activeDuration,
          const Duration(minutes: 2),
        );
      }

      controller.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );

      stopwatch.advance(const Duration(minutes: 1));

      expect(controller.isAppActive, isTrue);
      expect(controller.isEligible, isTrue);

      expect(
        controller.activeDuration,
        const Duration(minutes: 3),
      );
    });

    test('showing an ad pauses tracking and blocks other ads', () {
      navigate(6);

      stopwatch.advance(const Duration(minutes: 2));

      controller.setAdShowing(true);

      stopwatch.advance(const Duration(minutes: 5));
      controller.registerNavigation();

      expect(controller.isAdShowing, isTrue);
      expect(controller.isEligible, isFalse);
      expect(stopwatch.isRunning, isFalse);
      expect(controller.navigationCount, 6);

      expect(
        controller.activeDuration,
        const Duration(minutes: 2),
      );

      controller.setAdShowing(false);

      expect(stopwatch.isRunning, isTrue);
      expect(controller.isEligible, isTrue);
    });

    test('ad shown resets both counters and restarts tracking correctly', () {
      navigate(6);
      stopwatch.advance(const Duration(minutes: 4));

      controller.setAdShowing(true);
      controller.onAdShown();

      expect(controller.navigationCount, 0);
      expect(controller.activeDuration, Duration.zero);
      expect(controller.isEligible, isFalse);
      expect(stopwatch.isRunning, isFalse);

      controller.setAdShowing(false);

      expect(stopwatch.isRunning, isTrue);
      expect(controller.isEligible, isFalse);

      stopwatch.advance(const Duration(minutes: 4));

      expect(controller.isEligible, isTrue);
    });

    test('closing an ad in background does not restart tracking', () {
      controller.setAdShowing(true);

      controller.didChangeAppLifecycleState(
        AppLifecycleState.paused,
      );

      controller.setAdShowing(false);

      expect(stopwatch.isRunning, isFalse);

      stopwatch.advance(const Duration(minutes: 10));

      expect(controller.activeDuration, Duration.zero);

      controller.didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );

      expect(stopwatch.isRunning, isTrue);
    });

    test('dispose clears counters and controller state', () {
      navigate(6);
      stopwatch.advance(const Duration(minutes: 4));

      controller.setColoringActive(true);
      controller.setAdShowing(true);

      controller.dispose();

      expect(controller.activeDuration, Duration.zero);
      expect(controller.navigationCount, 0);
      expect(controller.isAppActive, isFalse);
      expect(controller.isColoring, isFalse);
      expect(controller.isAdShowing, isFalse);
      expect(controller.isEligible, isFalse);
      expect(stopwatch.isRunning, isFalse);
    });
  });
}
