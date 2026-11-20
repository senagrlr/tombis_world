
import 'dart:ui';

import 'svg_color_region.dart';

class SvgColoringDocument {
  final Size size;
  final List<SvgColorRegion> regions;
  final Path outline;

  SvgColoringDocument({
    required this.size,
    required this.regions,
    required this.outline,
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
