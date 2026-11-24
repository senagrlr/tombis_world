import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class SvgLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const SvgLoadError({
    super.key,
    required this.onRetry,
  });

  static const Color _textColor = Color(0xFFA37352);
  static const Color _buttonColor = Color(0xFFFAF0E0);
  static const Color _iconColor = Color(0xFF6E4B33);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: _iconColor,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.svgLoadError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                foregroundColor: _textColor,
                surfaceTintColor: Colors.transparent,
              ),
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}
