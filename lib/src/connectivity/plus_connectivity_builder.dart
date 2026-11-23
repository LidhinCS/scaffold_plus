import 'package:flutter/widgets.dart';

/// Conditionally builds online or offline UI from an explicit status.
///
/// Independent of `ScaffoldPlus`. Does not subscribe to streams — pass the
/// current [isConnected] value from the host.
///
/// {@tool snippet}
/// ```dart
/// PlusConnectivityBuilder(
///   isConnected: isConnected,
///   onlineBuilder: (context) => const HomePage(),
///   offlineBuilder: (context) => const PlusOfflineState(),
/// )
/// ```
/// {@end-tool}
class PlusConnectivityBuilder extends StatelessWidget {
  /// Creates a connectivity-aware builder switch.
  const new({
    required this.isConnected,
    required this.onlineBuilder,
    required this.offlineBuilder,
    super.key,
  });

  /// Current reachability / connectivity status supplied by the app.
  final bool isConnected;

  /// Built when [isConnected] is true.
  final WidgetBuilder onlineBuilder;

  /// Built when [isConnected] is false.
  final WidgetBuilder offlineBuilder;

  @override
  Widget build(BuildContext context) {
    return isConnected ? onlineBuilder(context) : offlineBuilder(context);
  }
}
