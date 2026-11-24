
import 'package:flutter/widgets.dart';

class AdFrequencyController with WidgetsBindingObserver {
  AdFrequencyController({
    Stopwatch? stopwatch,
  }) : _stopwatch = stopwatch ?? Stopwatch();

  static final AdFrequencyController instance =
  AdFrequencyController();

  static const Duration minimumActiveTime =
  Duration(minutes: 4);

  static const int minimumNavigationCount = 6;

  final Stopwatch _stopwatch;

  int _navigationCount = 0;

  bool _isAppActive = false;
  bool _isColoring = false;
  bool _isAdShowing = false;
  bool _initialized = false;

  Duration get activeDuration => _stopwatch.elapsed;

  int get navigationCount => _navigationCount;

  bool get isAppActive => _isAppActive;

  bool get isColoring => _isColoring;

  bool get isAdShowing => _isAdShowing;

  bool get _shouldTrackTime =>
      _isAppActive && !_isAdShowing;

  bool get isEligible {
    if (!_isAppActive || _isColoring || _isAdShowing) {
      return false;
    }

    return activeDuration >= minimumActiveTime ||
        _navigationCount >= minimumNavigationCount;
  }

  void initialize() {
    if (_initialized) return;

    _initialized = true;

    WidgetsBinding.instance.addObserver(this);

    didChangeAppLifecycleState(
      WidgetsBinding.instance.lifecycleState ??
          AppLifecycleState.detached,
    );
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    _isAppActive =
        state == AppLifecycleState.resumed;

    _syncTimer();
  }

  void registerNavigation() {
    if (!_isAppActive || _isAdShowing) return;

    _navigationCount++;
  }

  void setColoringActive(bool active) {
    _isColoring = active;
  }

  void setAdShowing(bool showing) {
    if (_isAdShowing == showing) return;

    _isAdShowing = showing;

    _syncTimer();
  }

  void onAdShown() {
    _stopwatch.reset();

    _navigationCount = 0;

    _syncTimer();
  }

  void _syncTimer() {
    if (_shouldTrackTime) {
      _stopwatch.start();
    } else {
      _stopwatch.stop();
    }
  }

  void dispose() {
    if (_initialized) {
      WidgetsBinding.instance.removeObserver(this);
    }

    _initialized = false;
    _isAppActive = false;
    _isColoring = false;
    _isAdShowing = false;

    _stopwatch.stop();
    _stopwatch.reset();

    _navigationCount = 0;
  }
}
