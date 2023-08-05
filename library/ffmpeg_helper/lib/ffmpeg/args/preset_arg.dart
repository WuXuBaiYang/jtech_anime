import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

class PresetArgument implements CliArguments {
  /// A preset is a collection of options that will provide a certain encoding speed to compression ratio.
  ///
  /// A slower preset will provide better compression (compression is quality per filesize).
  ///
  /// This means that, for example, if you target a certain file size or constant bit rate, you will achieve better quality with a slower preset. Similarly, for constant quality encoding, you will simply save bitrate by choosing a slower preset.
  ///
  /// Use the slowest preset that you have patience for. The available presets in descending order of speed are:
  ///
  /// ultrafast,superfast,veryfast,faster,fast,medium (default preset),slow,slower,veryslow
  final EncodingPresets preset;
  const PresetArgument(this.preset);

  @override
  List<String> toArgs() {
    return ['-preset', preset.name];
  }
}

enum EncodingPresets {
  ultrafast,
  superfast,
  veryfast,
  faster,
  fast,
  medium,
  slow,
  slower,
  veryslow
}
