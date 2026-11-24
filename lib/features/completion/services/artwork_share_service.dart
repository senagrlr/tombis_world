import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';

class ArtworkShareService {
  const ArtworkShareService();

  Future<void> shareArtwork(Uint8List pngBytes, {required String text,}) async {
    if (pngBytes.isEmpty) {
      throw ArgumentError('PNG data cannot be empty.');
    }

    final file = XFile.fromData(
      pngBytes,
      mimeType: 'image/png',
      name: 'tombili_coloring.png',
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        fileNameOverrides: ['tombili_coloring.png'],
        text: text,
      ),
    );
  }
}
