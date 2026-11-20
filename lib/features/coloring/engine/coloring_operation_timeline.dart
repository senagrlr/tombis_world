
import 'dart:ui';

import '../models/brush_stroke.dart';
import '../models/eraser_stroke.dart';

enum ColoringOperationType {
  fill,
  brush,
  eraser,
}

class ColoringOperation {
  final int order;
  final ColoringOperationType type;
  final String? regionId;
  final Color? color;
  final BrushStroke? brushStroke;
  final EraserStroke? eraserStroke;

  const ColoringOperation({
    required this.order,
    required this.type,
    this.regionId,
    this.color,
    this.brushStroke,
    this.eraserStroke,
  });
}

class ColoringOperationTimeline {
  final List<ColoringOperation> _operations = [];
  int _nextOrder = 0;

  List<ColoringOperation> get operations =>
      List.unmodifiable(_operations);

  int add({
    required ColoringOperationType type,
    String? regionId,
    Color? color,
    BrushStroke? brushStroke,
    EraserStroke? eraserStroke,
  }) {
    final order = ++_nextOrder;

    _operations.add(
      ColoringOperation(
        order: order,
        type: type,
        regionId: regionId,
        color: color,
        brushStroke: brushStroke,
        eraserStroke: eraserStroke,
      ),
    );

    return order;
  }

  bool remove(int order) {
    final index = _operations.indexWhere(
          (operation) => operation.order == order,
    );

    if (index == -1) return false;

    _operations.removeAt(index);
    return true;
  }

  void clear() {
    _operations.clear();
    _nextOrder = 0;
  }
}
