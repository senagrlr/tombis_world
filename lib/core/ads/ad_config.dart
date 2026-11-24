
import 'package:flutter/foundation.dart';

class AdConfig {
  AdConfig._();

  static const bool _enableProductionAds =
  bool.fromEnvironment(
    'ENABLE_PRODUCTION_ADS',
    defaultValue: false,
  );

  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  static const String _testRewardedId =
      'ca-app-pub-3940256099942544/5224354917';

  static const String _productionInterstitialId = '';

  static const String _productionRewardedId = '';

  static bool get useProductionAds =>
      kReleaseMode && _enableProductionAds;

  static String get interstitialAdUnitId =>
      _resolveAdUnitId(
        testId: _testInterstitialId,
        productionId: _productionInterstitialId,
      );

  static String get rewardedAdUnitId =>
      _resolveAdUnitId(
        testId: _testRewardedId,
        productionId: _productionRewardedId,
      );

  static String _resolveAdUnitId({
    required String testId,
    required String productionId,
  }) {
    if (!useProductionAds) {
      return testId;
    }

    if (productionId.trim().isEmpty) {
      throw StateError(
        'Production ad unit ID is missing.',
      );
    }

    return productionId;
  }
}
