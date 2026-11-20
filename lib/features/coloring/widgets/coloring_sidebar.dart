import 'package:flutter/material.dart';

import '../../../core/widgets/cozy_back_button.dart';
import '../data/coloring_palettes.dart';
import '../models/color_palette.dart';
import 'coloring_tools.dart';
import 'palette_selector.dart';
import 'color_swatches.dart';
import '../models/coloring_tool.dart';
import 'brush_size_slider.dart';

class ColoringSidebar extends StatefulWidget {
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
  State<ColoringSidebar> createState() => _ColoringSidebarState();
}

class _ColoringSidebarState extends State<ColoringSidebar> {
  bool _isSizeSliderOpen = false;

  void _handleToolSelected(ColoringTool tool) {
    setState(() {
      if (tool == widget.selectedTool &&
          (tool == ColoringTool.brush ||
              tool == ColoringTool.eraser)) {
        _isSizeSliderOpen = !_isSizeSliderOpen;
      } else {
        _isSizeSliderOpen = false;
      }
    });

    widget.onToolSelected(tool);
  }

  void _closeSizeSlider() {
    if (!_isSizeSliderOpen) return;

    setState(() {
      _isSizeSliderOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: CozyBackButton(),
        ),
        const SizedBox(height: 12),
        TapRegion(
          onTapOutside: (_) => _closeSizeSlider(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColoringTools(
                selected: widget.selectedTool,
                onSelected: _handleToolSelected,
              ),

              if (_isSizeSliderOpen &&
                  (widget.selectedTool == ColoringTool.brush ||
                      widget.selectedTool == ColoringTool.eraser)) ...[
                const SizedBox(height: 10),

                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.82,
                    child: BrushSizeSlider(
                      value: widget.selectedTool == ColoringTool.brush
                          ? widget.brushWidth
                          : widget.eraserWidth,
                      min: 8,
                      max: widget.selectedTool == ColoringTool.brush
                          ? 96
                          : 120,
                      previewColor: widget.selectedTool == ColoringTool.brush
                          ? widget.selectedColor
                          : Colors.white,
                      onChanged: widget.selectedTool == ColoringTool.brush
                          ? widget.onBrushWidthChanged
                          : widget.onEraserWidthChanged,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const Spacer(),
        PaletteSelector(
          palettes: ColoringPalettes.all,
          selectedId: widget.paletteId,
          onSelected: widget.onPaletteSelected,
        ),
        const SizedBox(height: 5),
        Flexible(
          flex: 3,
          child: SingleChildScrollView(
            child: ColorSwatches(
              palette: widget.palette,
              selectedColor: widget.selectedColor,
              onSelected: widget.onColorSelected,
            ),
          ),
        ),
      ],
    );
  }
}
