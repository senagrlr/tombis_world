
import 'package:flutter/foundation.dart';

class ColoringHistory {
  static const int maxUndoSteps = 100;

  final List<VoidCallback> _undoActions = [];

  bool get canUndo => _undoActions.isNotEmpty;

  int get undoCount => _undoActions.length;

  void record(VoidCallback undoAction) {
    _undoActions.add(undoAction);

    if (_undoActions.length > maxUndoSteps) {
      _undoActions.removeAt(0);
    }
  }

  bool undo() {
    if (_undoActions.isEmpty) {
      return false;
    }

    final undoAction = _undoActions.removeLast();
    undoAction();

    return true;
  }

  void clear() {
    _undoActions.clear();
  }
}
