import 'package:flutter/material.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../l10n/app_localizations.dart';

class LeaveColoringDialog extends StatelessWidget {
  const LeaveColoringDialog({super.key});

  static const Color _cream = Color(0xFFF8EFDE);
  static const Color _border = Color(0xFF9E7D5C);
  static const Color _titleColor = Color(0xFF69472F);
  static const Color _messageColor = Color(0xFFA57553);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screen = MediaQuery.sizeOf(context);

    final popupWidth =
    (screen.width - 36).clamp(0.0, 420.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 24,
      ),
      child: SizedBox(
        width: popupWidth,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 26),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  22,
                  34,
                  22,
                  55,
                ),
                decoration: BoxDecoration(
                  color: _cream,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: _border,
                    width: 5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.leaveColoringTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: _titleColor,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      l10n.leaveColoringMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _messageColor,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Panelin altından taşan onay butonları.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _imageButton(
                  asset: AssetPaths.rateNo,
                  onTap: () {
                    Navigator.of(context).pop(false);
                  },
                ),

                const SizedBox(width: 38),

                _imageButton(
                  asset: AssetPaths.rateYes,
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageButton({
    required String asset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Image.asset(
        asset,
        width: 56,
        height: 56,
        fit: BoxFit.contain,
      ),
    );
  }
}
