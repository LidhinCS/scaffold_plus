import 'package:flutter/material.dart';
import 'package:ui_plus/src/states/plus_state_layout.dart';
import 'package:ui_plus/src/theme/plus_theme.dart';

/// A centered full-page offline presentation.
///
/// Independently reusable. Does not detect connectivity — pass copy from the
/// app layer when reachability is known to be unavailable.
///
/// Scrolls instead of overflowing when placed in a tight height constraint.
///
/// {@tool snippet}
/// ```dart
/// const PlusOfflineState(
///   title: 'No internet connection',
///   message: 'Please check your network and try again.',
/// )
/// ```
/// {@end-tool}
class PlusOfflineState extends StatelessWidget {
  /// Creates an offline-state presentation.
  ///
  /// The retry button is shown only when both [actionLabel] and [onRetry] are
  /// non-null.
  const new({
    super.key,
    this.title = 'No internet connection',
    this.message = 'Please check your network and try again.',
    this.icon = Icons.wifi_off,
    this.illustration,
    this.iconSize = 64,
    this.iconColor,
    this.actionLabel,
    this.onRetry,
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

  /// Primary offline heading.
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

  /// Label for the optional retry button.
  final String? actionLabel;

  /// Called when the retry button is pressed.
  final VoidCallback? onRetry;

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
  /// retry button.
  final WidgetBuilder? actionBuilder;

  bool get _showDefaultAction => actionLabel != null && onRetry != null;

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
            FilledButton(onPressed: onRetry, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
