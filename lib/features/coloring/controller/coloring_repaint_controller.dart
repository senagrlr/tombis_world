
import 'package:flutter/foundation.dart';

class ColoringRepaintController {
  final ValueNotifier<int> strokes = ValueNotifier<int>(0);

  int get strokeRevision => strokes.value;

  void strokesChanged() {
    strokes.value++;
  }

  void allChanged() {
    strokesChanged();
  }

  void dispose() {
    strokes.dispose();
  }
}
