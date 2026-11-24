
import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class BaseFullscreenAdService<T extends Object> {
  BaseFullscreenAdService({
    required bool Function() canLoadAds,
    required Future<bool> Function() canRequestAds,
    DateTime Function()? now,
  })  : _canLoadAds = canLoadAds,
        _canRequestAds = canRequestAds,
        _now = now ?? DateTime.now;

  static const Duration _maximumAdAge =
  Duration(minutes: 55);

  final bool Function() _canLoadAds;
  final Future<bool> Function() _canRequestAds;
  final DateTime Function() _now;

  T? _cachedAd;
  DateTime? _loadedAt;

  bool _isLoading = false;
  bool _isShowing = false;

  int _loadGeneration = 0;

  bool get isLoading => _isLoading;

  bool get isShowing => _isShowing;

  bool get _isExpired {
    final loadedAt = _loadedAt;

    if (loadedAt == null) return true;

    return _now().difference(loadedAt) >=
        _maximumAdAge;
  }

  bool get isReady =>
      _canLoadAds() &&
          _cachedAd != null &&
          !_isShowing &&
          !_isExpired;

  @protected
  String get adName;

  @protected
  Future<void> requestAd({
    required void Function(T ad) onLoaded,
    required void Function(Object error) onFailed,
  });

  @protected
  Future<void> disposeAd(T ad);

  Future<void> loadAd() async {
    if (_isLoading || _isShowing || !_canLoadAds()) {
      return;
    }

    if (_cachedAd != null) {
      if (!_isExpired) return;

      _clearCachedAd();
    }

    _isLoading = true;

    final generation = ++_loadGeneration;

    try {
      final allowed = await _canRequestAds();

      if (generation != _loadGeneration) return;

      if (!allowed || !_canLoadAds()) {
        _isLoading = false;
        return;
      }

      await requestAd(
        onLoaded: (ad) {
          if (generation != _loadGeneration) {
            unawaited(_safeDispose(ad));
            return;
          }

          _isLoading = false;

          if (!_canLoadAds()) {
            unawaited(_safeDispose(ad));
            return;
          }

          _cachedAd = ad;
          _loadedAt = _now();

          debugPrint('$adName ad loaded.');
        },
        onFailed: (error) {
          if (generation != _loadGeneration) return;

          _isLoading = false;

          debugPrint(
            '$adName ad failed to load: $error',
          );
        },
      );
    } catch (error) {
      if (generation == _loadGeneration) {
        _isLoading = false;
      }

      debugPrint('$adName load exception: $error');
    }
  }

  @protected
  Future<bool> showCachedAd({
    required Future<void> Function(
        T ad,
        VoidCallback onShown,
        VoidCallback onDismissed,
        void Function(Object error) onFailed,
        ) presentAd,
    VoidCallback? onAdShown,
    bool Function()? canPresentAd,
  }) async {
    if (_isShowing || !_canLoadAds()) {
      return false;
    }

    if (!isReady) {
      unawaited(loadAd());
      return false;
    }

    _isShowing = true;

    final generation = _loadGeneration;

    try {
      final allowed = await _canRequestAds();

      if (generation != _loadGeneration ||
          !allowed ||
          !_canLoadAds()) {
        _isShowing = false;
        _clearCachedAd();

        return false;
      }

      if (canPresentAd != null && !canPresentAd()) {
        _isShowing = false;
        return false;
      }
    } catch (error) {
      _isShowing = false;

      debugPrint(
        '$adName pre-show check error: $error',
      );

      return false;
    }

    final ad = _cachedAd;

    if (ad == null || _isExpired) {
      _isShowing = false;
      _clearCachedAd();
      unawaited(loadAd());

      return false;
    }

    _cachedAd = null;
    _loadedAt = null;

    final completer = Completer<bool>();

    bool wasShown = false;
    bool finished = false;

    void finish() {
      if (finished) return;

      finished = true;

      unawaited(_safeDispose(ad));

      _isShowing = false;

      completer.complete(wasShown);

      if (generation == _loadGeneration) {
        unawaited(loadAd());
      }
    }

    void handleShown() {
      if (finished || wasShown) return;

      wasShown = true;

      debugPrint('$adName ad shown.');

      try {
        onAdShown?.call();
      } catch (error) {
        debugPrint(
          '$adName onAdShown error: $error',
        );
      }
    }

    void handleDismissed() {
      debugPrint('$adName ad dismissed.');

      finish();
    }

    void handleFailed(Object error) {
      debugPrint(
        '$adName failed to show: $error',
      );

      finish();
    }

    try {
      await presentAd(
        ad,
        handleShown,
        handleDismissed,
        handleFailed,
      );
    } catch (error) {
      handleFailed(error);
    }

    return completer.future;
  }

  Future<void> _safeDispose(T ad) async {
    try {
      await disposeAd(ad);
    } catch (error) {
      debugPrint(
        '$adName dispose error: $error',
      );
    }
  }

  void _clearCachedAd() {
    final ad = _cachedAd;

    _cachedAd = null;
    _loadedAt = null;

    if (ad != null) {
      unawaited(_safeDispose(ad));
    }
  }

  void dispose() {
    _loadGeneration++;

    _clearCachedAd();

    _isLoading = false;
  }
}
