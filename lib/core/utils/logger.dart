import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String message) {
    if (kDebugMode) debugPrint('💡 $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ $message');
      if (error != null) debugPrint('   Error: $error');
      if (stackTrace != null) debugPrint('   $stackTrace');
    }
  }

  static void debug(String message) {
    if (kDebugMode) debugPrint('🔍 $message');
  }

  static void network(String method, String path, {int? statusCode, String? body}) {
    if (kDebugMode) {
      final status = statusCode != null ? ' [$statusCode]' : '';
      debugPrint('🌐 $method $path$status');
      if (body != null && body.length < 500) debugPrint('   $body');
    }
  }
}
