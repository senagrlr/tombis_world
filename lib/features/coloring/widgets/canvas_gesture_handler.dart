
import 'package:flutter/material.dart';

import '../engine/coloring_session.dart';
import '../models/coloring_tool.dart';

class CanvasGestureHandler extends StatefulWidget {
  final Widget child;
  final ColoringSession session;
  final ColoringTool selectedTool;
  final Color selectedColor;
  final double brushWidth;
  final double eraserWidth;
  final ValueChanged<Color> onColorPicked;
  final Size canvasSize;

  const CanvasGestureHandler({
    super.key,
    required this.child,
    required this.session,
    required this.selectedTool,
    required this.selectedColor,
    required this.brushWidth,
    required this.eraserWidth,
    required this.onColorPicked,
    required this.canvasSize,
  });

  @override
  State<CanvasGestureHandler> createState() =>
      _CanvasGestureHandlerState();
}

class _CanvasGestureHandlerState
    extends State<CanvasGestureHandler> {
  static const double _tapSlop = 12.0;

  final Map<int, Offset> _pointers = {};

  int? _drawingPointer;
  Offset? _tapStart;
  bool _multiTouchUsed = false;

  bool get _isBrush =>
      widget.selectedTool == ColoringTool.brush;

  bool get _isEraser =>
      widget.selectedTool == ColoringTool.eraser;

  bool get _isDrawingTool => _isBrush || _isEraser;

  Offset _toSvgPoint(Offset position) {
    final document = widget.session.document!;

    return Offset(
      position.dx *
          document.size.width /
          widget.canvasSize.width,
      position.dy *
          document.size.height /
          widget.canvasSize.height,
    );
  }

  void _cancelDrawing() {
    if (_drawingPointer == null) return;

    widget.session.cancelStroke();
    widget.session.cancelEraser();

    _drawingPointer = null;
  }

  Future<void> _handleTap(Offset position) async {
    if (widget.session.document == null) return;

    final point = _toSvgPoint(position);

    switch (widget.selectedTool) {
      case ColoringTool.fill:
        widget.session.fill(
          point,
          widget.selectedColor,
        );
        break;

      case ColoringTool.picker:
        final session = widget.session;

        final color = await session.pickColor(point);

        if (!mounted ||
            widget.session != session ||
            widget.selectedTool != ColoringTool.picker) {
          return;
        }

        if (color != null) {
          widget.onColorPicked(color);
        }
        break;

      case ColoringTool.brush:
      case ColoringTool.eraser:
        break;
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.localPosition;

    if (_pointers.length == 1) {
      _multiTouchUsed = false;
      _tapStart = event.localPosition;

      if (_isDrawingTool &&
          widget.session.document != null) {
        final point = _toSvgPoint(
          event.localPosition,
        );

        bool started = false;

        if (_isBrush) {
          started = widget.session.startStroke(
            point: point,
            color: widget.selectedColor,
            width: widget.brushWidth,
          );
        } else if (_isEraser) {
          started = widget.session.startEraser(
            point: point,
            width: widget.eraserWidth,
          );
        }

        if (started) {
          _drawingPointer = event.pointer;
        }
      }
    } else {
      _multiTouchUsed = true;
      _tapStart = null;
      _cancelDrawing();
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) {
      return;
    }

    _pointers[event.pointer] = event.localPosition;

    if (_pointers.length != 1 ||
        _drawingPointer != event.pointer ||
        widget.session.document == null) {
      return;
    }

    final point = _toSvgPoint(
      event.localPosition,
    );

    if (_isBrush) {
      widget.session.updateStroke(point);
    } else if (_isEraser) {
      widget.session.updateEraser(point);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    final position = _pointers[event.pointer];

    if (_drawingPointer == event.pointer) {
      if (_isBrush) {
        widget.session.finishStroke();
      } else if (_isEraser) {
        widget.session.finishEraser();
      }

      _drawingPointer = null;
    } else if (!_multiTouchUsed &&
        _pointers.length == 1 &&
        _tapStart != null &&
        position != null &&
        (position - _tapStart!).distance <= _tapSlop) {
      _handleTap(position);
    }

    _pointers.remove(event.pointer);

    if (_pointers.isEmpty) {
      _tapStart = null;
      _multiTouchUsed = false;
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_drawingPointer == event.pointer) {
      _cancelDrawing();
    }

    _pointers.remove(event.pointer);

    if (_pointers.isEmpty) {
      _tapStart = null;
      _multiTouchUsed = false;
    }
  }

  @override
  void didUpdateWidget(
      covariant CanvasGestureHandler oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedTool != widget.selectedTool ||
        oldWidget.canvasSize != widget.canvasSize ||
        oldWidget.session != widget.session) {
      _cancelDrawing();
      _pointers.clear();
      _tapStart = null;
      _multiTouchUsed = false;
    }
  }

  @override
  void dispose() {
    _cancelDrawing();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: widget.child,
    );
  }
}
