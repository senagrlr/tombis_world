import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/button_sound_service.dart';
import '../data/coloring_palettes.dart';
import '../widgets/coloring_actions.dart';
import '../widgets/coloring_canvas.dart';
import '../widgets/coloring_sidebar.dart';
import '../controller/coloring_controller.dart';

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
  final ColoringController _controller = ColoringController();
  final GlobalKey<ColoringCanvasState> _canvasKey = GlobalKey<ColoringCanvasState>();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
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
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset coloring?'),
          content: const Text(
            'All your coloring will be erased. '
                'You cannot undo this action.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Reset'),
            ),
          ],
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
        throw StateError('Coloring image is not ready.');
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
        const SnackBar(
          content: Text(
            'Could not finish coloring. Please try again.',
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

                  const SizedBox(width: 18),

                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ColoringCanvas(
                          key: _canvasKey,
                          imagePath: widget.imagePath,
                          selectedColor: selectedColor,
                          selectedTool: selectedTool,
                          brushWidth: _controller.brushWidth,
                          eraserWidth: _controller.eraserWidth,
                          onColorPicked: (color) {
                            _controller.selectPickedColor(color);
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

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
                        _canvasKey.currentState?.undo();
                      });
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
