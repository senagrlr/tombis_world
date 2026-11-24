
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/services/button_sound_service.dart';
import '../controllers/gallery_unlock_controller.dart';
import '../data/gallery_data.dart';
import '../models/coloring_page.dart';
import '../widgets/gallery_header.dart';
import '../widgets/gallery_grid.dart';
import '../widgets/ad_unavailable_dialog.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  static const AssetImage _backgroundImage = AssetImage(
    'assets/images/gallery/gallery_background.png',
  );

  final GalleryUnlockController _unlockController =
      GalleryUnlockController.instance;

  bool _isOpeningPage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(_backgroundImage, context);
  }

  Future<void> _onPageSelected(ColoringPage page) async {
    if (_isOpeningPage) return;

    _isOpeningPage = true;

    try {
      ButtonSoundService.play();

      if (_unlockController.isLocked(page)) {
        final result = await _unlockController.unlockPage(page);

        if (!mounted) return;

        if (ModalRoute.of(context)?.isCurrent != true) return;

        if (result == GalleryUnlockResult.adUnavailable) {
          await showDialog<void>(
            context: context,
            barrierColor: Colors.black54,
            builder: (_) => const AdUnavailableDialog(),
          );

          return;
        }

        if (result != GalleryUnlockResult.unlocked) {
          return;
        }
      }

      if (!mounted) return;

      if (ModalRoute.of(context)?.isCurrent != true) return;

      await context.push(
        AppRoutes.coloring,
        extra: page.imagePath,
      );
    } finally {
      _isOpeningPage = false;
    }
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
                  onPageSelected: _onPageSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
