import 'package:flutter/material.dart';

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
    const path = 'assets/images/completion_ui/';

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        actionButton(
          '${path}home_button.png',
          onHome,
        ),
        const SizedBox(height: 5),
        actionButton(
          '${path}download_button.png',
          onDownload,
        ),
        const Spacer(),
        actionButton(
          '${path}share_button.png',
          onShare,
        ),
      ],
    );
  }
}
