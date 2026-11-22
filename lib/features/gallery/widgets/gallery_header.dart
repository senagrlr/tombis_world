
import 'package:flutter/material.dart';
import '../../../core/widgets/cozy_back_button.dart';
import '../../../l10n/app_localizations.dart';

class GalleryHeader extends StatelessWidget {
  const GalleryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: CozyBackButton(
              width: 52,
              height: 40,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            AppLocalizations.of(context).galleryTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: Color(0xFFA77554),
            ),
          ),
        ],
      ),
    );
  }
}
