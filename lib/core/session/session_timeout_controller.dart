
class SessionTimeoutController {
  SessionTimeoutController({
    this.timeout = const Duration(hours: 1),
    DateTime Function()? now,
  })  : assert(timeout > Duration.zero),
        _now = now ?? DateTime.now;

  final Duration timeout;
  final DateTime Function() _now;

  DateTime? _backgroundedAt;

  bool get isInBackground => _backgroundedAt != null;

  void onBackgrounded() {
    _backgroundedAt ??= _now();
  }

  bool onResumed() {
    final backgroundedAt = _backgroundedAt;

    reset();

    if (backgroundedAt == null) return false;

    return _now().difference(backgroundedAt) >= timeout;
  }

  void reset() {
    _backgroundedAt = null;
  }
}
