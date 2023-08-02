import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

/// Video bitrate in kbps , eg: 1000kbps
class OverwriteArgument implements CliArguments {
  const OverwriteArgument();

  @override
  List<String> toArgs() {
    return ['-y'];
  }
}
