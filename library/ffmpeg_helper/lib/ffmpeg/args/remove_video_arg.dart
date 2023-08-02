import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

class RemoveVideoArgument implements CliArguments {
  /// Remove audio track
  const RemoveVideoArgument();

  @override
  List<String> toArgs() {
    return ['-vn'];
  }
}
