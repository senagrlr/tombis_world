
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/coloring_operation_timeline.dart';
import '../models/svg_coloring_document.dart';
import '../widgets/coloring_paint_painter.dart';

class ColorPickerService {
  const ColorPickerService();

  Future<Color?> pickColor({
    required SvgColoringDocument document,
    required List<ColoringOperation> operations,
    required Offset point,
  }) async {
    if (point.dx < 0 ||
        point.dy < 0 ||
        point.dx >= document.size.width ||
        point.dy >= document.size.height) {
      return null;
    }

    const sampleSize = 3;
    const center = 1;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawColor(
      Colors.white,
      ui.BlendMode.src,
    );

    canvas.translate(
      center - point.dx,
      center - point.dy,
    );

    ColoringPaintPainter(
      document: document,
      operations: operations,
      activeBrush: null,
      activeEraser: null,
      revision: 0,
    ).paint(canvas, document.size);

    final picture = recorder.endRecording();

    try {
      final image = await picture.toImage(
        sampleSize,
        sampleSize,
      );

      try {
        final data = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );

        if (data == null) return null;

        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        final index = (center * sampleSize + center) * 4;

        final red = bytes[index];
        final green = bytes[index + 1];
        final blue = bytes[index + 2];
        final alpha = bytes[index + 3];

        final opacity = alpha / 255.0;

        return Color.fromARGB(
          255,
          (red * opacity + 255 * (1 - opacity)).round(),
          (green * opacity + 255 * (1 - opacity)).round(),
          (blue * opacity + 255 * (1 - opacity)).round(),
        );
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }
}
