/// An input into an FFMPEG filter graph.
///
/// An input might refer to a video file, audio file, or virtual device.
class FFMpegInput {
  /// Configures an FFMPEG input for an asset at the given [assetPath].
  FFMpegInput.asset(String assetPath) : args = ['-i', assetPath];

  /// Configures an FFMPEG input for a virtual device.
  ///
  /// See the FFMPEG docs for more information.
  FFMpegInput.virtualDevice(String device)
      : args = ['-f', 'lavfi', '-i', device];

  const FFMpegInput(this.args);

  /// List of CLI arguments that configure a single FFMPEG input.
  final List<String> args;

  /// Returns this input in a form that can be added to a CLI string.
  ///
  /// Example: "-i /videos/vid1.mp4"
  String toCli() => args.join(' ');
}
