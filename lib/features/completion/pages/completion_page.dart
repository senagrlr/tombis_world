
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

class CompletionPage extends StatefulWidget {
  final String imagePath;
  final Uint8List? paintedImage;

  const CompletionPage({
    super.key,
    required this.imagePath,
    this.paintedImage,
  });

  @override
  State<CompletionPage> createState() => _CompletionPageState();
}

class _CompletionPageState extends State<CompletionPage> {
  final ArtworkStorageService _storageService = const ArtworkStorageService();
  final ArtworkShareService _shareService = const ArtworkShareService();

  bool _isSaving = false;
  bool _isSharing = false;

  Future<void> _downloadArtwork() async {
    if (_isSaving || _isSharing) return;

    final pngBytes = widget.paintedImage;

    if (pngBytes == null || pngBytes.isEmpty) {
      _showMessage('No image available to save.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _storageService.saveToGallery(pngBytes);

      if (!mounted) return;

      _showMessage('Image saved to gallery!');
    } catch (error, stackTrace) {
      debugPrint('Artwork save error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage('Could not save image. Please try again.');
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
      _showMessage('No image available to share.');
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      await _shareService.shareArtwork(pngBytes);
    } catch (error, stackTrace) {
      debugPrint('Artwork share error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage('Could not share image. Please try again.');
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CozyBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CompletedArtwork(
                      imagePath: widget.imagePath,
                      paintedImage: widget.paintedImage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 56,
                    child: CompletionActions(
                      onHome: () => context.go(AppRoutes.home),
                      onDownload: _downloadArtwork,
                      onShare: _shareArtwork,
                    ),
                  ),
                ],
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: CompletionConfetti(),
                ),
              ),
              if (_isSaving || _isSharing)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
