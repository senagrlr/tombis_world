
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/services/button_sound_service.dart';

import '../widgets/home_background.dart';
import '../widgets/home_logo.dart';
import '../widgets/home_play_button.dart';
import '../widgets/home_settings_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              const HomeBackground(),

              // Settings Button - 52 x 40
              Positioned(
                top: height * 0.05,
                left: width * 0.09,
                child: SizedBox(
                  width: 52,
                  height: 40,
                  child: HomeSettingsButton(
                    onPressed: () {
                      ButtonSoundService.play();
                      context.push(AppRoutes.settings);
                    },
                  ),
                ),
              ),

              // Home Logo
              Positioned(
                top: height * 0.16,
                left: width * 0.13,
                width: width * 0.74,
                child: const HomeLogo(),
              ),

              // Play Button
              Positioned(
                top: height * 0.38,
                left: width * 0.265,
                width: width * 0.47,
                child: HomePlayButton(
                  onPressed: () {
                    ButtonSoundService.play();
                    context.push(AppRoutes.gallery);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
