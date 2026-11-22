
class SettingsState {
  final bool music;
  final bool sound;
  final bool notification;

  const SettingsState({
    this.music = true,
    this.sound = true,
    this.notification = false,
  });

  SettingsState copyWith({
    bool? music,
    bool? sound,
    bool? notification,
  }) {
    return SettingsState(
      music: music ?? this.music,
      sound: sound ?? this.sound,
      notification: notification ?? this.notification,
    );
  }
}
