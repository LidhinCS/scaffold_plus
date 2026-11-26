import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/src/dialogs/plus_dialog.dart';
import 'package:ui_plus/src/feedback/plus_snackbar.dart';

/// Maps operation outcomes to [PlusSnackbar] / [PlusDialog].
///
/// Use after an async action (save, delete, load) so call sites do not repeat
/// success/error snackbar wiring. Soft failures use a snackbar; set
/// `blocking` / `blockingErrors` to require acknowledgment via [PlusDialog].
///
/// Snackbars work with or without [BuildContext] when `PlusToastHost` is wired.
/// Blocking dialogs always need a [BuildContext].
///
/// ```dart
/// await PlusFeedback.run(
///   context: context,
///   action: () => repository.save(item),
///   successMessage: 'Saved',
/// );
///
/// PlusFeedback.result(
///   error: failure,
///   successMessage: 'Done',
///   mapError: (e) => 'Could not save: $e',
/// );
/// ```
abstract final class PlusFeedback {
  /// Shows a success snackbar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> success({
    required String message,
    BuildContext? context,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    bool showIcon = true,
  }) {
    return PlusSnackbar.success(
      context: context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      showIcon: showIcon,
    );
  }

  /// Shows failure feedback for [error].
  ///
  /// When [blocking] is false (default), uses [PlusSnackbar.error].
  /// When [blocking] is true, shows [PlusDialog.alert] (requires [context]).
  static Future<void> failure({
    required Object error,
    BuildContext? context,
    String? message,
    bool blocking = false,
    String title = 'Something went wrong',
    String primaryLabel = 'OK',
    Duration? duration,
    bool showIcon = true,
  }) async {
    final text = message ?? messageFor(error);
    if (blocking) {
      assert(
        context != null,
        'PlusFeedback.failure(blocking: true) requires a BuildContext.',
      );
      await PlusDialog.alert(
        context!,
        title: title,
        message: text,
        primaryLabel: primaryLabel,
        icon: Icons.error_rounded,
        showIcon: showIcon,
      );
      return;
    }

    PlusSnackbar.error(
      context: context,
      message: text,
      duration: duration,
      showIcon: showIcon,
    );
  }

  /// Same as [failure] — convenient when the value is typed as [Exception].
  static Future<void> exception({
    required Object error,
    BuildContext? context,
    String? message,
    bool blocking = false,
    String title = 'Something went wrong',
    String primaryLabel = 'OK',
    Duration? duration,
    bool showIcon = true,
  }) {
    return failure(
      error: error,
      context: context,
      message: message,
      blocking: blocking,
      title: title,
      primaryLabel: primaryLabel,
      duration: duration,
      showIcon: showIcon,
    );
  }

  /// Reports a completed operation: snackbar on success, failure path on error.
  ///
  /// When [error] is non-null, shows failure feedback and ignores
  /// [successMessage]. When [error] is null and [successMessage] is set, shows
  /// a success snackbar. When both are absent, this is a no-op.
  static Future<void> result({
    BuildContext? context,
    Object? error,
    String? successMessage,
    String Function(Object error)? mapError,
    bool blocking = false,
    String failureTitle = 'Something went wrong',
    Duration? duration,
    bool showIcon = true,
  }) async {
    if (error != null) {
      await failure(
        error: error,
        context: context,
        message: mapError?.call(error),
        blocking: blocking,
        title: failureTitle,
        duration: duration,
        showIcon: showIcon,
      );
      return;
    }

    if (successMessage != null && successMessage.isNotEmpty) {
      success(
        context: context,
        message: successMessage,
        duration: duration,
        showIcon: showIcon,
      );
    }
  }

  /// Runs [action] and reports success or failure feedback.
  ///
  /// On success, shows [successMessage] when non-null/non-empty.
  /// On error, shows failure feedback (snackbar or blocking dialog), then
  /// returns `null` unless [rethrowError] is true.
  static Future<T?> run<T>({
    required Future<T> Function() action,
    BuildContext? context,
    String? successMessage,
    String Function(Object error)? mapError,
    bool blockingErrors = false,
    String failureTitle = 'Something went wrong',
    bool rethrowError = false,
    void Function(Object error, StackTrace stackTrace)? onError,
    Duration? duration,
    bool showIcon = true,
  }) async {
    final ctx = context;
    try {
      final value = await action();
      if (successMessage != null && successMessage.isNotEmpty) {
        if (ctx != null && ctx.mounted) {
          success(
            context: ctx,
            message: successMessage,
            duration: duration,
            showIcon: showIcon,
          );
        } else {
          success(
            message: successMessage,
            duration: duration,
            showIcon: showIcon,
          );
        }
      }
      return value;
    } on Object catch (error, stackTrace) {
      final mounted = ctx != null && ctx.mounted;
      await failure(
        error: error,
        context: mounted ? ctx : null,
        message: mapError?.call(error),
        // Blocking needs a mounted context; otherwise fall back to snackbar.
        blocking: blockingErrors && mounted,
        title: failureTitle,
        duration: duration,
        showIcon: showIcon,
      );
      onError?.call(error, stackTrace);
      if (rethrowError) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      return null;
    }
  }

  /// Default human-readable message for [error].
  static String messageFor(Object error) {
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }
    final text = error.toString().trim();
    if (text.isEmpty) {
      return 'Something went wrong';
    }
    // Strip common "Exception: " / "Error: " prefixes for snackbar copy.
    final match = RegExp(r'^(?:Exception|Error):\s*(.+)$').firstMatch(text);
    return match?.group(1) ?? text;
  }
}
