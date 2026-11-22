
import 'package:flutter/material.dart';

import '../models/svg_coloring_document.dart';

class SvgOutlinePainter extends CustomPainter {
  final SvgColoringDocument document;

  SvgOutlinePainter({
    required this.document,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / document.size.width;
    final scaleY = size.height / document.size.height;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(document.outline, paint);

    for (var i = 0; i < document.strokePaths.length; i++) {
      final strokePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = document.strokeWidths[i]
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;

      canvas.drawPath(document.strokePaths[i], strokePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SvgOutlinePainter oldDelegate) {
    return document != oldDelegate.document;
  }
}
