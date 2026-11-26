import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/src/states/plus_error_state.dart';

/// Builds a presentable widget for a framework [FlutterErrorDetails] report.
typedef PlusErrorBoundaryBuilder = Widget Function(
  BuildContext context,
  FlutterErrorDetails details,
);

/// Replaces Flutter’s red/grey [ErrorWidget] with a presentable layout.
///
/// Call [install] once during app startup (typically in `main` before
/// `runApp`). This only affects errors that surface as an [ErrorWidget]
/// (build / layout / paint failures in the tree). It does not catch every
/// async or isolate failure — pair with `FlutterError.onError` in the app if
/// you need reporting.
///
/// ```dart
/// void main() {
///   PlusErrorBoundary.install();
///   runApp(const MyApp());
/// }
/// ```
///
/// Presentation only — no logging or crash-reporting dependencies.
abstract final class PlusErrorBoundary {
  static ErrorWidgetBuilder? _previous;
  static var _installed = false;

  /// Whether [install] is currently active.
  static bool get isInstalled => _installed;

  /// Installs a global [ErrorWidget.builder].
  ///
  /// When [builder] is null, uses [PlusErrorBoundaryView] (friendly copy in
  /// release; exception text in debug when [showDebugDetails] is true).
  static void install({
    PlusErrorBoundaryBuilder? builder,
    bool showDebugDetails = true,
    String title = 'Something went wrong',
    String releaseMessage = 'Please try again in a moment.',
  }) {
    if (!_installed) {
      _previous = ErrorWidget.builder;
      _installed = true;
    }

    ErrorWidget.builder = (details) {
      return _PlusErrorBoundaryHost(
        details: details,
        builder: builder,
        showDebugDetails: showDebugDetails,
        title: title,
        releaseMessage: releaseMessage,
      );
    };
  }

  /// Restores the previous [ErrorWidget.builder] (for tests / hot-restart).
  static void uninstall() {
    if (!_installed) {
      return;
    }
    ErrorWidget.builder = _previous ?? ErrorWidget.builder;
    _previous = null;
    _installed = false;
  }
}

/// Default presentable UI used by [PlusErrorBoundary.install].
///
/// Can also be used manually if you supply a custom [PlusErrorBoundaryBuilder].
class PlusErrorBoundaryView extends StatelessWidget {
  /// Creates the default error-boundary presentation.
  const new({
    required this.details,
    super.key,
    this.showDebugDetails = true,
    this.title = 'Something went wrong',
    this.releaseMessage = 'Please try again in a moment.',
    this.onRetry,
    this.actionLabel,
  });

  /// Framework error details for the failed widget.
  final FlutterErrorDetails details;

  /// When true (default), debug/profile builds include exception text.
  final bool showDebugDetails;

  /// Heading shown above the message.
  final String title;

  /// Message used when debug details are hidden.
  final String releaseMessage;

  /// Optional retry action (only shown with [actionLabel]).
  final VoidCallback? onRetry;

  /// Optional retry button label.
  final String? actionLabel;

  String get _message {
    final showDetails = showDebugDetails && !kReleaseMode;
    if (!showDetails) {
      return releaseMessage;
    }
    final exception = details.exceptionAsString().trim();
    if (exception.isEmpty) {
      return releaseMessage;
    }
    return exception;
  }

  @override
  Widget build(BuildContext context) {
    return PlusErrorState(
      title: title,
      message: _message,
      actionLabel: actionLabel,
      onRetry: onRetry,
    );
  }
}

/// Ensures [Theme] / [Material] / [Directionality] exist when the failing
/// widget is high in the tree.
class _PlusErrorBoundaryHost extends StatelessWidget {
  const new({
    required this.details,
    required this.showDebugDetails,
    required this.title,
    required this.releaseMessage,
    this.builder,
  });

  final FlutterErrorDetails details;
  final PlusErrorBoundaryBuilder? builder;
  final bool showDebugDetails;
  final String title;
  final String releaseMessage;

  @override
  Widget build(BuildContext context) {
    Widget child = Builder(
      builder: (context) {
        if (builder != null) {
          return builder!(context, details);
        }
        return PlusErrorBoundaryView(
          details: details,
          showDebugDetails: showDebugDetails,
          title: title,
          releaseMessage: releaseMessage,
        );
      },
    );

    if (Directionality.maybeOf(context) == null) {
      child = Directionality(textDirection: TextDirection.ltr, child: child);
    }
    // material_ui Theme/Material have no maybeOf — detect via ancestors.
    if (context.findAncestorWidgetOfExactType<Theme>() == null &&
        context.findAncestorWidgetOfExactType<MaterialApp>() == null) {
      child = Theme(data: ThemeData(useMaterial3: true), child: child);
    }
    if (context.findAncestorWidgetOfExactType<Material>() == null) {
      child = Material(type: MaterialType.transparency, child: child);
    }

    return child;
  }
}
