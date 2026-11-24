
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/constants/asset_paths.dart';
import 'core/theme/app_colors.dart';
import 'core/services/background_music_service.dart';
import 'core/services/button_sound_service.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/tombi_loading.dart';
import 'core/ads/ad_frequency_controller.dart';
import 'core/ads/ad_coordinator.dart';
import 'core/session/session_timeout_controller.dart';
import 'core/session/session_lifecycle_controller.dart';
import 'features/gallery/controllers/session_unlock_controller.dart';
import 'features/settings/repositories/settings_repository.dart';

final _sessionLifecycleController = SessionLifecycleController(
  timeoutController: SessionTimeoutController(),
  onSessionExpired: SessionUnlockController.instance.resetSession,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AdFrequencyController.instance.initialize();

  _sessionLifecycleController.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  await TombiLoading.preload();

  await _preloadGalleryBackground();

  final settingsRepository = SettingsRepository();

  final settings = await settingsRepository.loadSettings();

  await ButtonSoundService.initialize();
  await ButtonSoundService.setEnabled(settings.sound);

  await BackgroundMusicService.initialize();
  await BackgroundMusicService.setEnabled(settings.music);

  await NotificationService.instance.initialize();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          settingsRepository,
        ),
      ],
      child: const TombisWorldApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(AdCoordinator.instance.initialize());
  });
}

Future<void> _preloadGalleryBackground() async {
  const imageProvider = AssetImage(
    AssetPaths.galleryBackground,
  );

  final imageStream = imageProvider.resolve(
    const ImageConfiguration(),
  );

  final completer = Completer<void>();

  late ImageStreamListener listener;

  listener = ImageStreamListener(
        (image, synchronousCall) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    },
    onError: (error, stackTrace) {
      debugPrint('Gallery background preload error: $error');

      if (!completer.isCompleted) {
        completer.complete();
      }
    },
  );

  imageStream.addListener(listener);

  try {
    await completer.future;
  } finally {
    imageStream.removeListener(listener);
  }
}
