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
  ///
  /// When [showIcon] is true (default), a tone icon appears beside the message.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    PlusSnackbarTone tone = PlusSnackbarTone.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    bool clearCurrent = true,
    bool showIcon = true,
    IconData? icon,
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

    final theme = Theme.of(context);
    final colors = _resolveColors(context, tone);
    final resolvedBackground = backgroundColor ?? colors.background;
    final resolvedForeground = foregroundColor ?? colors.foreground;
    final resolvedTextStyle =
        textStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: resolvedForeground,
          fontWeight: FontWeight.w500,
          height: 1.35,
        );
    final resolvedDuration = duration ?? PlusTheme.of(context).snackbarDuration;
    final resolvedIcon = icon ?? _iconForTone(tone);
    final showAction = actionLabel != null && onAction != null;

    return messenger.showSnackBar(
      SnackBar(
        content: _PlusSnackbarBody(
          message: message,
          textStyle: resolvedTextStyle,
          foreground: resolvedForeground,
          iconBackground: colors.iconBackground,
          showIcon: showIcon,
          icon: resolvedIcon,
        ),
        duration: resolvedDuration,
        behavior: behavior,
        backgroundColor: resolvedBackground,
        elevation: elevation ?? 6,
        shape:
            shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        width: width,
        dismissDirection: DismissDirection.down,
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
    bool showIcon = true,
  }) {
    return show(
      context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      behavior: behavior,
      clearCurrent: clearCurrent,
      showIcon: showIcon,
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
    bool showIcon = true,
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
      showIcon: showIcon,
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
    bool showIcon = true,
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
      showIcon: showIcon,
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

  static IconData _iconForTone(PlusSnackbarTone tone) {
    return switch (tone) {
      PlusSnackbarTone.info => Icons.info_rounded,
      PlusSnackbarTone.success => Icons.check_circle_rounded,
      PlusSnackbarTone.error => Icons.error_rounded,
    };
  }

  static ({Color background, Color foreground, Color iconBackground})
  _resolveColors(BuildContext context, PlusSnackbarTone tone) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (tone) {
      PlusSnackbarTone.info => (
        background: colorScheme.inverseSurface,
        foreground: colorScheme.onInverseSurface,
        iconBackground: colorScheme.onInverseSurface.withValues(alpha: 0.14),
      ),
      PlusSnackbarTone.success => (
        background: colorScheme.primaryContainer,
        foreground: colorScheme.onPrimaryContainer,
        iconBackground: colorScheme.primary.withValues(alpha: 0.16),
      ),
      PlusSnackbarTone.error => (
        background: colorScheme.errorContainer,
        foreground: colorScheme.onErrorContainer,
        iconBackground: colorScheme.error.withValues(alpha: 0.16),
      ),
    };
  }
}

class _PlusSnackbarBody extends StatefulWidget {
  const new({
    required this.message,
    required this.foreground,
    required this.iconBackground,
    required this.showIcon,
    required this.icon,
    this.textStyle,
  });

  final String message;
  final TextStyle? textStyle;
  final Color foreground;
  final Color iconBackground;
  final bool showIcon;
  final IconData icon;

  @override
  State<_PlusSnackbarBody> createState() => _PlusSnackbarBodyState();
}

class _PlusSnackbarBodyState extends State<_PlusSnackbarBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.showIcon) ...[
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(widget.icon, size: 20, color: widget.foreground),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(child: Text(widget.message, style: widget.textStyle)),
      ],
    );
  }
}
