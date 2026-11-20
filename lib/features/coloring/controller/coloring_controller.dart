
import 'package:flutter/material.dart';

import '../data/coloring_palettes.dart';
import '../models/coloring_tool.dart';

class ColoringController extends ChangeNotifier {
  String _paletteId = ColoringPalettes.all.first.id;
  Color _selectedColor = ColoringPalettes.all.first.colors.first;
  ColoringTool _selectedTool = ColoringTool.brush;

  double _brushWidth = 48.0;
  double _eraserWidth = 80.0;

  String get paletteId => _paletteId;
  Color get selectedColor => _selectedColor;
  ColoringTool get selectedTool => _selectedTool;

  double get brushWidth => _brushWidth;
  double get eraserWidth => _eraserWidth;

  void selectTool(ColoringTool tool) {
    if (_selectedTool == tool) return;

    _selectedTool = tool;
    notifyListeners();
  }

  void selectPalette(String id) {
    final palette = ColoringPalettes.all.firstWhere(
          (item) => item.id == id,
    );

    _paletteId = id;
    _selectedColor = palette.colors.first;

    notifyListeners();
  }

  void selectColor(Color color) {
    if (_selectedColor == color) return;

    _selectedColor = color;
    notifyListeners();
  }

  void selectPickedColor(Color color) {
    final currentPalette = ColoringPalettes.all.firstWhere(
          (item) => item.id == _paletteId,
    );

    if (currentPalette.colors.contains(color)) {
      selectColor(color);
      return;
    }

    for (final palette in ColoringPalettes.all) {
      if (palette.colors.contains(color)) {
        _paletteId = palette.id;
        break;
      }
    }

    if (_selectedColor == color &&
        _paletteId == currentPalette.id) {
      return;
    }

    _selectedColor = color;
    notifyListeners();
  }

  void setBrushWidth(double width) {
    final newWidth = width.clamp(8.0, 96.0);

    if (_brushWidth == newWidth) return;

    _brushWidth = newWidth;
    notifyListeners();
  }

  void setEraserWidth(double width) {
    final newWidth = width.clamp(8.0, 120.0);

    if (_eraserWidth == newWidth) return;

    _eraserWidth = newWidth;
    notifyListeners();
  }
}
