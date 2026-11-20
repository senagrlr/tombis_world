import 'package:flutter/material.dart';
import '../models/coloring_page.dart';

class GalleryThumbnail extends StatelessWidget {
  final ColoringPage page;
  final VoidCallback onTap;

  const GalleryThumbnail({
    super.key,
    required this.page,
    required this.onTap,
  });

  // Thumbnail'ın mevcut yatay kırpma miktarı.
  static const double horizontalTrim = 16;

  // Kart sağdan ve soldan 5'er piksel daralacak.
  static const double cardInset = 5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cardConstraints) {
        // Kart daralmadan önceki kullanılabilir thumbnail genişliği.
        final originalThumbnailWidth =
            cardConstraints.maxWidth - 24;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: cardInset,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2DE),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF5B9EE2)
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
                                    errorBuilder:
                                        (_, _, _) {
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
                      page.title,
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
        );
      },
    );
  }
}
