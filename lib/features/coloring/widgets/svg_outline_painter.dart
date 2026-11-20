
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

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SvgOutlinePainter oldDelegate) {
    return document != oldDelegate.document;
  }
}
