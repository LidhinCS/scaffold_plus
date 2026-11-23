import 'package:flutter/material.dart';
import 'package:ui_plus/src/theme/plus_theme.dart';

/// Visual tone for [PlusSnackbar] messages.
enum PlusSnackbarTone {
  /// Neutral / informational feedback.
  info,

  /// Positive confirmation.
  success,

  /// Failure or destructive feedback.
  error,
}

/// Theme-aware snackbar helpers built on [ScaffoldMessenger].
///
/// Prefer these helpers over ad-hoc [SnackBar] construction when you want
/// consistent success / info / error styling across an app.
///
/// {@tool snippet}
/// ```dart
/// PlusSnackbar.success(context, message: 'Saved');
/// PlusSnackbar.error(context, message: 'Could not save');
/// PlusSnackbar.show(
///   context,
///   message: 'Draft discarded',
///   actionLabel: 'Undo',
///   onAction: restoreDraft,
/// );
/// ```
/// {@end-tool}
abstract final class PlusSnackbar {
  /// Shows a snackbar with the given [message] and optional [tone].
  ///
  /// When [clearCurrent] is true (default), any visible snackbar is cleared
  /// first so messages do not queue.
  ///
  /// An action button is shown only when both [actionLabel] and [onAction]
  /// are non-null.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    PlusSnackbarTone tone = PlusSnackbarTone.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    bool clearCurrent = true,
    Color? backgroundColor,
    Color? foregroundColor,
    TextStyle? textStyle,
    double? elevation,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? width,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    if (clearCurrent) {
      messenger.clearSnackBars();
    }

    final colors = _resolveColors(context, tone);
    final resolvedBackground = backgroundColor ?? colors.background;
    final resolvedForeground = foregroundColor ?? colors.foreground;
    final resolvedTextStyle =
        textStyle ??
        Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: resolvedForeground);
    final resolvedDuration = duration ?? PlusTheme.of(context).snackbarDuration;

    final showAction = actionLabel != null && onAction != null;

    return messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: resolvedTextStyle),
        duration: resolvedDuration,
        behavior: behavior,
        backgroundColor: resolvedBackground,
        elevation: elevation,
        shape: shape,
        margin: margin,
        padding: padding,
        width: width,
        action: showAction
            ? SnackBarAction(
                label: actionLabel,
                textColor: resolvedForeground,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Shows an informational snackbar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> info(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    bool clearCurrent = true,
  }) {
    return show(
      context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      behavior: behavior,
      clearCurrent: clearCurrent,
    );
  }

  /// Shows a success snackbar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> success(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    bool clearCurrent = true,
  }) {
    return show(
      context,
      message: message,
      tone: PlusSnackbarTone.success,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      behavior: behavior,
      clearCurrent: clearCurrent,
    );
  }

  /// Shows an error snackbar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> error(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    bool clearCurrent = true,
  }) {
    return show(
      context,
      message: message,
      tone: PlusSnackbarTone.error,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      behavior: behavior,
      clearCurrent: clearCurrent,
    );
  }

  /// Dismisses the current snackbar, if any.
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Clears all queued and visible snackbars for the nearest messenger.
  static void clear(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  static ({Color background, Color foreground}) _resolveColors(
    BuildContext context,
    PlusSnackbarTone tone,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (tone) {
      PlusSnackbarTone.info => (
        background: colorScheme.inverseSurface,
        foreground: colorScheme.onInverseSurface,
      ),
      PlusSnackbarTone.success => (
        background: colorScheme.primaryContainer,
        foreground: colorScheme.onPrimaryContainer,
      ),
      PlusSnackbarTone.error => (
        background: colorScheme.errorContainer,
        foreground: colorScheme.onErrorContainer,
      ),
    };
  }
}
