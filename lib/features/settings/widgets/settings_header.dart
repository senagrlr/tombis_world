import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cozy_back_button.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 205,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: PhysicalShape(
              clipper: _WaveClipper(),
              color: AppColors.cream,
              elevation: 4,
              shadowColor: const Color(0x66000000),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            top: topPadding + 12,
            left: 25,
            child: const CozyBackButton(),
          ),
          const Positioned(
            top: 82,
            left: 0,
            right: 0,
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppColors.brown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 38);
    final waveWidth = size.width / 5;

    for (var i = 0; i < 5; i++) {
      final x = i * waveWidth;

      path.quadraticBezierTo(
        x + waveWidth / 2,
        size.height + 25,
        x + waveWidth,
        size.height - 38,
      );
    }

    return path
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
