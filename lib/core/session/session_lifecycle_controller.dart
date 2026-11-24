
import 'package:flutter/widgets.dart';

import 'session_timeout_controller.dart';

class SessionLifecycleController with WidgetsBindingObserver {
  SessionLifecycleController({
    required SessionTimeoutController timeoutController,
    required VoidCallback onSessionExpired,
  })  : _timeoutController = timeoutController,
        _onSessionExpired = onSessionExpired;

  final SessionTimeoutController _timeoutController;
  final VoidCallback _onSessionExpired;

  bool _initialized = false;

  void initialize() {
    if (_initialized) return;

    _initialized = true;

    WidgetsBinding.instance.addObserver(this);

    final state = WidgetsBinding.instance.lifecycleState;

    if (state != null) {
      didChangeAppLifecycleState(state);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (_timeoutController.onResumed()) {
          _onSessionExpired();
        }
        break;

      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _timeoutController.onBackgrounded();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  void dispose() {
    if (!_initialized) return;

    WidgetsBinding.instance.removeObserver(this);

    _initialized = false;
    _timeoutController.reset();
  }
}
