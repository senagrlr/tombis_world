
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

  Widget _button(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        asset,
        width: 52,
        height: 42,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const path = 'assets/images/completion_ui/';

    return Column(
      children: [
        _button('${path}home_button.png', onHome),
        const SizedBox(height: 5),
        _button('${path}download_button.png', onDownload),
        const Spacer(),
        _button('${path}share_button.png', onShare),
      ],
    );
  }
}
