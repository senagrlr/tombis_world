import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TombiLoading extends StatelessWidget {
  const TombiLoading({super.key});

  static const String _animationPath =
      'assets/animations/tombi_loading.json';

  static LottieComposition? _cachedComposition;
  static Future<LottieComposition>? _loadingFuture;

  // Animasyonu yalnızca bir kez yükle.
  static Future<void> preload() async {
    await _getComposition();
  }

  static Future<LottieComposition> _getComposition() {
    if (_cachedComposition != null) {
      return Future.value(_cachedComposition!);
    }

    return _loadingFuture ??= _loadComposition();
  }

  static Future<LottieComposition> _loadComposition() async {
    try {
      final composition = await AssetLottie(
        _animationPath,
      ).load();

      _cachedComposition = composition;

      return composition;
    } catch (error) {
      _loadingFuture = null;
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFAF5B3),
      child: Center(
        child: SizedBox(
          width: 260,
          height: 260,
          child: _cachedComposition != null
              ? Lottie(
            composition: _cachedComposition,
            repeat: true,
            fit: BoxFit.contain,
          )
              : FutureBuilder<LottieComposition>(
            future: _getComposition(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              return Lottie(
                composition: snapshot.data,
                repeat: true,
                fit: BoxFit.contain,
              );
            },
          ),
        ),
      ),
    );
  }
}
