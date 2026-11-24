
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/services/button_sound_service.dart';
import '../../../l10n/app_localizations.dart';

class AdUnavailableDialog extends StatelessWidget {
  const AdUnavailableDialog({super.key});

  static const Color _backgroundColor = Color(0xFFFFF5E5);
  static const Color _textColor = Color(0xFF704B36);
  static const Color _buttonColor = Color(0xFFA9D59B);
  static const Color _buttonTextColor = Color(0xFF385D32);

  static const String _iconPath =
      'assets/images/gallery/popups/ad_unavailable_icon.svg';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: _backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 310,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                _iconPath,
                width: 64,
                height: 64,
              ),

              const SizedBox(height: 12),

              Text(
                l10n.adUnavailableTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _textColor,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                l10n.adUnavailableMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: _textColor,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    ButtonSoundService.play();
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: _buttonColor,
                    foregroundColor: _buttonTextColor,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.adUnavailableOkay,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
