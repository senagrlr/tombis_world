
import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetPaths.homeLogo,
      fit: BoxFit.contain,
    );
  }
}
