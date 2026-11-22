
import 'dart:ui';

import 'svg_color_region.dart';

class SvgColoringDocument {
  final Size size;
  final List<SvgColorRegion> regions;
  final Path outline;
  final List<Path> strokePaths;
  final List<double> strokeWidths;

  SvgColoringDocument({
    required this.size,
    required this.regions,
    required this.outline,
    this.strokePaths = const [],
    this.strokeWidths = const [],
  });

  SvgColorRegion? findRegionAt(Offset point) {
    for (final region in regions.reversed) {
      if (region.path.contains(point)) {
        return region;
      }
    }

    return null;
  }
}
