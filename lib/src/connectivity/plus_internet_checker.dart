import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ui_plus/src/connectivity/plus_internet_probe.dart';

/// Performs a single reachability probe.
///
/// Injectable for tests. The default implementation is platform-specific and
/// does **not** require a connectivity plugin.
typedef PlusInternetProbeFn = Future<bool> Function({
  required List<Uri> endpoints,
  required Duration timeout,
});

/// Configuration for [PlusInternetChecker].
@immutable
class PlusInternetCheckerConfig {
  /// Creates internet-check configuration.
  const new({
    this.endpoints = const [
      'https://www.gstatic.com/generate_204',
      'https://connectivitycheck.gstatic.com/generate_204',
    ],
    this.interval = const Duration(seconds: 5),
    this.timeout = const Duration(seconds: 3),
    this.checkOnStart = true,
  });

  /// Probe URLs tried in order until one succeeds.
  final List<String> endpoints;

  /// How often to re-check while the checker is running.
  final Duration interval;

  /// Per-request timeout.
  final Duration timeout;

  /// Whether to run an immediate check when [PlusInternetChecker.start] runs.
  final bool checkOnStart;

  /// Parsed endpoint URIs.
  List<Uri> get endpointUris => [
    for (final endpoint in endpoints) Uri.parse(endpoint),
  ];

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlusInternetCheckerConfig &&
            runtimeType == other.runtimeType &&
            interval == other.interval &&
            timeout == other.timeout &&
            checkOnStart == other.checkOnStart &&
            _listEquals(endpoints, other.endpoints);
  }

  @override
  int get hashCode =>
      Object.hash(interval, timeout, checkOnStart, Object.hashAll(endpoints));
}

bool _listEquals(List<String> a, List<String> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

/// Plugin-free internet reachability checker.
///
/// Emits `true` / `false` on [onStatusChange]. On IO platforms this uses a
/// lightweight HTTP probe; on web it uses the browser online signal.
///
/// {@tool snippet}
/// ```dart
/// final checker = PlusInternetChecker()..start();
/// ScaffoldPlus(
///   connectivityBanner: true,
///   connectivityStream: checker.onStatusChange,
///   isConnected: checker.isConnected,
///   body: child,
/// );
/// ```
/// {@end-tool}
///
/// Prefer supplying your own stream when you already have a reachability
/// source — custom values always win over the built-in checker in
/// `ScaffoldPlus` / `PlusConnectivityOverlay`.
class PlusInternetChecker {
  /// Creates a checker.
  ///
  /// [probe] overrides the platform default (useful in tests).
  new({
    this.config = const PlusInternetCheckerConfig(),
    PlusInternetProbeFn? probe,
  }) : _probe = probe ?? plusInternetProbe;

  /// Checker configuration.
  final PlusInternetCheckerConfig config;

  final PlusInternetProbeFn _probe;

  final _controller = StreamController<bool>.broadcast();
  Timer? _timer;
  bool? _isConnected;
  var _started = false;
  var _disposed = false;
  var _checking = false;

  /// Latest known status, or `null` before the first completed check.
  bool? get isConnected => _isConnected;

  /// Whether [start] has been called and not yet [stop]/[dispose]d.
  bool get isStarted => _started;

  /// Live status updates. Does not replay the current value to new listeners;
  /// read [isConnected] for the snapshot.
  Stream<bool> get onStatusChange => _controller.stream;

  /// Runs a single probe and updates listeners when the value changes.
  Future<bool> checkNow() async {
    if (_disposed) {
      return _isConnected ?? false;
    }
    if (_checking) {
      return _isConnected ?? false;
    }

    _checking = true;
    try {
      final result = await _probe(
        endpoints: config.endpointUris,
        timeout: config.timeout,
      );
      _emit(result);
      return result;
    } finally {
      _checking = false;
    }
  }

  /// Starts periodic probing.
  void start() {
    if (_disposed || _started) {
      return;
    }
    _started = true;
    if (config.checkOnStart) {
      unawaited(checkNow());
    }
    _timer = Timer.periodic(config.interval, (_) {
      unawaited(checkNow());
    });
  }

  /// Stops periodic probing. Keeps the last [isConnected] value.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _started = false;
  }

  /// Stops probing and closes [onStatusChange].
  void dispose() {
    stop();
    _disposed = true;
    unawaited(_controller.close());
  }

  void _emit(bool value) {
    if (_disposed) {
      return;
    }
    if (_isConnected == value) {
      return;
    }
    _isConnected = value;
    if (!_controller.isClosed) {
      _controller.add(value);
    }
  }
}
