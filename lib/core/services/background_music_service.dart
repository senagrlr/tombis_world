import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class BackgroundMusicService {
  BackgroundMusicService._();

  static final AudioPlayer _player = AudioPlayer();
  static bool _initialized = false;
  static bool _started = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0.25);

    _initialized = true;
  }

  // Yalnızca ilk başlangıçta müziği aç
  static Future<void> start() async {
    if (_started) return;

    try {
      await initialize();

      _started = true;

      await _player.play(
        AssetSource('sounds/tombi_cozy_background.wav'),
      );
    } catch (e) {
      _started = false;
      debugPrint('Müzik başlatma hatası: $e');
    }
  }

  static Future<void> pause() async {
    await _player.pause();
  }

  static Future<void> resume() async {
    if (!_started) {
      await start();
      return;
    }

    await _player.resume();
  }

  static Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }
}
