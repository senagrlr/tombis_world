import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cozy_back_button.dart';
import '../../../core/widgets/tombi_loading.dart';
import '../../../core/services/button_sound_service.dart';

import '../data/coloring_palettes.dart';
import '../widgets/coloring_actions.dart';
import '../widgets/coloring_canvas.dart';
import '../widgets/coloring_sidebar.dart';
import '../controller/coloring_controller.dart';
import '../../../l10n/app_localizations.dart';

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
  final ColoringController _controller =
  ColoringController();

  final GlobalKey<ColoringCanvasState> _canvasKey =
  GlobalKey<ColoringCanvasState>();

  bool _isExporting = false;

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onControllerChanged);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _controller.removeListener(_onControllerChanged);
    _controller.dispose();

    super.dispose();
  }

  Future<void> _confirmReset() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFFFF2DE),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: const BorderSide(
              color: Color(0xFF5B9EE2),
              width: 3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(dialogContext).resetColoringTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF704B36),
                  ),
                ),

                const SizedBox(height: 26),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // X - İptal
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      child: Container(
                        width: 76,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2A5A5),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF704B36),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF704B36),
                          size: 30,
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Tik - Sıfırla
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      child: Container(
                        width: 76,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB9CB85),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF704B36),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF704B36),
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || shouldReset != true) return;

    _canvasKey.currentState?.resetColoring();
  }

  Future<void> _completeColoring() async {
    if (_isExporting) return;

    final canvas = _canvasKey.currentState;
    if (canvas == null) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final pngBytes = await canvas.exportPng();

      if (!mounted) return;

      if (pngBytes == null) {
        throw StateError(
          'Coloring image is not ready.',
        );
      }

      await context.push(
        AppRoutes.completion,
        extra: {
          'imagePath': widget.imagePath,
          'paintedImage': pngBytes,
        },
      );
    } catch (error) {
      if (!mounted) return;

      debugPrint('Coloring export error: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).finishColoringError,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paletteId = _controller.paletteId;
    final selectedColor = _controller.selectedColor;
    final selectedTool = _controller.selectedTool;

    final palette = ColoringPalettes.all.firstWhere(
          (item) => item.id == paletteId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
      Container(
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
              final canvasSize =
                  constraints.maxWidth;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Üst butonlar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        24, 16, 24, 12,
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const CozyBackButton(),
                          const Spacer(),
                          ColoringActions(
                            onDone: () {
                              if (_isExporting) return;

                              ButtonSoundService.tap(() {
                                _completeColoring();
                              });
                            },
                            onDelete: () {
                              ButtonSoundService.tap(() {
                                _confirmReset();
                              });
                            },
                            onUndo: () {
                              ButtonSoundService.tap(() {
                                _canvasKey.currentState
                                    ?.undo();
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Mevcut boyama alanı
                    SizedBox(
                      width: canvasSize,
                      height: canvasSize,
                      child: ColoringCanvas(
                        key: _canvasKey,
                        imagePath: widget.imagePath,
                        selectedColor: selectedColor,
                        selectedTool: selectedTool,
                        brushWidth: _controller.brushWidth,
                        eraserWidth: _controller.eraserWidth,
                        onColorPicked: (color) {
                          _controller.selectPickedColor(
                            color,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Araçlar, slider ve paletler
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        24, 0, 24, 24,
                      ),
                      child: ColoringSidebar(
                        palette: palette,
                        paletteId: paletteId,
                        selectedColor: selectedColor,
                        selectedTool: selectedTool,
                        brushWidth: _controller.brushWidth,
                        eraserWidth: _controller.eraserWidth,

                        onBrushWidthChanged: (width) {
                          _controller.setBrushWidth(width);
                        },

                        onEraserWidthChanged: (width) {
                          _controller.setEraserWidth(width);
                        },

                        onToolSelected: (tool) {
                          ButtonSoundService.tap(() {
                            _controller.selectTool(tool);
                          });
                        },

                        onPaletteSelected: (id) {
                          ButtonSoundService.tap(() {
                            _controller.selectPalette(id);
                          });
                        },

                        onColorSelected: (color) {
                          ButtonSoundService.tap(() {
                            _controller.selectColor(color);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
          if (_isExporting)
            const Positioned.fill(
              child: TombiLoading(),
            ),
        ],
      ),
    );
  }
}
