import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const title = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.brown,
  );

  static const heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.brown,
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.darkBrown,
  );

  static const button = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.cream,
  );
}
