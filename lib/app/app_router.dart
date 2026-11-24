
import 'dart:typed_data';

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
        final imagePath = state.extra as String;

        return ColoringPageScreen(
          imagePath: imagePath,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.completion,
      name: AppRoutes.completion,
      builder: (context, state) {
        final extra = state.extra;

        if (extra is Map<String, dynamic>) {
          return CompletionPage(
            imagePath: extra['imagePath'] as String,
            paintedImage:
            extra['paintedImage'] as Uint8List?,
            showRatePopup:
            extra['showRatePopup'] as bool? ?? false,
          );
        }

        return CompletionPage(
          imagePath: extra as String,
        );
      },
    ),
  ],
);
