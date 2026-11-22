
import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

class NotificationMessages {
  NotificationMessages._();

  static AppLocalizations get _l10n {
    final deviceLocales =
        WidgetsBinding.instance.platformDispatcher.locales;

    for (final locale in deviceLocales) {
      if (!AppLocalizations.supportedLocales.any(
            (supported) =>
        supported.languageCode == locale.languageCode,
      )) {
        continue;
      }

      if (locale.languageCode == 'pt') {
        return lookupAppLocalizations(
          locale.countryCode == 'BR'
              ? const Locale('pt', 'BR')
              : const Locale('pt'),
        );
      }

      return lookupAppLocalizations(
        Locale(locale.languageCode),
      );
    }

    return lookupAppLocalizations(const Locale('en'));
  }

  static String get title => _l10n.notificationTitle;

  static List<String> get messages {
    final l10n = _l10n;

    return [
      l10n.notificationMessage01,
      l10n.notificationMessage02,
      l10n.notificationMessage03,
      l10n.notificationMessage04,
      l10n.notificationMessage05,
      l10n.notificationMessage06,
      l10n.notificationMessage07,
      l10n.notificationMessage08,
      l10n.notificationMessage09,
      l10n.notificationMessage10,
      l10n.notificationMessage11,
      l10n.notificationMessage12,
      l10n.notificationMessage13,
      l10n.notificationMessage14,
      l10n.notificationMessage15,
      l10n.notificationMessage16,
      l10n.notificationMessage17,
      l10n.notificationMessage18,
      l10n.notificationMessage19,
      l10n.notificationMessage20,
    ];
  }
}
