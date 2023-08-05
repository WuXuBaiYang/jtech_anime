import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

class TrimArgument implements CliArguments {
  /// Trim video
  final Duration start;
  final Duration end;
  const TrimArgument({
    required this.start,
    required this.end,
  });

  @override
  List<String> toArgs() {
    return ['-ss', '$start', '-to', '$end'];
  }
}
