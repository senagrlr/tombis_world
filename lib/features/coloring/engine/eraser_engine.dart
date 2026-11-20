
import 'dart:ui';

import '../models/eraser_stroke.dart';
import '../models/svg_coloring_document.dart';

class EraserEngine {
  static const double minPointDistance = 3.0;

  final SvgColoringDocument document;

  final List<EraserStroke> _strokes = [];

  EraserStroke? _activeStroke;
  Offset? _lastPoint;

  EraserEngine({
    required this.document,
  });

  List<EraserStroke> get strokes =>
      List.unmodifiable(_strokes);

  EraserStroke? get activeStroke => _activeStroke;

  bool get isErasing => _activeStroke != null;

  bool startStroke({
    required Offset point,
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

    _activeStroke = EraserStroke(
      path: path,
      width: width,
      region: region,
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

  EraserStroke? finishStroke() {
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

  bool removeStroke(EraserStroke stroke) {
    return _strokes.remove(stroke);
  }

  void clear() {
    _strokes.clear();
    cancelStroke();
  }
}
