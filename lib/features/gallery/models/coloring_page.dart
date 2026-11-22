class ColoringPage {
  final String id;
  final String title;
  final String thumbnailPath;
  final String imagePath;

  // Görsel ödüllü reklamla mı açılıyor?
  final bool isRewarded;

  const ColoringPage({
    required this.id,
    required this.title,
    required this.thumbnailPath,
    required this.imagePath,
    this.isRewarded = false,
  });
}
