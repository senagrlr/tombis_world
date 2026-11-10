
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_option.dart';
import '../widgets/rate_us_button.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      ('music', 'Music', Icons.music_note),
                      ('sound', 'Sound', Icons.volume_up),
                      ('notification', 'Notification',
                      Icons.notifications),
                    ])
                      SettingsOption(
                        title: item.$2,
                        icon: item.$3,
                        value: settings?[item.$1] ?? false,
                        onChanged: settings == null
                            ? null
                            : (value) =>
                            controller.updateSetting(item.$1, value),
                      ),
                    SettingsOption(
                      title: 'Privacy',
                      icon: Icons.description,
                      onTap: () {},
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
