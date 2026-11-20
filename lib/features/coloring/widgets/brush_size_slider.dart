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
    final progress =
    ((value - min) / (max - min)).clamp(0.0, 1.0);

    // Boyut arttıkça tutamaç da büyür.
    final thumbSize = 20.0 + (progress * 16.0);

    const trackColor = Color(0xFF795039);

    return SizedBox(
      height: 46,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth - 36;

          void updateValue(double dx) {
            final fraction =
            (dx / trackWidth).clamp(0.0, 1.0);

            onChanged(min + fraction * (max - min));
          }

          return Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                updateValue(details.localPosition.dx - 18);
              },
              onTapDown: (details) {
                updateValue(details.localPosition.dx - 18);
              },
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: 18,
                      right: 18,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: trackColor,
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18 + trackWidth * progress
                          - thumbSize / 2,
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: trackColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
