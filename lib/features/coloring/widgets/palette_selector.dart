import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/color_palette.dart';

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
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        itemCount: palettes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 5),
        itemBuilder: (context, index) {
          final palette = palettes[index];
          final selected = palette.id == selectedId;

          return Center(
            child: GestureDetector(
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
                  palette.name,
                  style: const TextStyle(
                    color: AppColors.darkBrown,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
