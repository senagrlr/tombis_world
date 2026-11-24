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
import 'features/settings/repositories/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Uygulamanın tamamını dikey moda kilitle.
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

  // Tombi loading animasyonunu önceden yükle.
  await TombiLoading.preload();

  // Galeri arka planını uygulama açılırken belleğe yükle.
  await _preloadGalleryBackground();

  // Ayar repository'sini oluştur.
  final settingsRepository = SettingsRepository();

  // Kullanıcının kayıtlı tercihlerini oku.
  final settings = await settingsRepository.loadSettings();

  // Buton seslerini başlat ve tercihi uygula.
  await ButtonSoundService.initialize();
  await ButtonSoundService.setEnabled(settings.sound);

  // Arka plan müziğini başlat ve tercihi uygula.
  await BackgroundMusicService.initialize();
  await BackgroundMusicService.setEnabled(settings.music);

  // Bildirim servisini başlat.
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
}

// Galeri arka planını önceden çözümleyip önbelleğe al.
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
