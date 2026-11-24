import 'package:material_ui/material_ui.dart';

/// Shared polished dialog chrome used by Plus dialog helpers.
class PlusDialogSurface extends StatelessWidget {
  /// Creates a dialog surface with optional leading icon badge.
  const new({
    required this.title,
    required this.actions,
    super.key,
    this.message,
    this.content,
    this.icon,
    this.iconBackgroundColor,
    this.iconColor,
    this.titleTextStyle,
    this.messageTextStyle,
    this.isDestructive = false,
  });

  /// Dialog title.
  final String title;

  /// Optional plain-text body.
  final String? message;

  /// Optional custom body (wins over [message]).
  final Widget? content;

  /// Optional leading icon shown in a soft badge.
  final IconData? icon;

  /// Badge background. Defaults from theme / destructive flag.
  final Color? iconBackgroundColor;

  /// Icon color. Defaults from theme / destructive flag.
  final Color? iconColor;

  /// Title style override.
  final TextStyle? titleTextStyle;

  /// Message style override.
  final TextStyle? messageTextStyle;

  /// Whether to use error-tinted icon defaults.
  final bool isDestructive;

  /// Dialog actions.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedIconColor =
        iconColor ?? (isDestructive ? colorScheme.error : colorScheme.primary);
    final resolvedIconBackground =
        iconBackgroundColor ??
        (isDestructive
            ? colorScheme.error.withValues(alpha: 0.12)
            : colorScheme.primary.withValues(alpha: 0.12));

    final body =
        content ??
        (message == null || message!.isEmpty
            ? null
            : Text(
                message!,
                style:
                    messageTextStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ));

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 3,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.25),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      titlePadding: EdgeInsets.fromLTRB(24, icon == null ? 24 : 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: resolvedIconBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: resolvedIconColor, size: 28),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            style:
                titleTextStyle ??
                theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
          ),
        ],
      ),
      content: body,
      actions: actions,
    );
  }
}

/// Shows a dialog route with a soft scale + fade entrance.
Future<T?> showPlusDialogRoute<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.46),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
