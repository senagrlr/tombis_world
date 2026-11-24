
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tombis_world/app/app.dart';
import 'package:tombis_world/features/splash/pages/splash_page.dart';
import 'package:tombis_world/features/settings/controllers/settings_controller.dart';
import 'package:tombis_world/features/settings/models/settings_state.dart';

class FakeSettingsController extends SettingsController {
  @override
  Future<SettingsState> build() async {
    return SettingsState(
      music: false,
      sound: false,
      notification: false,
    );
  }
}

void main() {
  testWidgets(
    'App starts successfully on splash screen',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'notification_permission_asked': true,
        'notification': false,
        'music': false,
        'sound': false,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith(
              FakeSettingsController.new,
            ),
          ],
          child: const TombisWorldApp(),
        ),
      );

      await tester.pump();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(SplashPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
