import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

/// Audio bitrate in kbps , eg: 1000kbps
class AudioBitrateArgument implements CliArguments {
  final int bitrate;

  const AudioBitrateArgument(this.bitrate);

  @override
  List<String> toArgs() {
    return ['-b:a', '${bitrate}k'];
  }
}
