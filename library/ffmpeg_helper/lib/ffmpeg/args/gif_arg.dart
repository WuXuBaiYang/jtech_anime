import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

class GifArgument implements CliArguments {
  /// Convert to gif, use in conjunction with fps=10
  const GifArgument();

  @override
  List<String> toArgs() {
    return ['-loop', '0'];
  }
}
