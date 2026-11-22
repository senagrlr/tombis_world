
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/services/notification_startup_service.dart';
import '../core/services/background_music_service.dart';
import 'app_router.dart';

class TombisWorldApp extends ConsumerStatefulWidget {
  const TombisWorldApp({super.key});

  @override
  ConsumerState<TombisWorldApp> createState() => _TombisWorldAppState();
}

class _TombisWorldAppState extends ConsumerState<TombisWorldApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      NotificationStartupService.initialize(ref);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _resumeMusicIfEnabled();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        BackgroundMusicService.pause();
        break;
    }
  }

  Future<void> _resumeMusicIfEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted ||
        WidgetsBinding.instance.lifecycleState !=
            AppLifecycleState.resumed) {
      return;
    }

    final musicEnabled = prefs.getBool('music') ?? true;

    if (musicEnabled) {
      await BackgroundMusicService.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,

        onGenerateTitle: (context) =>
        AppLocalizations.of(context).appTitle,

        supportedLocales: AppLocalizations.supportedLocales,

        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],

        theme: AppTheme.light,
        routerConfig: appRouter,

        builder: (context, child) {
          return ColoredBox(
            color: AppColors.background,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
