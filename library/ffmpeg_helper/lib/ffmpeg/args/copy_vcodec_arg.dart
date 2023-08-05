import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

class CopyVideoCodecArgument implements CliArguments {
  // Copy video codec
  const CopyVideoCodecArgument();

  @override
  List<String> toArgs() {
    return ['-c:v', 'copy'];
  }
}
