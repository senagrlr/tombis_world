
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ColoringCanvas extends StatelessWidget {
  final String imagePath;

  const ColoringCanvas({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(5),
      child: SvgPicture.asset(
        imagePath,
        fit: BoxFit.contain,
        placeholderBuilder: (context) =>
        const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
