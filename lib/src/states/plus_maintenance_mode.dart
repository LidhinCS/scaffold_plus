import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/src/states/plus_state_layout.dart';
import 'package:ui_plus/src/theme/plus_theme.dart';

/// A centered full-page maintenance presentation.
///
/// Independently reusable. Does not fetch remote flags — the app decides when
/// maintenance is active and supplies copy / actions.
///
/// Scrolls instead of overflowing when placed in a tight height constraint.
///
/// {@tool snippet}
/// ```dart
/// const PlusMaintenanceMode(
///   title: "We'll be back soon",
///   message: 'Scheduled maintenance is in progress. Please try again later.',
/// )
/// ```
/// {@end-tool}
class PlusMaintenanceMode extends StatelessWidget {
  /// Creates a maintenance-state presentation.
  ///
  /// The action button is shown only when both [actionLabel] and [onAction]
  /// are non-null.
  const new({
    super.key,
    this.title = "We'll be back soon",
    this.message =
        'Scheduled maintenance is in progress. Please try again later.',
    this.icon = Icons.construction_outlined,
    this.illustration,
    this.iconSize = 64,
    this.iconColor,
    this.actionLabel,
    this.onAction,
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

  /// Primary maintenance heading.
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

  /// Label for the optional action button (e.g. "Check status").
  final String? actionLabel;

  /// Called when the action button is pressed.
  final VoidCallback? onAction;

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
  /// action button.
  final WidgetBuilder? actionBuilder;

  bool get _showDefaultAction => actionLabel != null && onAction != null;

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
          ] else if (_showDefaultAction) ...[
            SizedBox(height: spacing),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
