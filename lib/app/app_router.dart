
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/splash/pages/splash_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../features/gallery/pages/gallery_page.dart';
import '../features/coloring/pages/coloring_page.dart';
import '../features/completion/pages/completion_page.dart';

import '../core/ads/ad_coordinator.dart';
import '../core/ads/ad_navigation_observer.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const home = '/';
  static const settings = '/settings';
  static const gallery = '/gallery';
  static const coloring = '/coloring';
  static const completion = '/completion';
}

class InvalidRouteDataPage extends StatelessWidget {
  const InvalidRouteDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sayfa açılamadı. Gerekli bilgiler eksik.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.gallery),
              child: const Text('Galeriye dön'),
            ),
          ],
        ),
      ),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  observers: [
    AdNavigationObserver(
      onNavigation:
      AdCoordinator.instance.registerNavigation,
      onColoringChanged:
      AdCoordinator.instance.setColoringActive,
      onNaturalBreak:
      AdCoordinator.instance.showInterstitialAtNaturalBreak,
      coloringRouteName: AppRoutes.coloring,
      completionRouteName: AppRoutes.completion,
      splashRouteName: AppRoutes.splash,
      naturalBreakDestinations: const {
        AppRoutes.home,
        AppRoutes.gallery,
      },
    ),
  ],
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.gallery,
      name: AppRoutes.gallery,
      builder: (context, state) => const GalleryPage(),
    ),
    GoRoute(
      path: AppRoutes.coloring,
      name: AppRoutes.coloring,
      builder: (context, state) {
        final extra = state.extra;

        if (extra is! String || extra.trim().isEmpty) {
          return const InvalidRouteDataPage();
        }

        return ColoringPageScreen(
          imagePath: extra,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.completion,
      name: AppRoutes.completion,
      builder: (context, state) {
        final extra = state.extra;

        if (extra is String && extra.trim().isNotEmpty) {
          return CompletionPage(
            imagePath: extra,
          );
        }

        if (extra is Map) {
          final imagePath = extra['imagePath'];
          final paintedImage = extra['paintedImage'];
          final showRatePopup = extra['showRatePopup'];

          if (imagePath is! String || imagePath.trim().isEmpty) {
            return const InvalidRouteDataPage();
          }

          if (paintedImage != null && paintedImage is! Uint8List) {
            return const InvalidRouteDataPage();
          }

          if (showRatePopup != null && showRatePopup is! bool) {
            return const InvalidRouteDataPage();
          }

          return CompletionPage(
            imagePath: imagePath,
            paintedImage: paintedImage as Uint8List?,
            showRatePopup: showRatePopup as bool? ?? false,
          );
        }

        return const InvalidRouteDataPage();
      },
    ),
  ],
);
