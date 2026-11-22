
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/services/button_sound_service.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_option.dart';
import '../widgets/rate_us_button.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider).asData?.value;
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SettingsHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    for (final item in [
                      ('music', l10n.music, Icons.music_note),
                      ('sound', l10n.sound, Icons.volume_up),
                      (
                      'notification',
                      l10n.notification,
                      Icons.notifications,
                      ),
                    ])
                      SettingsOption(
                        title: item.$2,
                        icon: item.$3,
                        value: settings == null
                            ? false
                            : switch (item.$1) {
                          'music' => settings.music,
                          'sound' => settings.sound,
                          'notification' => settings.notification,
                          _ => false,
                        },
                        onChanged: settings == null
                            ? null
                            : (value) {
                          ButtonSoundService.tap(() {
                            controller.updateSetting(
                              item.$1,
                              value,
                            );
                          });
                        },
                      ),

                    SettingsOption(
                      title: l10n.privacy,
                      icon: Icons.description,
                      onTap: () {
                        ButtonSoundService.play();
                      },
                    ),

                    const Spacer(flex: 3),
                    const RateUsButton(),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
