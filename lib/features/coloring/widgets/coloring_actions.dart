import 'package:flutter/material.dart';
import '../../../core/constants/asset_paths.dart';

class ColoringActions extends StatelessWidget {
  final VoidCallback onDone;
  final VoidCallback onDelete;
  final VoidCallback onUndo;

  const ColoringActions({
    super.key,
    required this.onDone,
    required this.onDelete,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    Widget actionButton(
        String asset,
        VoidCallback onTap,
        ) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 40,
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        actionButton(
          AssetPaths.deleteButton,
          onDelete,
        ),
        const SizedBox(width: 6),
        actionButton(
          AssetPaths.undoButton,
          onUndo,
        ),
        const SizedBox(width: 6),
        actionButton(
          AssetPaths.doneButton,
          onDone,
        ),
      ],
    );
  }
}
