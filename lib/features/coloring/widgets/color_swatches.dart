import 'package:flutter/material.dart';
import '../models/color_palette.dart';

class ColorSwatches extends StatelessWidget {
  final ColorPalette palette;
  final Color selectedColor;
  final ValueChanged<Color> onSelected;

  const ColorSwatches({
    super.key,
    required this.palette,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E9E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: palette.colors.length,
        itemBuilder: (context, index) {
          final color = palette.colors[index];

          return GestureDetector(
            onTap: () => onSelected(color),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color == selectedColor
                      ? Colors.brown
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
