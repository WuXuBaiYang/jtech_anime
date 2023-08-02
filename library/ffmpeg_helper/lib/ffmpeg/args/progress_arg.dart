import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

class ProgressArgument implements CliArguments {
  const ProgressArgument();

  @override
  List<String> toArgs() {
    return ['-progress', '-'];
  }
}
