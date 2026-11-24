import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tombi\'s World'**
  String get appTitle;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate us'**
  String get rateUs;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @galleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Tombi’s\nAdventures'**
  String get galleryTitle;

  /// No description provided for @brush.
  ///
  /// In en, this message translates to:
  /// **'Brush'**
  String get brush;

  /// No description provided for @fill.
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get fill;

  /// No description provided for @eraser.
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get eraser;

  /// No description provided for @picker.
  ///
  /// In en, this message translates to:
  /// **'Picker'**
  String get picker;

  /// No description provided for @resetColoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Coloring?'**
  String get resetColoringTitle;

  /// No description provided for @finishColoringError.
  ///
  /// In en, this message translates to:
  /// **'Could not finish coloring. Please try again.'**
  String get finishColoringError;

  /// No description provided for @noImageToSave.
  ///
  /// In en, this message translates to:
  /// **'No image available to save.'**
  String get noImageToSave;

  /// No description provided for @imageSaved.
  ///
  /// In en, this message translates to:
  /// **'Image saved to gallery!'**
  String get imageSaved;

  /// No description provided for @saveImageError.
  ///
  /// In en, this message translates to:
  /// **'Could not save image. Please try again.'**
  String get saveImageError;

  /// No description provided for @noImageToShare.
  ///
  /// In en, this message translates to:
  /// **'No image available to share.'**
  String get noImageToShare;

  /// No description provided for @shareImageError.
  ///
  /// In en, this message translates to:
  /// **'Could not share image. Please try again.'**
  String get shareImageError;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @playStoreOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open Play Store'**
  String get playStoreOpenError;

  /// No description provided for @splashLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load animation.'**
  String get splashLoadError;

  /// No description provided for @svgLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load SVG:\n{error}'**
  String svgLoadError(String error);

  /// No description provided for @adUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get adUnavailableTitle;

  /// No description provided for @adUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'The ad isn\'t available right now. Please try again later!'**
  String get adUnavailableMessage;

  /// No description provided for @adUnavailableOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get adUnavailableOkay;

  /// No description provided for @shareArtworkText.
  ///
  /// In en, this message translates to:
  /// **'I colored this picture in Tombi\'s World! 🎨💖'**
  String get shareArtworkText;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Tombi\'s World'**
  String get notificationTitle;

  /// No description provided for @palettePastel.
  ///
  /// In en, this message translates to:
  /// **'Pastel'**
  String get palettePastel;

  /// No description provided for @paletteNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get paletteNature;

  /// No description provided for @paletteTombi.
  ///
  /// In en, this message translates to:
  /// **'Tombi'**
  String get paletteTombi;

  /// No description provided for @paletteCandy.
  ///
  /// In en, this message translates to:
  /// **'Candy'**
  String get paletteCandy;

  /// No description provided for @paletteDreamy.
  ///
  /// In en, this message translates to:
  /// **'Dreamy'**
  String get paletteDreamy;

  /// No description provided for @galleryFarmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get galleryFarmer;

  /// No description provided for @gallerySakura.
  ///
  /// In en, this message translates to:
  /// **'Sakura'**
  String get gallerySakura;

  /// No description provided for @galleryPainter.
  ///
  /// In en, this message translates to:
  /// **'Painter'**
  String get galleryPainter;

  /// No description provided for @galleryGarden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get galleryGarden;

  /// No description provided for @galleryWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get galleryWinter;

  /// No description provided for @gallerySummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get gallerySummer;

  /// No description provided for @gallerySpring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get gallerySpring;

  /// No description provided for @galleryAmusumentPark.
  ///
  /// In en, this message translates to:
  /// **'Amusument Park'**
  String get galleryAmusumentPark;

  /// No description provided for @galleryChef.
  ///
  /// In en, this message translates to:
  /// **'Chef'**
  String get galleryChef;

  /// No description provided for @galleryHalloween.
  ///
  /// In en, this message translates to:
  /// **'Halloween'**
  String get galleryHalloween;

  /// No description provided for @galleryTailor.
  ///
  /// In en, this message translates to:
  /// **'Tailor'**
  String get galleryTailor;

  /// No description provided for @gallerySkater.
  ///
  /// In en, this message translates to:
  /// **'Skater'**
  String get gallerySkater;

  /// No description provided for @gallerySchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get gallerySchool;

  /// No description provided for @galleryNewyearEve.
  ///
  /// In en, this message translates to:
  /// **'New Year Eve'**
  String get galleryNewyearEve;

  /// No description provided for @galleryIceCream.
  ///
  /// In en, this message translates to:
  /// **'Ice Cream'**
  String get galleryIceCream;

  /// No description provided for @galleryGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get galleryGym;

  /// No description provided for @galleryFlowerShop.
  ///
  /// In en, this message translates to:
  /// **'Flower Shop'**
  String get galleryFlowerShop;

  /// No description provided for @galleryBedTime.
  ///
  /// In en, this message translates to:
  /// **'Bed Time'**
  String get galleryBedTime;

  /// No description provided for @galleryAstronaut.
  ///
  /// In en, this message translates to:
  /// **'Astronaut'**
  String get galleryAstronaut;

  /// No description provided for @galleryAquarium.
  ///
  /// In en, this message translates to:
  /// **'Aquarium'**
  String get galleryAquarium;

  /// No description provided for @notificationMessage01.
  ///
  /// In en, this message translates to:
  /// **'Tombi is waiting for you! 🐱'**
  String get notificationMessage01;

  /// No description provided for @notificationMessage02.
  ///
  /// In en, this message translates to:
  /// **'Let\'s add some color to your day! 🎨'**
  String get notificationMessage02;

  /// No description provided for @notificationMessage03.
  ///
  /// In en, this message translates to:
  /// **'It\'s coloring time with Tombi! 💖'**
  String get notificationMessage03;

  /// No description provided for @notificationMessage04.
  ///
  /// In en, this message translates to:
  /// **'Ready for a colorful adventure? 🌈'**
  String get notificationMessage04;

  /// No description provided for @notificationMessage05.
  ///
  /// In en, this message translates to:
  /// **'Let your imagination shine! ✨'**
  String get notificationMessage05;

  /// No description provided for @notificationMessage06.
  ///
  /// In en, this message translates to:
  /// **'A lovely day with Tombi awaits! 🐱'**
  String get notificationMessage06;

  /// No description provided for @notificationMessage07.
  ///
  /// In en, this message translates to:
  /// **'What\'s your favorite color? 🎨'**
  String get notificationMessage07;

  /// No description provided for @notificationMessage08.
  ///
  /// In en, this message translates to:
  /// **'How about coloring something new today? 💕'**
  String get notificationMessage08;

  /// No description provided for @notificationMessage09.
  ///
  /// In en, this message translates to:
  /// **'Come have fun with Tombi! 🌸'**
  String get notificationMessage09;

  /// No description provided for @notificationMessage10.
  ///
  /// In en, this message translates to:
  /// **'Get your colors ready! Tombi is waiting! 🖌️'**
  String get notificationMessage10;

  /// No description provided for @notificationMessage11.
  ///
  /// In en, this message translates to:
  /// **'How about a little coloring break? 💛'**
  String get notificationMessage11;

  /// No description provided for @notificationMessage12.
  ///
  /// In en, this message translates to:
  /// **'Today\'s coloring page is waiting! 🌈'**
  String get notificationMessage12;

  /// No description provided for @notificationMessage13.
  ///
  /// In en, this message translates to:
  /// **'Explore a world of colors with Tombi! ✨'**
  String get notificationMessage13;

  /// No description provided for @notificationMessage14.
  ///
  /// In en, this message translates to:
  /// **'Let\'s color together! 🎨'**
  String get notificationMessage14;

  /// No description provided for @notificationMessage15.
  ///
  /// In en, this message translates to:
  /// **'Which colors will you choose today? 🐱'**
  String get notificationMessage15;

  /// No description provided for @notificationMessage16.
  ///
  /// In en, this message translates to:
  /// **'Show your creativity with Tombi! 💖'**
  String get notificationMessage16;

  /// No description provided for @notificationMessage17.
  ///
  /// In en, this message translates to:
  /// **'A colorful world is waiting for you! 🌷'**
  String get notificationMessage17;

  /// No description provided for @notificationMessage18.
  ///
  /// In en, this message translates to:
  /// **'Ready for a new coloring adventure? 🖌️'**
  String get notificationMessage18;

  /// No description provided for @notificationMessage19.
  ///
  /// In en, this message translates to:
  /// **'It\'s time to relax and color with Tombi! 💕'**
  String get notificationMessage19;

  /// No description provided for @notificationMessage20.
  ///
  /// In en, this message translates to:
  /// **'Let\'s make the world a little brighter! 🌈'**
  String get notificationMessage20;

  /// No description provided for @playAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playAccessibility;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'pt',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
