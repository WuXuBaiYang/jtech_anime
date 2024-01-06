import 'package:logger/logger.dart';

/*
* 日志工具方法
* @author wuxubaiyang
* @Time 2022/3/17 16:26
*/
class LogTool {
  // 日期方法
  static Logger? _logger;

  // 输出verbose日志
  static void v(
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    return _output(
      level: Level.trace,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // 输出debug日志
  static void d(
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    return _output(
      level: Level.debug,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // 输出info日志
  static void i(
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    return _output(
      level: Level.info,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // 输出warning日志
  static void w(
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    return _output(
      level: Level.warning,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // 输出error日志
  static void e(
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    return _output(
      level: Level.error,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // 输出wtf日志
  static void wtf(
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    return _output(
      level: Level.fatal,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // 输出日志
  static void _output({
    required Level level,
    String? message,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    return (_logger ??= Logger()).log(
      level,
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
