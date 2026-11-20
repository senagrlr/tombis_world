
import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';
import '../models/coloring_tool.dart';

class ColoringTools extends StatelessWidget {
  final ColoringTool selected;
  final ValueChanged<ColoringTool> onSelected;

  const ColoringTools({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const tools = [
      (ColoringTool.brush, AssetPaths.brushTool, 'Brush'),
      (ColoringTool.fill, AssetPaths.fillTool, 'Fill'),
      (ColoringTool.eraser, AssetPaths.eraserTool, 'Eraser'),
      (ColoringTool.picker, AssetPaths.pickerTool, 'Picker'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tool in tools)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(tool.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 62,
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected == tool.$1
                      ? const Color(0xFFE6E9C5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      tool.$2,
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tool.$3,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF704B36),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
