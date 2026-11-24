import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cozy_back_button.dart';
import '../../../core/widgets/tombi_loading.dart';
import '../../../core/services/button_sound_service.dart';
import '../../../core/services/rate_popup_service.dart';

import '../data/coloring_palettes.dart';
import '../widgets/coloring_actions.dart';
import '../widgets/coloring_canvas.dart';
import '../widgets/coloring_sidebar.dart';
import '../widgets/leave_coloring_dialog.dart';
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

class _ColoringPageScreenState extends State<ColoringPageScreen> {
  final ColoringController _controller = ColoringController();

  final GlobalKey<ColoringCanvasState> _canvasKey =
  GlobalKey<ColoringCanvasState>();

  bool _isExporting = false;
  bool _isExitDialogOpen = false;
  bool _allowExit = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBack() async {
    if (_isExporting || _isExitDialogOpen || _allowExit) return;

    _isExitDialogOpen = true;

    try {
      final hasChanges =
          _canvasKey.currentState?.hasUnsavedChanges ?? false;

      if (hasChanges) {
        final shouldLeave = await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.35),
          builder: (dialogContext) {
            return const LeaveColoringDialog();
          },
        );

        if (!mounted || shouldLeave != true) return;
      }

      if (!mounted) return;

      setState(() => _allowExit = true);

      await WidgetsBinding.instance.endOfFrame;

      if (!mounted) return;

      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.gallery);
      }
    } finally {
      _isExitDialogOpen = false;
    }
  }

  Future<bool?> _showConfirmation({
    required String title,
    String? message,
  }) {
    return showDialog<bool>(
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
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF704B36),
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF704B36),
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
  }

  Future<void> _confirmReset() async {
    final shouldReset = await _showConfirmation(
      title: AppLocalizations.of(context).resetColoringTitle,
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

      final shouldShowRatePopup =
      await RatePopupService.onPaintingCompleted();

      if (!mounted) return;

      await context.push(
        AppRoutes.completion,
        extra: {
          'imagePath': widget.imagePath,
          'paintedImage': pngBytes,
          'showRatePopup': shouldShowRatePopup,
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

    return PopScope<Object?>(
      canPop: _allowExit,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    AssetPaths.galleryBackground,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            24, 16, 24, 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CozyBackButton(onTap: _handleBack),
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
                                    _canvasKey.currentState?.undo();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, canvasConstraints) {
                              final canvasSize =
                              canvasConstraints.maxWidth <
                                  canvasConstraints.maxHeight
                                  ? canvasConstraints.maxWidth
                                  : canvasConstraints.maxHeight;

                              return Center(
                                child: SizedBox(
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
                                      _controller.selectPickedColor(color);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            24, 0, 24, 8,
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
      ),
    );
  }
}
