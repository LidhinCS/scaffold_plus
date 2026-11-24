import 'package:material_ui/material_ui.dart';

/// Theme-aware [RefreshIndicator] with optional error handling.
///
/// Prefer this when you want Material 3 color defaults and a chance to handle
/// refresh failures without leaving the spinner stuck or crashing the zone.
///
/// {@tool snippet}
/// ```dart
/// PlusRefreshIndicator(
///   onRefresh: reload,
///   onError: (error, stack) {
///     PlusSnackbar.error(context: context, message: 'Refresh failed');
///   },
///   child: ListView(...),
/// )
/// ```
/// {@end-tool}
class PlusRefreshIndicator extends StatelessWidget {
  /// Creates a pull-to-refresh wrapper.
  ///
  /// When [onError] is provided, errors from [onRefresh] are caught, forwarded
  /// to [onError], and the indicator is dismissed. When [onError] is null,
  /// errors are rethrown (Flutter's default behavior).
  const new({
    required this.onRefresh,
    required this.child,
    super.key,
    this.onError,
    this.color,
    this.backgroundColor,
    this.displacement = 40,
    this.edgeOffset = 0,
    this.strokeWidth = RefreshProgressIndicator.defaultStrokeWidth,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.elevation = 2.0,
  });

  /// Invoked when the user pulls to refresh. Must complete to dismiss the
  /// indicator.
  final Future<void> Function() onRefresh;

  /// Scrollable content that triggers refresh.
  final Widget child;

  /// Optional error handler. When set, [onRefresh] errors are caught and the
  /// indicator still dismisses.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Indicator color. Defaults to [ColorScheme.primary].
  final Color? color;

  /// Indicator background color.
  final Color? backgroundColor;

  /// Distance from the child's top before the indicator appears.
  final double displacement;

  /// Offset from where the indicator starts relative to the top.
  final double edgeOffset;

  /// Progress indicator stroke width.
  final double strokeWidth;

  /// When the indicator should start.
  final RefreshIndicatorTriggerMode triggerMode;

  /// Which scroll notifications should trigger refresh.
  final ScrollNotificationPredicate notificationPredicate;

  /// Semantics label for the indicator.
  final String? semanticsLabel;

  /// Semantics value for the indicator.
  final String? semanticsValue;

  /// Material elevation of the indicator.
  final double elevation;

  Future<void> _handleRefresh() async {
    try {
      await onRefresh();
    } catch (error, stackTrace) {
      final handler = onError;
      if (handler != null) {
        handler(error, stackTrace);
        return;
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: color ?? colorScheme.primary,
      backgroundColor: backgroundColor,
      displacement: displacement,
      edgeOffset: edgeOffset,
      strokeWidth: strokeWidth,
      triggerMode: triggerMode,
      notificationPredicate: notificationPredicate,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
      elevation: elevation,
      child: child,
    );
  }
}
