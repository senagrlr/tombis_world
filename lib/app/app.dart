import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'app_router.dart';

class TombisWorldApp extends StatelessWidget {
  const TombisWorldApp({super.key});

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
        title: "Tombi's World",
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
