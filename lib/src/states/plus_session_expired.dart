import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/src/states/plus_state_layout.dart';
import 'package:ui_plus/src/theme/plus_theme.dart';

/// A centered full-page session-expired presentation.
///
/// Independently reusable. Does not manage auth tokens — the app decides when
/// the session is invalid and supplies copy / sign-in actions.
///
/// Scrolls instead of overflowing when placed in a tight height constraint.
///
/// {@tool snippet}
/// ```dart
/// PlusSessionExpired(
///   actionLabel: 'Sign in',
///   onAction: goToLogin,
/// )
/// ```
/// {@end-tool}
class PlusSessionExpired extends StatelessWidget {
  /// Creates a session-expired presentation.
  ///
  /// The action button is shown only when both [actionLabel] and [onAction]
  /// are non-null.
  const new({
    super.key,
    this.title = 'Session expired',
    this.message = 'Your session has ended. Please sign in again to continue.',
    this.icon = Icons.lock_clock_outlined,
    this.illustration,
    this.iconSize = 64,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.spacing = 16,
    this.padding,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.titleTextStyle,
    this.messageTextStyle,
    this.textAlign = TextAlign.center,
    this.actionBuilder,
  });

  /// Primary heading.
  final String title;

  /// Optional supporting message.
  final String? message;

  /// Optional Material icon above the title.
  final IconData? icon;

  /// Optional custom illustration that replaces [icon].
  final Widget? illustration;

  /// Size applied to [icon].
  final double iconSize;

  /// Color for [icon]. Defaults to [ColorScheme.onSurfaceVariant].
  final Color? iconColor;

  /// Label for the primary action (e.g. "Sign in").
  final String? actionLabel;

  /// Called when the primary action is pressed.
  final VoidCallback? onAction;

  /// Optional secondary action label (e.g. "Dismiss").
  final String? secondaryActionLabel;

  /// Called when the secondary action is pressed.
  final VoidCallback? onSecondaryAction;

  /// Vertical gap between children.
  final double spacing;

  /// Outer padding.
  ///
  /// Null uses [PlusTheme.statePadding].
  final EdgeInsetsGeometry? padding;

  /// Column main-axis size.
  final MainAxisSize mainAxisSize;

  /// Column main-axis alignment.
  final MainAxisAlignment mainAxisAlignment;

  /// Column cross-axis alignment.
  final CrossAxisAlignment crossAxisAlignment;

  /// Title text style override.
  final TextStyle? titleTextStyle;

  /// Message text style override.
  final TextStyle? messageTextStyle;

  /// Text alignment for title and message.
  final TextAlign textAlign;

  /// Optional custom action widget. When non-null, replaces the default
  /// action buttons.
  final WidgetBuilder? actionBuilder;

  bool get _showPrimaryAction => actionLabel != null && onAction != null;

  bool get _showSecondaryAction =>
      secondaryActionLabel != null && onSecondaryAction != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedTitleStyle =
        titleTextStyle ??
        theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface);
    final resolvedMessageStyle =
        messageTextStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );

    final semanticsLabel = message == null || message!.isEmpty
        ? title
        : '$title. $message';

    return PlusStateLayout(
      padding: padding ?? PlusTheme.of(context).statePadding,
      child: Column(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Semantics(
            container: true,
            label: semanticsLabel,
            excludeSemantics: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: [
                if (illustration != null) ...[
                  illustration!,
                  SizedBox(height: spacing),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    size: iconSize,
                    color: iconColor ?? colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: spacing),
                ],
                Text(title, style: resolvedTitleStyle, textAlign: textAlign),
                if (message != null && message!.isNotEmpty) ...[
                  SizedBox(height: spacing / 2),
                  Text(
                    message!,
                    style: resolvedMessageStyle,
                    textAlign: textAlign,
                  ),
                ],
              ],
            ),
          ),
          if (actionBuilder != null) ...[
            SizedBox(height: spacing),
            actionBuilder!(context),
          ] else if (_showPrimaryAction || _showSecondaryAction) ...[
            SizedBox(height: spacing),
            if (_showPrimaryAction)
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            if (_showPrimaryAction && _showSecondaryAction)
              SizedBox(height: spacing / 2),
            if (_showSecondaryAction)
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryActionLabel!),
              ),
          ],
        ],
      ),
    );
  }
}
