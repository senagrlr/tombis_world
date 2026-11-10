
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CompletionConfetti extends StatefulWidget {
  const CompletionConfetti({super.key});

  @override
  State<CompletionConfetti> createState() =>
      _CompletionConfettiState();
}

class _CompletionConfettiState extends State<CompletionConfetti> {
  late final ConfettiController controller;

  @override
  void initState() {
    super.initState();
    controller = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    controller.play();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: controller,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.06,
          numberOfParticles: 22,
          gravity: 0.15,
          shouldLoop: false,
          colors: const [
            Color(0xFFFFB6C1),
            Color(0xFFFFD966),
            Color(0xFFB9CB85),
            Color(0xFFBEDAF7),
            Color(0xFFD5B8FF),
          ],
        ),
      ),
    );
  }
}
