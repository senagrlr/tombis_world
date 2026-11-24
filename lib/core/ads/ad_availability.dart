
import 'ad_consent_service.dart';

class AdAvailability {
  AdAvailability({
    required bool Function() hasConsent,
  }) : _hasConsent = hasConsent;

  static final AdAvailability instance = AdAvailability(
    hasConsent: () =>
    AdConsentService.instance.canRequestAds,
  );

  final bool Function() _hasConsent;

  bool _isSdkInitialized = false;

  bool get isSdkInitialized => _isSdkInitialized;

  bool get canLoadAds =>
      _isSdkInitialized && _hasConsent();

  void markSdkInitialized() {
    _isSdkInitialized = true;
  }
}
