
import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';

class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        AssetPaths.homeBackground,
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }
}
