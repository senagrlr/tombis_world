import 'package:flutter/material.dart';

import '../../../core/constants/asset_paths.dart';

class CompletionActions extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  const CompletionActions({
    super.key,
    required this.onHome,
    required this.onDownload,
    required this.onShare,
  });

  static const double buttonWidth = 52;
  static const double buttonHeight = 40;

  static Widget actionButton(
      String asset,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        actionButton(
          AssetPaths.completionHomeButton,
          onHome,
        ),
        const SizedBox(height: 5),
        actionButton(
          AssetPaths.completionDownloadButton,
          onDownload,
        ),
        const Spacer(),
        actionButton(
          AssetPaths.completionShareButton,
          onShare,
        ),
      ],
    );
  }
}
