import 'package:video_player/video_player.dart';

/// Extensions for the [VideoPlayerController]'s object.
extension VideoControllerExtension on VideoPlayerController {
  /// Extension to forward the video's current position.
  Future<void> fastForward() async {
    if (value.duration.inSeconds - value.position.inSeconds > 10) {
      return seekTo(Duration(seconds: value.position.inSeconds + 10));
    }
  }

  /// Extension to rewind the video's current position.
  Future<void> rewind() async {
    if (value.position.inSeconds > 10) {
      return seekTo(Duration(seconds: value.position.inSeconds - 10));
    } else {
      return seekTo(const Duration(seconds: 0));
    }
  }
}
