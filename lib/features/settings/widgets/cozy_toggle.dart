
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CozyToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CozyToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 60,
          height: 29,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value
                ? AppColors.brown
                : const Color(0xFFCBBEB1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.darkBrown,
              width: 2,
            ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            alignment: value
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: 19,
              height: 19,
              decoration: const BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
