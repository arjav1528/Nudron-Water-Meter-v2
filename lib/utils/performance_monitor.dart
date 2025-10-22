import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _measurements = {};
  
  static void startTimer(String operation) {
    if (kDebugMode) {
      _startTimes[operation] = DateTime.now();
    }
  }
  
  static void endTimer(String operation) {
    if (kDebugMode && _startTimes.containsKey(operation)) {
      final duration = DateTime.now().difference(_startTimes[operation]!);
      _measurements.putIfAbsent(operation, () => []).add(duration);
      _startTimes.remove(operation);
      
      // Log slow operations
      if (duration.inMilliseconds > 100) {
        developer.log('Performance: $operation took ${duration.inMilliseconds}ms');
      }
    }
  }
  
  static Duration? getAverageTime(String operation) {
    if (!_measurements.containsKey(operation) || _measurements[operation]!.isEmpty) {
      return null;
    }
    
    final measurements = _measurements[operation]!;
    final totalMs = measurements.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ measurements.length);
  }
  
  static void clearMeasurements() {
    _measurements.clear();
    _startTimes.clear();
  }
  
  static void logPerformanceSummary() {
    if (kDebugMode) {
      developer.log('=== Performance Summary ===');
      for (final operation in _measurements.keys) {
        final avgTime = getAverageTime(operation);
        final count = _measurements[operation]!.length;
        if (avgTime != null) {
          developer.log('$operation: ${avgTime.inMilliseconds}ms average ($count calls)');
        }
      }
    }
  }
}
