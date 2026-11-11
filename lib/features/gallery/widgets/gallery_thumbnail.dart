import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../models/coloring_page.dart';

class GalleryThumbnail extends StatelessWidget {
  final ColoringPage page;
  final VoidCallback onTap;

  const GalleryThumbnail({
    super.key,
    required this.page,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: AppColors.borderBlue,
            width: 1.5,
          ),
        ),
        child: SvgPicture.asset(
          page.imagePath,
          fit: BoxFit.contain,
          placeholderBuilder: (context) =>
          const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
