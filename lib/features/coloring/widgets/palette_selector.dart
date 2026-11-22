import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/color_palette.dart';
import '../../../l10n/app_localizations.dart';

class PaletteSelector extends StatelessWidget {
  final List<ColorPalette> palettes;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const PaletteSelector({
    super.key,
    required this.palettes,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 34,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.sizeOf(context).width - 48,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int index = 0; index < palettes.length; index++) ...[
                if (index > 0)
                  const SizedBox(width: 5),

                _buildPaletteButton(
                  palette: palettes[index],
                  selected: palettes[index].id == selectedId,
                  label: switch (palettes[index].id) {
                    'pastel' => l10n.palettePastel,
                    'nature' => l10n.paletteNature,
                    'tombi' => l10n.paletteTombi,
                    'candy' => l10n.paletteCandy,
                    'dreamy' => l10n.paletteDreamy,
                    _ => palettes[index].name,
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaletteButton({
    required ColorPalette palette,
    required bool selected,
    required String label,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelected(palette.id),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.cream : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.brown
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.darkBrown,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
