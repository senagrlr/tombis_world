
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/coloring_operation_timeline.dart';
import '../models/brush_stroke.dart';
import '../models/eraser_stroke.dart';
import '../models/svg_coloring_document.dart';

class ColoringPaintPainter extends CustomPainter {
  final SvgColoringDocument document;
  final List<ColoringOperation> operations;
  final BrushStroke? activeBrush;
  final EraserStroke? activeEraser;
  final int revision;

  ColoringPaintPainter({
    required this.document,
    required this.operations,
    required this.activeBrush,
    required this.activeEraser,
    required this.revision,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty ||
        document.size.width <= 0 ||
        document.size.height <= 0) {
      return;
    }

    final bounds = Offset.zero & size;

    canvas.saveLayer(bounds, Paint());

    canvas.save();
    canvas.scale(
      size.width / document.size.width,
      size.height / document.size.height,
    );

    final regions = {
      for (final region in document.regions)
        region.id: region.path,
    };

    for (final operation in operations) {
      switch (operation.type) {
        case ColoringOperationType.fill:
          final path = regions[operation.regionId];
          final color = operation.color;

          if (path == null || color == null) break;

          canvas.drawPath(
            path,
            Paint()
              ..color = color
              ..style = PaintingStyle.fill
              ..isAntiAlias = true,
          );

        case ColoringOperationType.brush:
          final stroke = operation.brushStroke;
          if (stroke != null) {
            _drawBrush(canvas, stroke);
          }

        case ColoringOperationType.eraser:
          final stroke = operation.eraserStroke;
          if (stroke != null) {
            _drawEraser(canvas, stroke);
          }
      }
    }

    if (activeBrush != null) {
      _drawBrush(canvas, activeBrush!);
    }

    if (activeEraser != null) {
      _drawEraser(canvas, activeEraser!);
    }

    canvas.restore();
    canvas.restore();
  }

  void _drawBrush(Canvas canvas, BrushStroke stroke) {
    canvas.save();
    canvas.clipPath(stroke.region.path);

    canvas.drawPath(
      stroke.path,
      Paint()
        ..color = stroke.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );

    canvas.restore();
  }

  void _drawEraser(Canvas canvas, EraserStroke stroke) {
    canvas.save();

    canvas.clipPath(stroke.region.path);

    canvas.drawPath(
      stroke.path,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..blendMode = ui.BlendMode.dstOut
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(
      covariant ColoringPaintPainter oldDelegate,
      ) {
    return document != oldDelegate.document ||
        revision != oldDelegate.revision;
  }
}
