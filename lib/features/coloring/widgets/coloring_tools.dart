import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';

enum ColoringTool { brush, fill, eraser, picker }

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
      (ColoringTool.brush, AssetPaths.brushTool),
      (ColoringTool.fill, AssetPaths.fillTool),
      (ColoringTool.eraser, AssetPaths.eraserTool),
      (ColoringTool.picker, AssetPaths.pickerTool),
    ];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E2),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          for (final tool in tools)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(tool.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: selected == tool.$1
                        ? const Color(0xFFE6E9C5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    height: 50,
                    child: Image.asset(
                      tool.$2,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
