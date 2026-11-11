import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class ButtonSoundService {
  ButtonSoundService._();

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> initialize() async {
    // Buton sesi müziğin ses odağını almasın.
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

  static Future<void> play() async {
    try {
      await _player.stop();

      await _player.play(
        AssetSource('sounds/tombi_button_pop.mp3'),
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
