
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/asset_paths.dart';

class CozyBackButton extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback? onTap;

  const CozyBackButton({
    super.key,
    this.width = 52,
    this.height = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap ??
                () {
              if (context.canPop()) {
                context.pop();
              }
            },
        child: SizedBox(
          width: width,
          height: height,
          child: Image.asset(
            AssetPaths.backButton,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
