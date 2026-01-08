// lib/core/utils/performance_monitor.dart
// Performance monitoring utilities cho debug và optimization

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Performance monitoring class
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _stopwatches = {};
  final Map<String, List<Duration>> _measurements = {};
  final Map<String, int> _counters = {};

  /// Start timing an operation
  void startTiming(String operationName) {
    if (!kDebugMode) return;
    
    _stopwatches[operationName] = Stopwatch()..start();
  }

  /// End timing an operation
  void endTiming(String operationName) {
    if (!kDebugMode) return;
    
    final stopwatch = _stopwatches[operationName];
    if (stopwatch != null) {
      stopwatch.stop();
      
      final duration = stopwatch.elapsed;
      _measurements.putIfAbsent(operationName, () => []).add(duration);
      
      if (duration.inMilliseconds > 100) {
        developer.log(
          'PERFORMANCE WARNING: $operationName took ${duration.inMilliseconds}ms',
          name: 'PerformanceMonitor',
        );
      }
      
      _stopwatches.remove(operationName);
    }
  }

  /// Time a function execution
  T time<T>(String operationName, T Function() operation) {
    if (!kDebugMode) return operation();
    
    startTiming(operationName);
    try {
      return operation();
    } finally {
      endTiming(operationName);
    }
  }

  /// Time an async function execution
  Future<T> timeAsync<T>(String operationName, Future<T> Function() operation) async {
    if (!kDebugMode) return operation();
    
    startTiming(operationName);
    try {
      return await operation();
    } finally {
      endTiming(operationName);
    }
  }

  /// Increment a counter
  void incrementCounter(String counterName) {
    if (!kDebugMode) return;
    _counters[counterName] = (_counters[counterName] ?? 0) + 1;
  }

  /// Get average time for an operation
  Duration? getAverageTime(String operationName) {
    final measurements = _measurements[operationName];
    if (measurements == null || measurements.isEmpty) return null;
    
    final totalMs = measurements.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    
    return Duration(milliseconds: totalMs ~/ measurements.length);
  }

  /// Get performance report
  String getPerformanceReport() {
    if (!kDebugMode) return 'Performance monitoring disabled in release mode';
    
    final buffer = StringBuffer();
    buffer.writeln('=== PERFORMANCE REPORT ===');
    
    // Timing measurements
    if (_measurements.isNotEmpty) {
      buffer.writeln('\nTiming Measurements:');
      _measurements.forEach((operation, measurements) {
        final avg = getAverageTime(operation);
        final max = measurements.reduce((a, b) => a > b ? a : b);
        final min = measurements.reduce((a, b) => a < b ? a : b);
        
        buffer.writeln(
          '$operation: avg=${avg?.inMilliseconds}ms, '
          'min=${min.inMilliseconds}ms, '
          'max=${max.inMilliseconds}ms, '
          'count=${measurements.length}',
        );
      });
    }
    
    // Counters
    if (_counters.isNotEmpty) {
      buffer.writeln('\nCounters:');
      _counters.forEach((name, count) {
        buffer.writeln('$name: $count');
      });
    }
    
    return buffer.toString();
  }

  /// Clear all measurements
  void clear() {
    _stopwatches.clear();
    _measurements.clear();
    _counters.clear();
  }

  /// Print performance report
  void printReport() {
    if (kDebugMode) {
      developer.log(getPerformanceReport(), name: 'PerformanceMonitor');
    }
  }
}

/// Widget để monitor widget build performance
class PerformanceWidget extends StatefulWidget {
  final String name;
  final Widget child;
  final bool enabled;

  const PerformanceWidget({
    super.key,
    required this.name,
    required this.child,
    this.enabled = kDebugMode,
  });

  @override
  State<PerformanceWidget> createState() => _PerformanceWidgetState();
}

class _PerformanceWidgetState extends State<PerformanceWidget> {
  final _monitor = PerformanceMonitor();
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    
    _buildCount++;
    final operationName = '${widget.name}_build';
    
    return _monitor.time(operationName, () {
      _monitor.incrementCounter('${widget.name}_builds');
      
      if (_buildCount > 10) {
        developer.log(
          'Widget ${widget.name} has been rebuilt $_buildCount times',
          name: 'PerformanceWidget',
        );
      }
      
      return widget.child;
    });
  }
}

/// Mixin để automatically monitor widget performance
mixin PerformanceMixin<T extends StatefulWidget> on State<T> {
  final _monitor = PerformanceMonitor();
  late final String _widgetName;
  int _buildCount = 0;
  
  @override
  void initState() {
    super.initState();
    _widgetName = widget.runtimeType.toString();
    _monitor.startTiming('${_widgetName}_init');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _monitor.incrementCounter('${_widgetName}_dependencies_changed');
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      _buildCount++;
      _monitor.incrementCounter('${_widgetName}_builds');
      
      if (_buildCount > 20) {
        developer.log(
          'Widget $_widgetName has been rebuilt $_buildCount times - consider optimization',
          name: 'PerformanceMixin',
        );
      }
    }
    
    return buildWithPerformanceTracking(context);
  }

  /// Override this method instead of build()
  Widget buildWithPerformanceTracking(BuildContext context);

  @override
  void dispose() {
    _monitor.endTiming('${_widgetName}_init');
    super.dispose();
  }
}

/// Network performance monitoring
class NetworkPerformanceMonitor {
  static final NetworkPerformanceMonitor _instance = NetworkPerformanceMonitor._internal();
  factory NetworkPerformanceMonitor() => _instance;
  NetworkPerformanceMonitor._internal();

  final Map<String, Stopwatch> _requests = {};

  void startRequest(String requestId, String url) {
    if (!kDebugMode) return;
    
    _requests[requestId] = Stopwatch()..start();
    developer.log('Starting request: $url', name: 'NetworkMonitor');
  }

  void endRequest(String requestId, String url, {int? statusCode, String? error}) {
    if (!kDebugMode) return;
    
    final stopwatch = _requests[requestId];
    if (stopwatch != null) {
      stopwatch.stop();
      final duration = stopwatch.elapsed;
      
      String message = 'Request completed: $url in ${duration.inMilliseconds}ms';
      if (statusCode != null) message += ' (status: $statusCode)';
      if (error != null) message += ' (error: $error)';
      
      if (duration.inSeconds > 5) {
        developer.log('SLOW REQUEST: $message', name: 'NetworkMonitor');
      } else {
        developer.log(message, name: 'NetworkMonitor');
      }
      
      _requests.remove(requestId);
    }
  }
}

/// Memory monitoring utilities
class MemoryMonitor {
  static final MemoryMonitor _instance = MemoryMonitor._internal();
  factory MemoryMonitor() => _instance;
  MemoryMonitor._internal();

  Timer? _monitoringTimer;
  final List<int> _memorySnapshots = [];

  void startMonitoring({Duration interval = const Duration(seconds: 10)}) {
    if (!kDebugMode) return;
    
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(interval, (_) {
      _takeMemorySnapshot();
    });
  }

  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  void _takeMemorySnapshot() {
    // Simplified memory monitoring
    final currentUsage = _getCurrentMemoryUsage();
    _memorySnapshots.add(currentUsage);
    
    if (_memorySnapshots.length > 100) {
      _memorySnapshots.removeAt(0);
    }
    
    if (currentUsage > 100) { // 100MB threshold
      developer.log(
        'High memory usage detected: ${currentUsage}MB',
        name: 'MemoryMonitor',
      );
    }
  }

  int _getCurrentMemoryUsage() {
    // This is a simplified implementation
    // In real apps, you'd use platform channels or other methods
    return DateTime.now().millisecond; // Mock value
  }

  void clearImageCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
    developer.log('Image cache cleared', name: 'MemoryMonitor');
  }

  String getMemoryReport() {
    if (_memorySnapshots.isEmpty) return 'No memory data available';
    
    final avg = _memorySnapshots.reduce((a, b) => a + b) / _memorySnapshots.length;
    final max = _memorySnapshots.reduce((a, b) => a > b ? a : b);
    
    return 'Memory Usage - Average: ${avg.toInt()}MB, Peak: ${max}MB';
  }
}
