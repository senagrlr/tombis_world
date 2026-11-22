import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cozy_back_button.dart';

import '../services/artwork_storage_service.dart';
import '../services/artwork_share_service.dart';
import '../widgets/completed_artwork.dart';
import '../widgets/completion_actions.dart';
import '../widgets/completion_confetti.dart';
import '../../../l10n/app_localizations.dart';

class CompletionPage extends StatefulWidget {
  final String imagePath;
  final Uint8List? paintedImage;

  const CompletionPage({
    super.key,
    required this.imagePath,
    this.paintedImage,
  });

  @override
  State<CompletionPage> createState() =>
      _CompletionPageState();
}

class _CompletionPageState extends State<CompletionPage> {
  final ArtworkStorageService _storageService =
  const ArtworkStorageService();

  final ArtworkShareService _shareService =
  const ArtworkShareService();

  bool _isSaving = false;
  bool _isSharing = false;

  Future<void> _downloadArtwork() async {
    if (_isSaving || _isSharing) return;

    final pngBytes = widget.paintedImage;

    if (pngBytes == null || pngBytes.isEmpty) {
      _showMessage(AppLocalizations.of(context).noImageToSave);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _storageService.saveToGallery(pngBytes);

      if (!mounted) return;

      _showMessage(AppLocalizations.of(context).imageSaved);
    } catch (error, stackTrace) {
      debugPrint('Artwork save error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage(
        AppLocalizations.of(context).saveImageError,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _shareArtwork() async {
    if (_isSharing || _isSaving) return;

    final pngBytes = widget.paintedImage;

    if (pngBytes == null || pngBytes.isEmpty) {
      _showMessage(AppLocalizations.of(context).noImageToShare);
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      await _shareService.shareArtwork(
        pngBytes,
        text: AppLocalizations.of(context).shareArtworkText,
      );
    } catch (error, stackTrace) {
      debugPrint('Artwork share error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage(
        AppLocalizations.of(context).shareImageError,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/gallery/gallery_background.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final artworkSize =
              (constraints.maxWidth - 24)
                  .clamp(0.0, constraints.maxHeight * 0.75);

              return Stack(
                children: [
                  // Tamamlanan görsel
                  Center(
                    child: SizedBox(
                      width: artworkSize,
                      height: artworkSize,
                      child: CompletedArtwork(
                        imagePath: widget.imagePath,
                        paintedImage: widget.paintedImage,
                      ),
                    ),
                  ),

                  // Geri butonu
                  const Positioned(
                    top: 20,
                    left: 20,
                    child: CozyBackButton(),
                  ),

                  // Home ve Download
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Column(
                      children: [
                        CompletionActions.actionButton(
                          'assets/images/completion_ui/home_button.png',
                              () => context.go(AppRoutes.home),
                        ),
                        const SizedBox(height: 5),
                        CompletionActions.actionButton(
                          'assets/images/completion_ui/download_button.png',
                          _downloadArtwork,
                        ),
                      ],
                    ),
                  ),

                  // Share
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: CompletionActions.actionButton(
                      'assets/images/completion_ui/share_button.png',
                      _shareArtwork,
                    ),
                  ),

                  // Konfeti - aynen korundu
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: CompletionConfetti(),
                    ),
                  ),

                  // Kaydetme / paylaşma göstergesi
                  if (_isSaving || _isSharing)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
