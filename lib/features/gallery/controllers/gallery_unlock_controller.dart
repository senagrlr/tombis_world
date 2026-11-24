
import '../../../core/ads/ad_coordinator.dart';

import '../models/coloring_page.dart';
import 'session_unlock_controller.dart';

enum GalleryUnlockResult {
  unlocked,
  adUnavailable,
  rewardNotEarned,
  busy,
}

class GalleryUnlockController {
  GalleryUnlockController({
    required AdCoordinator ads,
    required SessionUnlockController session,
  })  : _ads = ads,
        _session = session;

  static final GalleryUnlockController instance =
  GalleryUnlockController(
    ads: AdCoordinator.instance,
    session: SessionUnlockController.instance,
  );

  final AdCoordinator _ads;
  final SessionUnlockController _session;

  bool _isUnlocking = false;

  bool get isUnlocking => _isUnlocking;

  bool isLocked(ColoringPage page) {
    return _session.isLocked(page);
  }

  Future<GalleryUnlockResult> unlockPage(ColoringPage page) async {
    if (!_session.isLocked(page)) {
      return GalleryUnlockResult.unlocked;
    }

    if (_isUnlocking || _ads.isBusy) {
      return GalleryUnlockResult.busy;
    }

    _isUnlocking = true;

    final sessionVersion = _session.sessionVersion;

    try {
      final wasShown = await _ads.showRewarded(
        onRewardEarned: () {
          if (sessionVersion != _session.sessionVersion) {
            return;
          }

          _session.unlockPage(page);
        },
      );

      if (sessionVersion != _session.sessionVersion) {
        return GalleryUnlockResult.rewardNotEarned;
      }

      if (_session.isUnlocked(page)) {
        return GalleryUnlockResult.unlocked;
      }

      if (!wasShown) {
        return GalleryUnlockResult.adUnavailable;
      }

      return GalleryUnlockResult.rewardNotEarned;
    } finally {
      _isUnlocking = false;
    }
  }
}
