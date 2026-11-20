
import 'dart:typed_data';

import 'package:gal/gal.dart';

class ArtworkStorageService {
  const ArtworkStorageService();

  Future<void> saveToGallery(Uint8List pngBytes) async {
    if (pngBytes.isEmpty) {
      throw ArgumentError('PNG data cannot be empty.');
    }

    await Gal.putImageBytes(
      pngBytes,
      name: 'tombili_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
