
import 'dart:ui';

import '../models/brush_stroke.dart';
import '../models/svg_coloring_document.dart';

class BrushEngine {
  static const double minPointDistance = 3.0;

  final SvgColoringDocument document;

  final List<BrushStroke> _strokes = [];
  BrushStroke? _activeStroke;
  Offset? _lastPoint;

  BrushEngine({required this.document});

  List<BrushStroke> get strokes =>
      List.unmodifiable(_strokes);

  BrushStroke? get activeStroke => _activeStroke;

  bool get isDrawing => _activeStroke != null;

  bool startStroke({
    required Offset point,
    required Color color,
    required double width,
  }) {
    if (_activeStroke != null || width <= 0) {
      return false;
    }

    final region = document.findRegionAt(point);

    if (region == null) {
      return false;
    }

    final path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(point.dx, point.dy);

    _activeStroke = BrushStroke(
      path: path,
      region: region,
      color: color,
      width: width,
    );

    _lastPoint = point;
    return true;
  }

  bool updateStroke(Offset point) {
    final stroke = _activeStroke;
    final lastPoint = _lastPoint;

    if (stroke == null || lastPoint == null) {
      return false;
    }

    if ((point - lastPoint).distance < minPointDistance) {
      return false;
    }

    stroke.path.lineTo(point.dx, point.dy);
    _lastPoint = point;

    return true;
  }

  BrushStroke? finishStroke() {
    final stroke = _activeStroke;

    if (stroke == null) {
      return null;
    }

    _strokes.add(stroke);
    _activeStroke = null;
    _lastPoint = null;

    return stroke;
  }

  void cancelStroke() {
    _activeStroke = null;
    _lastPoint = null;
  }

  bool removeStroke(BrushStroke stroke) {
    return _strokes.remove(stroke);
  }

  void clear() {
    _strokes.clear();
    cancelStroke();
  }
}
