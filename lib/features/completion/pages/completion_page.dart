import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cozy_back_button.dart';
import '../../../core/services/rate_popup_service.dart';
import '../../../l10n/app_localizations.dart';

import '../../settings/widgets/rate_popup_dialog.dart';

import '../services/artwork_storage_service.dart';
import '../services/artwork_share_service.dart';
import '../widgets/completed_artwork.dart';
import '../widgets/completion_actions.dart';
import '../widgets/completion_confetti.dart';

class CompletionPage extends StatefulWidget {
  final String imagePath;
  final Uint8List? paintedImage;
  final bool showRatePopup;

  const CompletionPage({
    super.key,
    required this.imagePath,
    this.paintedImage,
    this.showRatePopup = false,
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
  bool _isOpeningStore = false;

  @override
  void initState() {
    super.initState();

    if (widget.showRatePopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showRatePopup();
      });
    }
  }

  // Rate Us pop-up
  Future<void> _showRatePopup() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return RatePopupDialog(
          onYes: () async {
            if (_isOpeningStore) return;

            _isOpeningStore = true;

            try {
              final opened = await _openPlayStore();

              if (!opened) {
                if (mounted) {
                  _showMessage(
                    'Google Play Store could not be opened.',
                  );
                }
                return;
              }

              // Mağaza başarıyla açıldıysa
              // değerlendirme isteğini tekrar gösterme.
              await RatePopupService.markAccepted();

              if (!dialogContext.mounted) return;

              Navigator.of(dialogContext).pop();
            } finally {
              _isOpeningStore = false;
            }
          },
        );
      },
    );
  }

  // Yeşil tik butonunun açacağı Google Play sayfası
  Future<bool> _openPlayStore() async {
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details'
          '?id=com.tombisworld.tombis_world',
    );

    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      debugPrint('Google Play Store error: $error');
      return false;
    }
  }

  // Boyamayı galeriye kaydet
  Future<void> _downloadArtwork() async {
    if (_isSaving || _isSharing) return;

    final pngBytes = widget.paintedImage;

    if (pngBytes == null || pngBytes.isEmpty) {
      _showMessage(
        AppLocalizations.of(context).noImageToSave,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _storageService.saveToGallery(pngBytes);

      if (!mounted) return;

      _showMessage(
        AppLocalizations.of(context).imageSaved,
      );
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

  // Boyamayı paylaş
  Future<void> _shareArtwork() async {
    if (_isSharing || _isSaving) return;

    final pngBytes = widget.paintedImage;

    if (pngBytes == null || pngBytes.isEmpty) {
      _showMessage(
        AppLocalizations.of(context).noImageToShare,
      );
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      await _shareService.shareArtwork(
        pngBytes,
        text: AppLocalizations.of(context)
            .shareArtworkText,
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

  // Bilgilendirme mesajı
  void _showMessage(String message) {
    if (!mounted) return;

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
              (constraints.maxWidth - 24).clamp(
                0.0,
                constraints.maxHeight * 0.75,
              );

              return Stack(
                children: [
                  // Tamamlanan boyama
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

                  // Konfeti
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
