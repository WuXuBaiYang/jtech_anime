import 'package:logging/logging.dart';

class LogNames {
  static const ffmpegCommand = "ffmpeg.command";
  static const ffmpegBuilder = "ffmpeg.command.builder";
  static const ffmpegFilter = "ffmpeg.filter";
}

final ffmpegCommandLog = Logger(LogNames.ffmpegCommand);
final ffmpegBuilderLog = Logger(LogNames.ffmpegBuilder);
final ffmpegFilter = Logger(LogNames.ffmpegFilter);

final _activeLoggers = <Logger>{};

void initAllLoggers(Level level) {
  initLoggers(level, {Logger.root});
}

void initLoggers(Level level, Set<Logger> loggers) {
  hierarchicalLoggingEnabled = true;

  for (final logger in loggers) {
    if (!_activeLoggers.contains(logger)) {
      // ignore: avoid_print
      print("Initializing logger: ${logger.name}");

      logger
        ..level = level
        ..onRecord.listen(printLog);

      _activeLoggers.add(logger);
    }
  }
}

void deactivateLoggers(Set<Logger> loggers) {
  for (final logger in loggers) {
    if (_activeLoggers.contains(logger)) {
      // ignore: avoid_print
      print("Deactivating logger: ${logger.name}");
      logger.clearListeners();

      _activeLoggers.remove(logger);
    }
  }
}

void printLog(record) {
  // ignore: avoid_print
  print("${record.level.name}: ${record.time}: ${record.message}");
}
