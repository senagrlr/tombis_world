
import 'dart:ui';

import '../models/svg_color_region.dart';
import '../models/svg_coloring_document.dart';
import 'coloring_history.dart';

class ColoringEngine {
  final SvgColoringDocument document;
  final ColoringHistory history;

  ColoringEngine({
    required this.document,
    ColoringHistory? history,
  }) : history = history ?? ColoringHistory();

  bool get canUndo => history.canUndo;
  int get undoCount => history.undoCount;


  bool fillRegion({
    required Offset point,
    required Color color,
    bool recordHistory = true,
  }) {
    final region = document.findRegionAt(point);

    if (region == null || region.color == color) {
      return false;
    }

    final previousColor = region.color;

    if (recordHistory) {
      history.record(() {
        region.color = previousColor;
      });
    }

    region.color = color;
    return true;
  }

  bool undo() => history.undo();

  SvgColorRegion? getRegionAt(Offset point) {
    return document.findRegionAt(point);
  }

  void resetColors() {
    for (final region in document.regions) {
      region.color = const Color(0xFFFFFFFF);
    }
  }
}
