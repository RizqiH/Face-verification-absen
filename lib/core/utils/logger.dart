import 'dart:developer' as developer;

/// Application logger
/// Replace all print() statements with this logger
/// Provides different log levels and better formatting
class AppLogger {
  static const String _name = 'FaceVerification';
  static bool _enabled = true;

  /// Enable or disable logging
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Debug level logging (verbose information)
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    
    developer.log(
      message,
      name: _name,
      level: 500,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Info level logging (general information)
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    
    developer.log(
      message,
      name: _name,
      level: 800,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Warning level logging (potential issues)
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    
    developer.log(
      message,
      name: _name,
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Error level logging (errors that need attention)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    
    developer.log(
      message,
      name: _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Fatal level logging (critical errors)
  static void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    // Always log fatal errors, even if logging is disabled
    developer.log(
      message,
      name: _name,
      level: 1200,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Network request logging
  static void network(String method, String url, {int? statusCode, Object? error}) {
    if (!_enabled) return;
    
    final message = statusCode != null
        ? '$method $url - Status: $statusCode'
        : '$method $url';
    
    if (error != null) {
      developer.log(
        message,
        name: '$_name.Network',
        level: 1000,
        error: error,
      );
    } else {
      developer.log(
        message,
        name: '$_name.Network',
        level: 800,
      );
    }
  }

  /// BLoC event logging
  static void blocEvent(String blocName, String eventName) {
    if (!_enabled) return;
    
    developer.log(
      'Event: $eventName',
      name: '$_name.BLoC.$blocName',
      level: 500,
    );
  }

  /// BLoC state logging
  static void blocState(String blocName, String stateName) {
    if (!_enabled) return;
    
    developer.log(
      'State: $stateName',
      name: '$_name.BLoC.$blocName',
      level: 500,
    );
  }

  /// Navigation logging
  static void navigation(String from, String to) {
    if (!_enabled) return;
    
    developer.log(
      'Navigate: $from → $to',
      name: '$_name.Navigation',
      level: 500,
    );
  }

  /// Performance timing logging
  static void performance(String operation, Duration duration) {
    if (!_enabled) return;
    
    developer.log(
      '$operation took ${duration.inMilliseconds}ms',
      name: '$_name.Performance',
      level: 500,
    );
  }
}

/// Stopwatch for performance measurement
class PerformanceTimer {
  final String operation;
  final Stopwatch _stopwatch = Stopwatch();

  PerformanceTimer(this.operation) {
    _stopwatch.start();
  }

  /// Stop the timer and log the duration
  void stop() {
    _stopwatch.stop();
    AppLogger.performance(operation, _stopwatch.elapsed);
  }
}

/// Extension for easier usage
extension LoggerString on String {
  void logDebug() => AppLogger.debug(this);
  void logInfo() => AppLogger.info(this);
  void logWarning() => AppLogger.warning(this);
  void logError([Object? error, StackTrace? stackTrace]) {
    AppLogger.error(this, error, stackTrace);
  }
}

