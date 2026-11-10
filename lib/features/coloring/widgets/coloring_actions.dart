
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
    final actions = [
      (AssetPaths.doneButton, onDone),
      (AssetPaths.deleteButton, onDelete),
      (AssetPaths.undoButton, onUndo),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final action in actions)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: GestureDetector(
              onTap: action.$2,
              child: Image.asset(
                action.$1,
                width: 49,
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}
