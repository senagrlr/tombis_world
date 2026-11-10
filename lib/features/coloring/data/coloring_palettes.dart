
import 'package:flutter/material.dart';
import '../models/color_palette.dart';

abstract final class ColoringPalettes {
  static const all = <ColorPalette>[
    ColorPalette(
      id: 'pastel',
      name: 'Pastel',
      colors: [
        Color(0xFFFFE632), Color(0xFFFF5038),
        Color(0xFFF578A4), Color(0xFF00B6EF),
        Color(0xFFA2AF71), Colors.white,
        Color(0xFFFFBD47), Color(0xFFFF3838),
        Color(0xFFD14670), Color(0xFF0098D5),
        Color(0xFF3CA582), Color(0xFFE17A3E),
        Color(0xFFFF9365), Color(0xFFF05E78),
        Color(0xFFAE5D80), Color(0xFF1C609C),
        Color(0xFF5D8176), Color(0xFF4B4E52),
      ],
    ),
    ColorPalette(
      id: 'nature',
      name: 'Nature',
      colors: [
        Color(0xFF9DB56C), Color(0xFF6D944E),
        Color(0xFF3D7658), Color(0xFFB8D4A4),
        Color(0xFFE2C28B), Color(0xFF9D6D4D),
      ],
    ),
    ColorPalette(
      id: 'tombi',
      name: 'Tombi',
      colors: [
        Color(0xFFFFD9A8), Color(0xFFD99C75),
        Color(0xFF8C624E), Color(0xFFB9CB85),
        Color(0xFFD4E5F7), Color(0xFFFFF3E2),
      ],
    ),
    ColorPalette(
      id: 'candy',
      name: 'Candy',
      colors: [
        Color(0xFFFF82AF), Color(0xFFB58DE6),
        Color(0xFFFFCF71), Color(0xFF88DAD2),
      ],
    ),
    ColorPalette(
      id: 'dreamy',
      name: 'Dreamy',
      colors: [
        Color(0xFFC5B6F0), Color(0xFF99C9F5),
        Color(0xFFF4B7D5), Color(0xFFB3D6C0),
      ],
    ),
  ];
}
