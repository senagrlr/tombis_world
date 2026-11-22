import 'package:flutter/material.dart';
import '../models/color_palette.dart';

abstract final class ColoringPalettes {
  static const all = <ColorPalette>[
    ColorPalette(
      id: 'pastel',
      name: 'Pastel',
      colors: [
        Color(0xFFFFE632),
        Color(0xFFFF5038),
        Color(0xFFF578A4),
        Color(0xFF00B6EF),
        Color(0xFFA2AF71),
        Colors.white,
        Color(0xFFFFBD47),
        Color(0xFFFF3838),
        Color(0xFFD14670),
        Color(0xFF0098D5),
        Color(0xFF3CA582),
        Color(0xFFE17A3E),
      ],
    ),

    ColorPalette(
      id: 'nature',
      name: 'Nature',
      colors: [
        Color(0xFF9DB56C),
        Color(0xFF6D944E),
        Color(0xFF3D7658),
        Color(0xFFB8D4A4),
        Color(0xFFE2C28B),
        Color(0xFF9D6D4D),
        Color(0xFFDDE8BA),
        Color(0xFF7EAD91),
        Color(0xFF547B62),
        Color(0xFFF0D9A5),
        Color(0xFFB77F57),
        Color(0xFF6B5344),
      ],
    ),

    ColorPalette(
      id: 'tombi',
      name: 'Tombi',
      colors: [
        Color(0xFFFFD9A8),
        Color(0xFFD99C75),
        Color(0xFF8C624E),
        Color(0xFFB9CB85),
        Color(0xFFD4E5F7),
        Color(0xFFFFF3E2),
        Color(0xFFF5B7C8),
        Color(0xFF9BC8B8),
        Color(0xFFF5D67E),
        Color(0xFFBBA5D5),
        Color(0xFF83B5DE),
        Color(0xFFE6A77E),
      ],
    ),

    ColorPalette(
      id: 'candy',
      name: 'Candy',
      colors: [
        Color(0xFFFF82AF),
        Color(0xFFB58DE6),
        Color(0xFFFFCF71),
        Color(0xFF88DAD2),
        Color(0xFFFFA1C5),
        Color(0xFFDE9FF2),
        Color(0xFFFFB88C),
        Color(0xFF7BCBEF),
        Color(0xFFFFE18D),
        Color(0xFFA9E4B2),
        Color(0xFFF18FB4),
        Color(0xFFC5A4F5),
      ],
    ),

    ColorPalette(
      id: 'dreamy',
      name: 'Dreamy',
      colors: [
        Color(0xFFC5B6F0),
        Color(0xFF99C9F5),
        Color(0xFFF4B7D5),
        Color(0xFFB3D6C0),
        Color(0xFFE8D2FA),
        Color(0xFFB8E1F2),
        Color(0xFFFFD8E5),
        Color(0xFFD3E8C8),
        Color(0xFFF9E3B5),
        Color(0xFFAFA9DF),
        Color(0xFF8EC6C3),
        Color(0xFFF2C5B2),
      ],
    ),
  ];
}
