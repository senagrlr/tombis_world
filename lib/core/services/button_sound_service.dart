import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

import '../constants/asset_paths.dart';

class ButtonSoundService {
  ButtonSoundService._();

  static final AudioPlayer _player = AudioPlayer();

  static bool _enabled = true;

  static Future<void> initialize() async {
    await _player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          usageType: AndroidUsageType.assistanceSonification,
          contentType: AndroidContentType.sonification,
          audioFocus: AndroidAudioFocus.none,
        ),
      ),
    );

    await _player.setPlayerMode(PlayerMode.lowLatency);
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setVolume(0.1);
  }

  static Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;

    if (!enabled) {
      await _player.stop();
    }
  }

  static Future<void> play() async {
    if (!_enabled) return;

    try {
      await _player.stop();

      if (!_enabled) return;

      await _player.play(
        AssetSource(AssetPaths.buttonSound),
      );
    } catch (e) {
      debugPrint('Buton sesi hatası: $e');
    }
  }

  static void tap(VoidCallback action) {
    play();
    action();
  }
}
