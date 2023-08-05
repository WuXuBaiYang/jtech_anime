import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

class VideoBitrateArgument implements CliArguments {
  /// Video bitrate in kbps , eg: 1000kbps
  final int bitrate;
  const VideoBitrateArgument(this.bitrate);

  @override
  List<String> toArgs() {
    return ['-b:v', '${bitrate}k'];
  }
}
