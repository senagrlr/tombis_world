
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'cozy_toggle.dart';

class SettingsOption extends StatelessWidget {
  final String title;
  final String iconPath;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  const SettingsOption({
    super.key,
    required this.title,
    required this.iconPath,
    this.value,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          // PNG ikon - ekstra stroke veya gölge yok.
          Image.asset(
            iconPath,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBrown,
              ),
            ),
          ),

          if (value != null && onChanged != null)
            CozyToggle(
              value: value!,
              onChanged: onChanged!,
            )
          else
            IconButton(
              onPressed: onTap,
              icon: const Icon(
                Icons.arrow_forward_rounded,
              ),
              color: AppColors.darkBrown,
            ),
        ],
      ),
    );
  }
}
