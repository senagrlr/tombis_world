import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'cozy_toggle.dart';

class SettingsOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  const SettingsOption({
    super.key,
    required this.title,
    required this.icon,
    this.value,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Icon(icon, size: 25, color: AppColors.brown),
          const SizedBox(width: 14),
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
            CozyToggle(value: value!, onChanged: onChanged!)
          else
            IconButton(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded),
              color: AppColors.darkBrown,
            ),
        ],
      ),
    );
  }
}
