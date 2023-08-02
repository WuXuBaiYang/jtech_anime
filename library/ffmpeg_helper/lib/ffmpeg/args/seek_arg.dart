import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

/// Audio bitrate in kbps , eg: 1000kbps
class SeekArgument implements CliArguments {
  final Duration seekTo;

  const SeekArgument(this.seekTo);

  @override
  List<String> toArgs() {
    return ['-ss', '$seekTo'];
  }
}
