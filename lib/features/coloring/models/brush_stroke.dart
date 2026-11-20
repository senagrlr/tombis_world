
import 'dart:ui';

import 'svg_color_region.dart';

class BrushStroke {
  final Path path;
  final SvgColorRegion region;
  final Color color;
  final double width;
  int order;

  BrushStroke({
    required this.path,
    required this.region,
    required this.color,
    required this.width,
    this.order = 0,
  });
}
