
import 'dart:async';

import 'package:flutter/widgets.dart';

class AdNavigationObserver extends NavigatorObserver {
  AdNavigationObserver({
    required VoidCallback onNavigation,
    required ValueChanged<bool> onColoringChanged,
    required Future<bool> Function({
    bool Function()? isStillAtNaturalBreak,
    }) onNaturalBreak,
    required String coloringRouteName,
    required String completionRouteName,
    required String splashRouteName,
    required Set<String> naturalBreakDestinations,
  })  : _onNavigation = onNavigation,
        _onColoringChanged = onColoringChanged,
        _onNaturalBreak = onNaturalBreak,
        _coloringRouteName = coloringRouteName,
        _completionRouteName = completionRouteName,
        _splashRouteName = splashRouteName,
        _naturalBreakDestinations =
        Set.unmodifiable(naturalBreakDestinations);

  final VoidCallback _onNavigation;
  final ValueChanged<bool> _onColoringChanged;
  final Future<bool> Function({
  bool Function()? isStillAtNaturalBreak,
  }) _onNaturalBreak;

  final String _coloringRouteName;
  final String _completionRouteName;
  final String _splashRouteName;

  final Set<String> _naturalBreakDestinations;

  PageRoute<dynamic>? _lastPageRoute;

  bool _isColoringFlow(String? routeName) {
    return routeName == _coloringRouteName ||
        routeName == _completionRouteName;
  }

  bool _isNaturalBreak(
      String? previousRouteName,
      String? currentRouteName,
      ) {
    return _isColoringFlow(previousRouteName) &&
        _naturalBreakDestinations.contains(currentRouteName);
  }

  @override
  void didChangeTop(
      Route<dynamic> topRoute,
      Route<dynamic>? previousTopRoute,
      ) {
    super.didChangeTop(topRoute, previousTopRoute);

    if (topRoute is! PageRoute<dynamic>) return;

    final previousPageRoute = _lastPageRoute;

    if (identical(previousPageRoute, topRoute)) return;

    _lastPageRoute = topRoute;

    final currentRouteName = topRoute.settings.name;
    final previousRouteName =
        previousPageRoute?.settings.name;

    final isColoringFlow =
    _isColoringFlow(currentRouteName);

    final wasColoringFlow =
    _isColoringFlow(previousRouteName);

    _onColoringChanged(isColoringFlow);

    if (previousPageRoute == null) return;

    if (currentRouteName == _splashRouteName ||
        previousRouteName == _splashRouteName) {
      return;
    }

    if (wasColoringFlow && isColoringFlow) {
      return;
    }

    _onNavigation();

    if (_isNaturalBreak(
      previousRouteName,
      currentRouteName,
    )) {
      _scheduleNaturalBreak(topRoute);
    }
  }

  void _scheduleNaturalBreak(PageRoute<dynamic> route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isStillAtNaturalBreak(route)) return;

      unawaited(_showInterstitial(route));
    });
  }

  bool _isStillAtNaturalBreak(PageRoute<dynamic> route) {
    return identical(_lastPageRoute, route) &&
        route.isCurrent;
  }

  Future<void> _showInterstitial(
      PageRoute<dynamic> route,
      ) async {
    try {
      await _onNaturalBreak(
        isStillAtNaturalBreak: () =>
            _isStillAtNaturalBreak(route),
      );
    } catch (error) {
      debugPrint('Natural break ad error: $error');
    }
  }
}
