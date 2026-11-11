import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/button_sound_service.dart';
import '../data/gallery_data.dart';
import '../widgets/gallery_header.dart';
import '../widgets/gallery_categories.dart';
import '../widgets/gallery_grid.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String selectedCategory = GalleryData.categories.first.id;

  @override
  Widget build(BuildContext context) {
    final filteredPages = GalleryData.pages
        .where((page) => page.categoryId == selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const GalleryHeader(),
            const SizedBox(height: 2),
            GalleryCategories(
              categories: GalleryData.categories,
              selectedId: selectedCategory,
              onSelected: (id) {
                ButtonSoundService.tap(() {
                  setState(() => selectedCategory = id);
                });
              },
            ),
            Expanded(
              child: GalleryGrid(
                key: ValueKey(selectedCategory),
                pages: filteredPages,
                onPageSelected: (page) {
                  ButtonSoundService.tap(() {
                    context.push(
                      AppRoutes.coloring,
                      extra: page.imagePath,
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
