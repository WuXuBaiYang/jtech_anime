import '../../abstract_classes/ffmpeg_arguments_abstract.dart';

class LogLevelArgument implements CliArguments {
  final LogLevel level;
  const LogLevelArgument(this.level);

  @override
  List<String> toArgs() {
    return ['-loglevel', level.name];
  }
}

enum LogLevel {
  quiet,
  panic,
  fatal,
  error,
  warning,
  info,
  verbose,
  debug,
  trace,
}
