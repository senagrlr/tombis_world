import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/services/button_sound_service.dart';
import '../data/gallery_data.dart';
import '../widgets/gallery_header.dart';
import '../widgets/gallery_grid.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  static const AssetImage _backgroundImage = AssetImage(
    AssetPaths.galleryBackground,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Galeri arka planını önceden belleğe al.
    precacheImage(_backgroundImage, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: _backgroundImage,
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const GalleryHeader(),
                GalleryGrid(
                  pages: GalleryData.pages,
                  onPageSelected: (page) {
                    ButtonSoundService.tap(() {
                      context.push(
                        AppRoutes.coloring,
                        extra: page.imagePath,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
