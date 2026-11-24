
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdConsentService {
  AdConsentService._();

  static final AdConsentService instance = AdConsentService._();

  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;

  Future<bool>? _consentOperation;

  bool get canRequestAds => _canRequestAds;

  bool get privacyOptionsRequired => _privacyOptionsRequired;

  Future<bool> gatherConsent() {
    return _consentOperation ??= _gatherConsentInternal()
        .whenComplete(() {
      _consentOperation = null;
    });
  }

  Future<bool> _gatherConsentInternal() async {
    _canRequestAds = false;

    try {
      final completer = Completer<bool>();

      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
            () {
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
            (error) {
          debugPrint(
            'Consent update error: ${error.message}',
          );

          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      final updateSuccessful = await completer.future;

      // Formu yalnızca izin bilgisi başarıyla güncellendiyse yükle.
      if (updateSuccessful) {
        final formCompleter = Completer<void>();

        ConsentForm.loadAndShowConsentFormIfRequired(
              (error) {
            if (error != null) {
              debugPrint(
                'Consent form error: ${error.message}',
              );
            }

            if (!formCompleter.isCompleted) {
              formCompleter.complete();
            }
          },
        );

        await formCompleter.future;
      }

      // Güncelleme başarısız olsa bile daha önce kaydedilmiş
      // geçerli bir izin durumu bulunabilir.
      await _refreshConsentState();

    } catch (error) {
      _canRequestAds = false;

      debugPrint('Consent service error: $error');
    }

    debugPrint(
      'Consent completed. Can request ads: $_canRequestAds',
    );

    return _canRequestAds;
  }

  Future<void> _refreshConsentState() async {
    _canRequestAds =
    await ConsentInformation.instance.canRequestAds();

    _privacyOptionsRequired =
        await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
            PrivacyOptionsRequirementStatus.required;
  }

  Future<void> showPrivacyOptions() async {
    if (_consentOperation != null ||
        !_privacyOptionsRequired) {
      return;
    }

    _consentOperation = _showPrivacyOptionsInternal()
        .whenComplete(() {
      _consentOperation = null;
    });

    await _consentOperation;
  }

  Future<bool> _showPrivacyOptionsInternal() async {
    _canRequestAds = false;

    try {
      final completer = Completer<void>();

      ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) {
          debugPrint(
            'Privacy options error: ${error.message}',
          );
        }

        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      await completer.future;

      await _refreshConsentState();

    } catch (error) {
      _canRequestAds = false;

      debugPrint('Privacy options exception: $error');
    }

    return _canRequestAds;
  }
}
