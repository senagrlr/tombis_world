
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/coloring_category.dart';

class GalleryCategories extends StatelessWidget {
  final List<ColoringCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const GalleryCategories({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category.id == selectedId;

          return Center(
            child: GestureDetector(
              onTap: () => onSelected(category.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.cream
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? AppColors.brown
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: AppColors.darkBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
