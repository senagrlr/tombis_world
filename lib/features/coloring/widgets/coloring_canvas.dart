import 'package:flutter/material.dart';

import 'dart:typed_data';

import '../controller/canvas_transform_controller.dart';
import '../engine/coloring_session.dart';
import 'canvas_gesture_handler.dart';
import 'coloring_paint_painter.dart';
import 'svg_outline_painter.dart';
import 'svg_load_error.dart';
import '../services/coloring_export_service.dart';
import '../models/coloring_tool.dart';

class ColoringCanvas extends StatefulWidget {
  final String imagePath;
  final Color selectedColor;
  final ColoringTool selectedTool;
  final double brushWidth;
  final double eraserWidth;
  final ValueChanged<Color> onColorPicked;

  const ColoringCanvas({
    super.key,
    required this.imagePath,
    required this.selectedColor,
    required this.selectedTool,
    required this.brushWidth,
    required this.eraserWidth,
    required this.onColorPicked,
  });

  @override
  State<ColoringCanvas> createState() =>
      ColoringCanvasState();
}

class ColoringCanvasState extends State<ColoringCanvas> {
  final ColoringSession _session = ColoringSession();

  final CanvasTransformController _transform =
  CanvasTransformController();

  Matrix4? _lastAllowedTransform;

  @override
  void initState() {
    super.initState();
    _session.load(widget.imagePath);
  }

  @override
  void didUpdateWidget(covariant ColoringCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imagePath != widget.imagePath) {
      _lastAllowedTransform = null;
      _transform.reset();
      _session.load(widget.imagePath);
    }
  }

  @override
  void dispose() {
    _session.dispose();
    _transform.dispose();
    super.dispose();
  }

  bool get hasUnsavedChanges =>
      _session.operations.isNotEmpty ||
          _session.activeStroke != null ||
          _session.activeEraser != null;

  bool undo() => _session.undo();

  Future<Uint8List?> exportPng() async {
    final document = _session.document;

    if (document == null || _session.isLoading) {
      return null;
    }

    final exportService = ColoringExportService();

    return exportService.exportPng(
      document: document,
      operations: _session.operations,
      scale: 3072 / document.size.longestSide,
    );
  }

  void resetColoring() {
    _session.clear();
    _transform.reset();
    _lastAllowedTransform = null;
  }

  void _retryLoading() {
    if (_session.isLoading) return;

    _lastAllowedTransform = null;
    _transform.reset();
    _session.load(widget.imagePath);
  }

  void _onInteractionStart(ScaleStartDetails details) {
    _lastAllowedTransform = Matrix4.copy(
      _transform.transformationController.value,
    );
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    final controller =
        _transform.transformationController;

    final isDrawingTool =
        widget.selectedTool == ColoringTool.brush ||
            widget.selectedTool == ColoringTool.eraser;

    if (isDrawingTool && details.pointerCount < 2) {
      final previous = _lastAllowedTransform;

      if (previous != null) {
        controller.value = Matrix4.copy(previous);
      }

      return;
    }

    _lastAllowedTransform =
        Matrix4.copy(controller.value);
  }

  Widget _buildPaintLayer() {
    final document = _session.document!;

    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _session.repaint.strokes,
          builder: (context, _) {
            return CustomPaint(
              painter: ColoringPaintPainter(
                document: document,
                operations: _session.operations,
                activeBrush: _session.activeStroke,
                activeEraser: _session.activeEraser,
                revision: _session.repaint.strokeRevision,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOutlineLayer() {
    final document = _session.document!;

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: SvgOutlinePainter(
            document: document,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  Widget _buildCanvas(Size canvasSize) {
    return CanvasGestureHandler(
      session: _session,
      selectedTool: widget.selectedTool,
      selectedColor: widget.selectedColor,
      brushWidth: widget.brushWidth,
      eraserWidth: widget.eraserWidth,
      onColorPicked: widget.onColorPicked,
      canvasSize: canvasSize,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildPaintLayer(),
          _buildOutlineLayer(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_session.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_session.error != null) {
      return SvgLoadError(
        onRetry: _retryLoading,
      );
    }

    if (_session.document == null) {
      return SvgLoadError(
        onRetry: _retryLoading,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        return InteractiveViewer(
          transformationController:
          _transform.transformationController,
          minScale: 1.0,
          maxScale: 5.0,
          scaleEnabled: true,
          panEnabled: true,
          onInteractionStart: _onInteractionStart,
          onInteractionUpdate: _onInteractionUpdate,
          boundaryMargin: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: canvasSize.width,
            height: canvasSize.height,
            child: _buildCanvas(canvasSize),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(5),
      child: AnimatedBuilder(
        animation: _session,
        builder: (context, _) => _buildContent(),
      ),
    );
  }
}
