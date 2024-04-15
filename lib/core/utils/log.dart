import 'package:logger/logger.dart';

class Log {
  Log._privateConstructor();

  static var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 20, // number of method calls if stacktrace is provided
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true, // Should each log print contain a timestamp
    ),
  );

  static void v(String tag, dynamic message) {
    logger.v(formatTag(tag) + message);
  }

  static void d(String tag, dynamic message) {
    logger.d(formatTag(tag) + message);
  }

  static void i(String tag, dynamic message) {
    logger.i(formatTag(tag) + message);
  }

  static void w(String tag, dynamic message) {
    logger.w(formatTag(tag) + message);
  }

  static void e(String tag, dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(formatTag(tag) + message, error: error, stackTrace: stackTrace);
  }

  static String formatTag(String tag) {
    var _tag = '';
    if (tag.isNotEmpty) {
      _tag = '[$tag]:';
    }
    return _tag;
  }
}
