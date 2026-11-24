import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/coloring_operation_timeline.dart';
import '../models/svg_coloring_document.dart';
import '../widgets/coloring_paint_painter.dart';
import '../widgets/svg_outline_painter.dart';
import 'package:flutter/foundation.dart';

class ColoringExportService {
  const ColoringExportService();

  Future<Uint8List> exportPng({
    required SvgColoringDocument document,
    required List<ColoringOperation> operations,
    double scale = 2.0,
  }) async {
    final stopwatch = Stopwatch()..start();
    if (scale <= 0 ||
        !scale.isFinite ||
        document.size.isEmpty) {
      throw ArgumentError('Invalid export dimensions.');
    }

    final width = (document.size.width * scale).ceil();
    final height = (document.size.height * scale).ceil();

    debugPrint(
      'PNG BOYUTU: ${width}x$height '
          '(${width * height} piksel)',
    );

    final exportSize = Size(
      width.toDouble(),
      height.toDouble(),
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      Offset.zero & exportSize,
      Paint()..color = Colors.white,
    );

    ColoringPaintPainter(
      document: document,
      operations: operations,
      activeBrush: null,
      activeEraser: null,
      revision: 0,
    ).paint(canvas, exportSize);

    SvgOutlinePainter(
      document: document,
    ).paint(canvas, exportSize);

    final picture = recorder.endRecording();
    debugPrint(
      'PNG Drawing: ${stopwatch.elapsedMilliseconds} ms',
    );

    try {
      final image = await picture.toImage(width, height);

      debugPrint(
        'PNG Rasterization: ${stopwatch.elapsedMilliseconds} ms',
      );

      try {
        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        debugPrint(
          'PNG Encoding: ${stopwatch.elapsedMilliseconds} ms',
        );

        if (byteData == null) {
          throw StateError('PNG export failed.');
        }

        return byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }
}
