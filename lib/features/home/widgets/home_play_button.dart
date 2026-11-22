
import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../l10n/app_localizations.dart';

class HomePlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HomePlayButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).playAccessibility,
      child: GestureDetector(
        onTap: onPressed,
        child: Image.asset(
          AssetPaths.playButton,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
