
import 'package:flutter/material.dart';

class BrushSizeSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final Color previewColor;
  final ValueChanged<double> onChanged;

  const BrushSizeSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.previewColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Container(
                width: 8 + (value - min) / (max - min) * 28,
                height: 8 + (value - min) / (max - min) * 28,
                decoration: BoxDecoration(
                  color: previewColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black26,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              value.round().toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
