import 'package:flutter/material.dart';

import '../data/coloring_palettes.dart';
import '../models/color_palette.dart';
import '../models/coloring_tool.dart';
import 'coloring_tools.dart';
import 'palette_selector.dart';
import 'color_swatches.dart';
import 'brush_size_slider.dart';

class ColoringSidebar extends StatelessWidget {
  final ColorPalette palette;
  final String paletteId;
  final Color selectedColor;
  final ColoringTool selectedTool;
  final ValueChanged<ColoringTool> onToolSelected;
  final ValueChanged<String> onPaletteSelected;
  final ValueChanged<Color> onColorSelected;
  final double brushWidth;
  final double eraserWidth;
  final ValueChanged<double> onBrushWidthChanged;
  final ValueChanged<double> onEraserWidthChanged;

  const ColoringSidebar({
    super.key,
    required this.palette,
    required this.paletteId,
    required this.selectedColor,
    required this.selectedTool,
    required this.onToolSelected,
    required this.onPaletteSelected,
    required this.onColorSelected,
    required this.brushWidth,
    required this.eraserWidth,
    required this.onBrushWidthChanged,
    required this.onEraserWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final showSlider =
        selectedTool == ColoringTool.brush ||
            selectedTool == ColoringTool.eraser;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: ColoringTools(
            selected: selectedTool,
            onSelected: onToolSelected,
          ),
        ),

        if (showSlider) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
            ),
            child: BrushSizeSlider(
              value: selectedTool == ColoringTool.brush
                  ? brushWidth
                  : eraserWidth,
              min: 8,
              max: selectedTool == ColoringTool.brush
                  ? 96
                  : 120,
              previewColor:
              selectedTool == ColoringTool.brush
                  ? selectedColor
                  : Colors.white,
              onChanged:
              selectedTool == ColoringTool.brush
                  ? onBrushWidthChanged
                  : onEraserWidthChanged,
            ),
          ),
        ],

        const SizedBox(height: 4),

        PaletteSelector(
          palettes: ColoringPalettes.all,
          selectedId: paletteId,
          onSelected: onPaletteSelected,
        ),

        const SizedBox(height: 3),

        ColorSwatches(
          palette: palette,
          selectedColor: selectedColor,
          onSelected: onColorSelected,
        ),
      ],
    );
  }
}
