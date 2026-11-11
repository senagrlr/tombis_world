import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';

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
      label: 'Play',
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
