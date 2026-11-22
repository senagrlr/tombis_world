import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/background_music_service.dart';
import '../../../l10n/app_localizations.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _openHome();
      }
    });
  }

  void _openHome() {
    if (!mounted || _navigated) return;

    _navigated = true;

    BackgroundMusicService.start();

    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBg,
      body: Center(
        child: Lottie.asset(
          'assets/animations/splash_animation.json',
          controller: _controller,
          width: 300,
          height: 300,
          fit: BoxFit.contain,
          repeat: false,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
          errorBuilder: (context, error, stackTrace) {
            return Text(AppLocalizations.of(context).splashLoadError);
          },
        ),
      ),
    );
  }
}
