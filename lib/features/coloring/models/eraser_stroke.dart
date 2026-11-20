import 'dart:ui';

import 'svg_color_region.dart';

class EraserStroke {
  final Path path;
  final double width;
  final SvgColorRegion region;

  EraserStroke({
    required this.path,
    required this.width,
    required this.region,
  });
}