
import 'dart:ui';

class SvgColorRegion {
  final String id;
  final Path path;
  Color color;

  SvgColorRegion({
    required this.id,
    required this.path,
    this.color = const Color(0xFFFFFFFF),
  });
}
