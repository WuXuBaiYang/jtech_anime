/// A single video/audio stream pair within an FFMPEG filter graph.
///
/// A stream might include a video ID, or an audio ID, or both.
///
/// Every filter chain in an FFMPEG filter graph requires one or more
/// input streams, and produces one or more output streams. From a CLI
/// perspective, these streams are just string names within the filter
/// graph configuration. However, these string names need to match, as
/// outputs from one filter chain are used as inputs in another filter
/// chain. To that end, these streams are represented by this class.
class FFMpegStream {
  const FFMpegStream({
    this.videoId,
    this.audioId,
  }) : assert(videoId != null || audioId != null,
            "FFMpegStream must include a videoId, or an audioId.");

  /// Handle to a video stream, e.g., "[0:v]".
  final String? videoId;

  /// Handle to an audio stream, e.g., "[0:a]".
  final String? audioId;

  /// Returns a copy of this stream with just the video stream handle.
  ///
  /// If this stream only includes video, then this stream is returned.
  FFMpegStream get videoOnly {
    return audioId == null ? this : FFMpegStream(videoId: videoId);
  }

  /// Returns a copy of this stream with just the audio stream handle.
  ///
  /// If this stream only includes audio, then this stream is returned.
  FFMpegStream get audioOnly {
    return videoId == null ? this : FFMpegStream(audioId: audioId);
  }

  /// Returns the video and audio handles for this stream in a list,
  /// to pass into a filter graph as filter inputs or outputs, e.g.,
  /// "[0:v] [0:a]".
  List<String> toCliList() {
    final List<String> streams = [];
    if (videoId != null) {
      streams.add(videoId!);
    }
    if (audioId != null) {
      streams.add(audioId!);
    }
    return streams;
  }

  @override
  String toString() => toCliList().join(" ");
}
