import 'package:flutter/material.dart';
import '../models/coloring_page.dart';
import 'gallery_thumbnail.dart';

class GalleryGrid extends StatelessWidget {
  final List<ColoringPage> pages;
  final ValueChanged<ColoringPage> onPageSelected;

  const GalleryGrid({
    super.key,
    required this.pages,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 35),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 22,
        mainAxisSpacing: 24,
        childAspectRatio: 0.90,
      ),
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final page = pages[index];

        return GalleryThumbnail(
          page: page,
          onTap: () => onPageSelected(page),
        );
      },
    );
  }
}
