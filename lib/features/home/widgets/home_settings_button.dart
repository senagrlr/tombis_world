import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../l10n/app_localizations.dart';

class HomeSettingsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HomeSettingsButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).settings,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          width: 52,
          height: 40,
          child: Image.asset(
            AssetPaths.settingsIcon,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
