
import 'package:flutter/foundation.dart';

import '../models/coloring_page.dart';

class SessionUnlockController extends ChangeNotifier {
  SessionUnlockController();

  static final SessionUnlockController instance =
  SessionUnlockController();

  final Set<String> _unlockedPageIds = {};

  int _sessionVersion = 0;

  int get sessionVersion => _sessionVersion;

  bool isUnlocked(ColoringPage page) {
    return !page.isRewarded ||
        _unlockedPageIds.contains(page.id);
  }

  bool isLocked(ColoringPage page) {
    return !isUnlocked(page);
  }

  void unlockPage(ColoringPage page) {
    if (!page.isRewarded) return;

    if (_unlockedPageIds.add(page.id)) {
      notifyListeners();
    }
  }

  void resetSession() {
    _sessionVersion++;

    if (_unlockedPageIds.isEmpty) return;

    _unlockedPageIds.clear();

    notifyListeners();
  }
}
