import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:typed_data';

class CompletedArtwork extends StatelessWidget {
  final String imagePath;
  final Uint8List? paintedImage;

  const CompletedArtwork({
    super.key,
    required this.imagePath,
    this.paintedImage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.29,
        child: paintedImage != null
            ? Image.memory(
          paintedImage!,
          fit: BoxFit.contain,
        )
            : SvgPicture.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
