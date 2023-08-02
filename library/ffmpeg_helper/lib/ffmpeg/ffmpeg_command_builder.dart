import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import '../logging.dart';

/// Builds an [FFMpegCommand] by accumulating all inputs and filter
/// streams for a given command, and then generates the CLI arguments.
///
/// An [FFMpegCommand] can be constructed directly, but [FFMpegBuilder]
/// helps to ensure that all of your inputs have appropriate flags, and
/// all of your stream IDs match, where expected.
///
/// To build an [FFMpegCommand], first, ddd inputs with [addAsset],
/// [addNullVideo], [addNullAudio], [addVideoVirtualDevice], and
/// [addAudioVirtualDevice].
///
/// Configure the filter graph by creating streams with [createStream], and
/// then combine those [FFMpegStream]s with [Filter]s, into [FilterChain]s,
/// and add the [FilterChain]s with [addFilterChain].
///
/// Once you've added all inputs, and you've configured the filter graph,
/// create the [FFMpegCommand] with [build].
class FFMpegBuilder {
  // FFMPEG command inputs, e.g., assets.
  final Map<FFMpegInput, FFMpegStream> _inputs = <FFMpegInput, FFMpegStream>{};

  // FFMpegBuilder assigns unique IDs to streams by tracking the total
  // number of created streams, and then using the number after that.
  // Using incrementing IDs makes it easier to trace bugs, rather than
  // generate unrelated IDs for every stream.
  int _compositionStreamCount = 0;

  final List<FilterChain> _filterChains = [];

  /// Adds an input asset at the given [assetPath].
  ///
  /// If [hasVideo] is `true`, the asset is processed for video frames.
  /// If [hasAudio] is `true`, the asset is processed for audio streams.
  FFMpegStream addAsset(
    String assetPath, {
    bool hasVideo = true,
    bool hasAudio = true,
  }) {
    final input = FFMpegInput.asset(assetPath);

    // Generate video and audio stream IDs using the format that
    // FFMPEG expects.
    final videoId = hasVideo
        ? hasVideo && hasAudio
            ? '[${_inputs.length}:v]'
            : '[${_inputs.length}]'
        : null;
    final audioId = hasAudio
        ? hasVideo && hasAudio
            ? '[${_inputs.length}:a]'
            : '[${_inputs.length}]'
        : null;

    _inputs.putIfAbsent(
        input,
        () => FFMpegStream(
              videoId: videoId,
              audioId: audioId,
            ));

    return _inputs[input]!;
  }

  /// Adds a virtual video input asset with the given [width] and [height],
  /// which can be used to fill up time when no other video is available.
  FFMpegStream addNullVideo({
    required int width,
    required int height,
  }) {
    final input = FFMpegInput.virtualDevice('nullsrc=s=${width}x$height');
    final stream = _inputs.putIfAbsent(
        input,
        () => FFMpegStream(
              videoId: '[${_inputs.length}]',
              audioId: null,
            ));
    return stream;
  }

  /// Adds a virtual audio input asset, which can be used to fill audio
  /// when no other audio source is available.
  FFMpegStream addNullAudio() {
    final input = FFMpegInput.virtualDevice('anullsrc=sample_rate=48000');
    final stream = _inputs.putIfAbsent(
        input,
        () => FFMpegStream(
              videoId: null,
              audioId: '[${_inputs.length}]',
            ));
    return stream;
  }

  FFMpegStream addVideoVirtualDevice(String device) {
    final input = FFMpegInput.virtualDevice(device);
    final stream = _inputs.putIfAbsent(
        input,
        () => FFMpegStream(
              videoId: '[${_inputs.length}]',
              audioId: null,
            ));
    return stream;
  }

  FFMpegStream addAudioVirtualDevice(String device) {
    final input = FFMpegInput.virtualDevice(device);
    final stream = _inputs.putIfAbsent(
        input,
        () => FFMpegStream(
              videoId: null,
              audioId: '[${_inputs.length}]',
            ));
    return stream;
  }

  FFMpegStream createStream({bool hasVideo = true, bool hasAudio = true}) {
    final stream = FFMpegStream(
      videoId: hasVideo ? '[comp_${_compositionStreamCount}_v]' : null,
      audioId: hasAudio ? '[comp_${_compositionStreamCount}_a]' : null,
    );

    _compositionStreamCount += 1;

    return stream;
  }

  void addFilterChain(FilterChain chain) {
    _filterChains.add(chain);
  }

  /// Accumulates all the input assets and filter chains in this builder
  /// and returns an [FFMpegCommand] that generates a corresponding video,
  /// which is rendered to the given [outputFilepath].
  ///
  /// To run the command, see [FFMpegCommand].
  FFMpegCommand build({
    required List<CliArguments> args,
    FFMpegStream? mainOutStream,
    required String outputFilepath,
  }) {
    ffmpegBuilderLog.info('Building command. Filter chains:');
    for (final chain in _filterChains) {
      ffmpegBuilderLog.info(' - ${chain.toCli()}');
    }

    ffmpegBuilderLog.info('Filter chains: $_filterChains');
    return FFMpegCommand(
      inputs: _inputs.keys.toList(),
      args: args,
      filterGraph: FilterGraph(
        chains: _filterChains,
      ),
      outputFilepath: outputFilepath,
    );
  }
}
