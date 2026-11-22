import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TombiLoading extends StatelessWidget {
  const TombiLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFAF5B3),
      child: Center(
        child: Lottie.asset(
          'assets/animations/tombi_loading.json',
          width: 200,
          height: 200,
          repeat: true,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}