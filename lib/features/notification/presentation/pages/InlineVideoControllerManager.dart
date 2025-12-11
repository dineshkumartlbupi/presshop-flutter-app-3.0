import 'package:flick_video_player/flick_video_player.dart';

class InlineVideoControllerManager {
  static FlickManager? _currentManager;

  /// Public getter
  static FlickManager? get currentManager => _currentManager;

  /// Sets the active manager: pauses the previous and keeps the new one as current.
  static void setActive(FlickManager manager) {
    try {
      _currentManager?.flickControlManager?.pause();
    } catch (e) {
      // ignore
    }
    _currentManager = manager;
  }

  /// Pause current (safe)
  static void pauseCurrent() {
    try {
      _currentManager?.flickControlManager?.pause();
    } catch (e) {
      // ignore
    }
  }

  /// Dispose and clear current
  static void clear() {
    try {
      _currentManager?.dispose();
    } catch (e) {
      // ignore
    }
    _currentManager = null;
  }
}
