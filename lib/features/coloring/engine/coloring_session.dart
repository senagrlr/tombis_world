
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../controller/coloring_repaint_controller.dart';
import '../data/svg_coloring_parser.dart';
import '../models/brush_stroke.dart';
import '../models/eraser_stroke.dart';
import '../models/svg_coloring_document.dart';
import 'brush_engine.dart';
import 'coloring_engine.dart';
import 'coloring_history.dart';
import 'coloring_operation_timeline.dart';
import 'eraser_engine.dart';
import '../services/color_picker_service.dart';

class ColoringSession extends ChangeNotifier {
  SvgColoringDocument? _document;
  ColoringEngine? _engine;
  BrushEngine? _brushEngine;
  EraserEngine? _eraserEngine;
  ColoringHistory? _history;

  final ColoringOperationTimeline _timeline = ColoringOperationTimeline();
  final ColoringRepaintController repaint = ColoringRepaintController();
  final ColorPickerService _colorPickerService = const ColorPickerService();

  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  int _loadVersion = 0;

  SvgColoringDocument? get document => _document;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get canUndo => _history?.canUndo ?? false;

  List<ColoringOperation> get operations =>
      _timeline.operations;

  BrushStroke? get activeStroke =>
      _brushEngine?.activeStroke;

  EraserStroke? get activeEraser =>
      _eraserEngine?.activeStroke;

  Future<void> load(String imagePath) async {
    final version = ++_loadVersion;

    _document = null;
    _engine = null;
    _brushEngine = null;
    _eraserEngine = null;
    _history = null;
    _error = null;
    _isLoading = true;

    _timeline.clear();
    _notify();

    try {
      final document =
      await const SvgColoringParser().parseAsset(imagePath);

      if (_disposed || version != _loadVersion) return;

      final history = ColoringHistory();

      _document = document;
      _history = history;

      _engine = ColoringEngine(
        document: document,
        history: history,
      );

      _brushEngine = BrushEngine(document: document);
      _eraserEngine = EraserEngine(document: document);

      repaint.allChanged();
    } catch (error) {
      if (_disposed || version != _loadVersion) return;
      _error = error.toString();
    } finally {
      if (!_disposed && version == _loadVersion) {
        _isLoading = false;
        _notify();
      }
    }
  }

  bool fill(Offset point, Color color) {
    final engine = _engine;
    final history = _history;

    if (engine == null || history == null) {
      return false;
    }

    final region = engine.getRegionAt(point);
    if (region == null) return false;

    final operations = _timeline.operations;

    if (operations.isNotEmpty) {
      final lastOperation = operations.last;

      if (lastOperation.type == ColoringOperationType.fill &&
          lastOperation.regionId == region.id &&
          lastOperation.color == color) {
        return false;
      }
    }

    final previousColor = region.color;

    final changed = engine.fillRegion(
      point: point,
      color: color,
      recordHistory: false,
    );

    final order = _timeline.add(
      type: ColoringOperationType.fill,
      regionId: region.id,
      color: color,
    );

    history.record(() {
      if (changed) {
        region.color = previousColor;
      }

      _timeline.remove(order);
    });

    repaint.allChanged();
    _notify();
    return true;
  }

  Future<Color?> pickColor(Offset point) async {
    final document = _document;

    if (document == null || _disposed) {
      return null;
    }

    final color = await _colorPickerService.pickColor(
      document: document,
      operations: _timeline.operations,
      point: point,
    );

    if (_disposed) return null;

    return color;
  }

  bool startStroke({
    required Offset point,
    required Color color,
    required double width,
  }) {
    final started = _brushEngine?.startStroke(
      point: point,
      color: color,
      width: width,
    ) ??
        false;

    if (!started) return false;

    repaint.strokesChanged();
    return true;
  }

  bool updateStroke(Offset point) {
    final changed =
        _brushEngine?.updateStroke(point) ?? false;

    if (changed) {
      repaint.strokesChanged();
    }

    return changed;
  }

  bool finishStroke() {
    final brushEngine = _brushEngine;
    if (brushEngine == null) return false;

    final stroke = brushEngine.finishStroke();
    if (stroke == null) return false;

    final order = _timeline.add(
      type: ColoringOperationType.brush,
      regionId: stroke.region.id,
      brushStroke: stroke,
    );

    stroke.order = order;

    _history?.record(() {
      brushEngine.removeStroke(stroke);
      _timeline.remove(order);
    });

    repaint.strokesChanged();
    _notify();
    return true;
  }

  void cancelStroke() {
    final brushEngine = _brushEngine;

    if (brushEngine == null || !brushEngine.isDrawing) {
      return;
    }

    brushEngine.cancelStroke();
    repaint.strokesChanged();
  }

  bool startEraser({
    required Offset point,
    required double width,
  }) {
    final eraserEngine = _eraserEngine;
    if (eraserEngine == null) return false;

    final started = eraserEngine.startStroke(
      point: point,
      width: width,
    );

    if (!started) return false;

    repaint.strokesChanged();
    return true;
  }

  bool updateEraser(Offset point) {
    final changed =
        _eraserEngine?.updateStroke(point) ?? false;

    if (changed) {
      repaint.strokesChanged();
    }

    return changed;
  }

  bool finishEraser() {
    final eraserEngine = _eraserEngine;
    if (eraserEngine == null) return false;

    final stroke = eraserEngine.finishStroke();
    if (stroke == null) return false;

    final order = _timeline.add(
      type: ColoringOperationType.eraser,
      eraserStroke: stroke,
    );

    _history?.record(() {
      eraserEngine.removeStroke(stroke);
      _timeline.remove(order);
    });

    repaint.strokesChanged();
    _notify();
    return true;
  }

  void cancelEraser() {
    final eraserEngine = _eraserEngine;

    if (eraserEngine == null || !eraserEngine.isErasing) {
      return;
    }

    eraserEngine.cancelStroke();
    repaint.strokesChanged();
  }

  bool undo() {
    final changed = _history?.undo() ?? false;

    if (changed) {
      repaint.allChanged();
      _notify();
    }

    return changed;
  }

  void clear() {
    if (_engine == null) return;

    _brushEngine?.clear();
    _eraserEngine?.clear();
    _engine!.resetColors();
    _history?.clear();
    _timeline.clear();

    repaint.allChanged();
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _loadVersion++;

    repaint.dispose();
    super.dispose();
  }
}
