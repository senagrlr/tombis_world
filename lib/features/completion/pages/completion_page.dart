
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cozy_back_button.dart';
import '../widgets/completed_artwork.dart';
import '../widgets/completion_actions.dart';
import '../widgets/completion_confetti.dart';

class CompletionPage extends StatelessWidget {
  final String imagePath;
  final Uint8List? paintedImage;

  const CompletionPage({
    super.key,
    required this.imagePath,
    this.paintedImage,
  });

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
                      imagePath: imagePath,
                      paintedImage: paintedImage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 56,
                    child: CompletionActions(
                      onHome: () => context.go(AppRoutes.home),
                      onDownload: () {},
                      onShare: () {},
                    ),
                  ),
                ],
              ),
              const Positioned.fill(
                child: CompletionConfetti(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
