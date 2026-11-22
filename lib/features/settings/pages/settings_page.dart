import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/services/button_sound_service.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_option.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider).asData?.value;
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/gallery/gallery_background.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SettingsHeader(),

              Expanded(
                child: Align(
                  alignment: const Alignment(0, -0.45),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final item in [
                          (
                          'music',
                          l10n.music,
                          'assets/images/settings/music_icon.png',
                          ),
                          (
                          'sound',
                          l10n.sound,
                          'assets/images/settings/sound_icon.png',
                          ),
                          (
                          'notification',
                          l10n.notification,
                          'assets/images/settings/notification_icon.png',
                          ),
                        ]) ...[
                          SettingsOption(
                            title: item.$2,
                            iconPath: item.$3,
                            value: settings == null
                                ? false
                                : switch (item.$1) {
                              'music' => settings.music,
                              'sound' => settings.sound,
                              'notification' =>
                              settings.notification,
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

                          const SizedBox(height: 18),
                        ],

                        const SizedBox(height: 8),

                        SettingsOption(
                          title: l10n.privacy,
                          iconPath:
                          'assets/images/settings/document_icon.png',
                          onTap: () {
                            ButtonSoundService.play();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
