import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';

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
      label: 'Settings',
      child: GestureDetector(
        onTap: onPressed,
        child: Image.asset(
          AssetPaths.settingsIcon,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
