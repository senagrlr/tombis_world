import 'package:flutter/material.dart';

import '../../../core/widgets/cozy_back_button.dart';
import '../data/coloring_palettes.dart';
import '../models/color_palette.dart';
import 'coloring_tools.dart';
import 'palette_selector.dart';
import 'color_swatches.dart';

class ColoringSidebar extends StatelessWidget {
  final ColorPalette palette;
  final String paletteId;
  final Color selectedColor;
  final ColoringTool selectedTool;
  final ValueChanged<ColoringTool> onToolSelected;
  final ValueChanged<String> onPaletteSelected;
  final ValueChanged<Color> onColorSelected;

  const ColoringSidebar({
    super.key,
    required this.palette,
    required this.paletteId,
    required this.selectedColor,
    required this.selectedTool,
    required this.onToolSelected,
    required this.onPaletteSelected,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: CozyBackButton(),
        ),
        const SizedBox(height: 12),
        ColoringTools(
          selected: selectedTool,
          onSelected: onToolSelected,
        ),
        const Spacer(),
        PaletteSelector(
          palettes: ColoringPalettes.all,
          selectedId: paletteId,
          onSelected: onPaletteSelected,
        ),
        const SizedBox(height: 5),
        Flexible(
          flex: 3,
          child: SingleChildScrollView(
            child: ColorSwatches(
              palette: palette,
              selectedColor: selectedColor,
              onSelected: onColorSelected,
            ),
          ),
        ),
      ],
    );
  }
}
