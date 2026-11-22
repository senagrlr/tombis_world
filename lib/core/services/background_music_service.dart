import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class BackgroundMusicService {
  BackgroundMusicService._();

  static final AudioPlayer _player = AudioPlayer();

  static bool _initialized = false;
  static bool _started = false;
  static bool _enabled = true;

  static Future<void> initialize() async {
    if (_initialized) return;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0.25);

    _initialized = true;
  }

  static Future<void> start() async {
    if (!_enabled || _started) return;

    try {
      await initialize();

      if (!_enabled) return;

      await _player.play(
        AssetSource('sounds/tombi_cozy_background.wav'),
      );

      _started = true;
    } catch (e) {
      _started = false;
      debugPrint('Müzik başlatma hatası: $e');
    }
  }

  static Future<void> pause() async {
    if (!_started) return;

    await _player.pause();
  }

  static Future<void> resume() async {
    if (!_enabled) return;

    if (!_started) {
      await start();
      return;
    }

    await _player.resume();
  }

  static Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;

    if (enabled) {
      await resume();
    } else {
      await pause();
    }
  }

  static Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }
}
