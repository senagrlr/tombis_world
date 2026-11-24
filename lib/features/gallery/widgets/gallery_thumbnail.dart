import 'package:flutter/material.dart';

import '../../../core/constants/asset_paths.dart';
import '../models/coloring_page.dart';
import '../../../l10n/app_localizations.dart';

class GalleryThumbnail extends StatelessWidget {
  final ColoringPage page;
  final VoidCallback onTap;

  const GalleryThumbnail({
    super.key,
    required this.page,
    required this.onTap,
  });

  static const double horizontalTrim = 16;
  static const double cardInset = 5;

  static const Color normalBorderColor = Color(0xFF5B9EE2);

  // Ödüllü görsellerin sarı kenarlığı
  static const Color rewardedBorderColor = Color(0xFFFFC533);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final originalThumbnailWidth =
            cardConstraints.maxWidth - 24;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: cardInset,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2DE),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: (page.isRewarded
                            ? rewardedBorderColor
                            : normalBorderColor)
                            .withValues(alpha: 0.85),
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 5,
                          offset: Offset(2, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final originalHeight =
                                  constraints.maxHeight;

                              final maskWidth =
                              (originalThumbnailWidth -
                                  horizontalTrim)
                                  .clamp(
                                1.0,
                                originalThumbnailWidth,
                              )
                                  .toDouble();

                              return Center(
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(15),
                                  child: SizedBox(
                                    width: maskWidth,
                                    height: originalHeight,
                                    child: OverflowBox(
                                      alignment: Alignment.center,
                                      minWidth:
                                      originalThumbnailWidth,
                                      maxWidth:
                                      originalThumbnailWidth,
                                      minHeight: originalHeight,
                                      maxHeight: originalHeight,
                                      child: Image.asset(
                                        page.thumbnailPath,
                                        width:
                                        originalThumbnailWidth,
                                        height: originalHeight,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) {
                                          return const Center(
                                            child: Icon(
                                              Icons.image_outlined,
                                              size: 40,
                                              color:
                                              Color(0xFFAA7956),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          _localizedTitle(context, page.id),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF704B36),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Yalnızca ödüllü görsellerde video ikonu
              if (page.isRewarded)
                Positioned(
                  top: -13,
                  right: -12,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: 0.20,
                      child: Image.asset(
                        AssetPaths.rewardedAdIcon,
                        width: 65,
                        height: 65,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

String _localizedTitle(BuildContext context, String id) {
  final l10n = AppLocalizations.of(context);

  return switch (id) {
    'farmer' => l10n.galleryFarmer,
    'sakura' => l10n.gallerySakura,
    'painter' => l10n.galleryPainter,
    'garden' => l10n.galleryGarden,
    'winter' => l10n.galleryWinter,
    'summer' => l10n.gallerySummer,
    'spring' => l10n.gallerySpring,
    'amusument_park' => l10n.galleryAmusumentPark,
    'chef' => l10n.galleryChef,
    'halloween' => l10n.galleryHalloween,
    'tailor' => l10n.galleryTailor,
    'skater' => l10n.gallerySkater,
    'school' => l10n.gallerySchool,
    'newyear_eve' => l10n.galleryNewyearEve,
    'ice_cream' => l10n.galleryIceCream,
    'gym' => l10n.galleryGym,
    'flower_shop' => l10n.galleryFlowerShop,
    'bed_time' => l10n.galleryBedTime,
    'astronaut' => l10n.galleryAstronaut,
    'aquarium' => l10n.galleryAquarium,
    _ => id,
  };
}
