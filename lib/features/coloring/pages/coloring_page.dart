import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/button_sound_service.dart';
import '../data/coloring_palettes.dart';
import '../widgets/coloring_actions.dart';
import '../widgets/coloring_canvas.dart';
import '../widgets/coloring_tools.dart';
import '../widgets/coloring_sidebar.dart';

class ColoringPageScreen extends StatefulWidget {
  final String imagePath;

  const ColoringPageScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ColoringPageScreen> createState() =>
      _ColoringPageScreenState();
}

class _ColoringPageScreenState
    extends State<ColoringPageScreen> {
  String paletteId = ColoringPalettes.all.first.id;
  Color selectedColor = ColoringPalettes.all.first.colors.first;
  ColoringTool selectedTool = ColoringTool.brush;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ColoringPalettes.all.firstWhere(
          (item) => item.id == paletteId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, size) {
            final sideWidth =
            (size.maxWidth * 0.32).clamp(185.0, 280.0);

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: sideWidth,
                    child: ColoringSidebar(
                      palette: palette,
                      paletteId: paletteId,
                      selectedColor: selectedColor,
                      selectedTool: selectedTool,

                      onToolSelected: (tool) {
                        ButtonSoundService.tap(() {
                          setState(() => selectedTool = tool);
                        });
                      },

                      onPaletteSelected: (id) {
                        ButtonSoundService.tap(() {
                          setState(() {
                            paletteId = id;
                            selectedColor = ColoringPalettes.all
                                .firstWhere((p) => p.id == id)
                                .colors.first;
                          });
                        });
                      },

                      onColorSelected: (color) {
                        ButtonSoundService.tap(() {
                          setState(() => selectedColor = color);
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.18,
                        child: ColoringCanvas(
                          imagePath: widget.imagePath,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  ColoringActions(
                    onDone: () {
                      ButtonSoundService.tap(() {
                        context.push(
                          AppRoutes.completion,
                          extra: widget.imagePath,
                        );
                      });
                    },
                    onDelete: () {
                      ButtonSoundService.play();
                    },
                    onUndo: () {
                      ButtonSoundService.play();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
