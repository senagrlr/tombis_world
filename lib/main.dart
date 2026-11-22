import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/theme/app_colors.dart';
import 'core/services/background_music_service.dart';
import 'core/services/button_sound_service.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/tombi_loading.dart';

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

  // Kullanıcının kayıtlı ses tercihlerini oku.
  final prefs = await SharedPreferences.getInstance();

  final musicEnabled = prefs.getBool('music') ?? true;
  final soundEnabled = prefs.getBool('sound') ?? true;

  // Buton seslerini başlat ve tercihi uygula.
  await ButtonSoundService.initialize();
  await ButtonSoundService.setEnabled(soundEnabled);

  // Arka plan müziğini başlat ve tercihi uygula.
  await BackgroundMusicService.initialize();
  await BackgroundMusicService.setEnabled(musicEnabled);

  // Bildirim servisini başlat.
  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: TombisWorldApp(),
    ),
  );
}

// Galeri arka planını önceden çözümleyip önbelleğe al.
Future<void> _preloadGalleryBackground() async {
  const imageProvider = AssetImage(
    'assets/images/gallery/gallery_background.png',
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
