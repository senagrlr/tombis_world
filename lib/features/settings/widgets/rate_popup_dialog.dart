import 'package:flutter/material.dart';

class RatePopupDialog extends StatelessWidget {
  final VoidCallback onYes;

  const RatePopupDialog({
    super.key,
    required this.onYes,
  });

  static const Color _brown = Color(0xFF9D6D4D);
  static const Color _darkBrown = Color(0xFF704A35);
  static const Color _cream = Color(0xFFF9EFDF);

  static const String _assets =
      'assets/images/rate_popup/';

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);

    final popupWidth =
    (screen.width - 36).clamp(260.0, 380.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      child: SizedBox(
        width: popupWidth,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 350,
            height: 440,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Daha kısa krem panel
                Positioned(
                  top: 135,
                  left: 0,
                  right: 0,
                  bottom: 28,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cream,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: _brown,
                        width: 6,
                      ),
                    ),
                  ),
                ),

                // Başlık, açıklama ve yıldızlar
                Positioned(
                  top: 155,
                  left: 18,
                  right: 18,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Rate Us!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: _darkBrown,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Enjoying Tombi's World?\n"
                            "We'd be so happy if you\n"
                            "could rate us!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                          color: _brown,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Beş yıldız tek PNG içinde.
                      Image.asset(
                        '${_assets}rate_star.png',
                        width: 245,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                // Biraz büyütülmüş Tombi
                Positioned(
                  top: 0,
                  child: Image.asset(
                    '${_assets}rate_tombi.png',
                    width: 230,
                    height: 175,
                    fit: BoxFit.contain,
                  ),
                ),

                // Alt butonlar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      _imageButton(
                        asset: 'rate_no.png',
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),

                      const SizedBox(width: 65),

                      _imageButton(
                        asset: 'rate_yes.png',
                        onTap: onYes,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        '$_assets$asset',
        width: 76,
        height: 76,
        fit: BoxFit.contain,
      ),
    );
  }
}
