
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
    if (pages.isEmpty) {
      return const Center(
        child: Text('New coloring pages coming soon!'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(25, 8, 25, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 1.28,
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
