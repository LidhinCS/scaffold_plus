import 'package:flutter/material.dart';
import 'package:ui_plus/src/states/plus_state_layout.dart';

/// A centered error-state layout with an optional retry action.
///
/// Use when content failed to load. Map domain or network errors to display
/// text in the app layer — this widget does not depend on HTTP clients or
/// error models.
///
/// Colors and text styles follow the ambient [ThemeData] / [ColorScheme]
/// unless overridden. The default icon uses [ColorScheme.error].
///
/// {@tool snippet}
/// ```dart
/// PlusErrorState(
///   title: 'Something went wrong',
///   message: 'Unable to load your data.',
///   actionLabel: 'Try again',
///   onRetry: reload,
/// )
/// ```
/// {@end-tool}
class PlusErrorState extends StatelessWidget {
  /// Creates an error-state presentation.
  ///
  /// The retry button is shown only when both [actionLabel] and [onRetry]
  /// are non-null.
  const new({
    required this.title,
    super.key,
    this.message,
    this.icon = Icons.error_outline,
    this.illustration,
    this.iconSize = 64,
    this.iconColor,
    this.actionLabel,
    this.onRetry,
    this.spacing = 16,
    this.padding = const EdgeInsets.all(24),
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.titleTextStyle,
    this.messageTextStyle,
    this.textAlign = TextAlign.center,
  });

  /// Primary error heading shown to the user.
  final String title;

  /// Optional supporting message below the title.
  final String? message;

  /// Optional Material icon shown above the title.
  ///
  /// Ignored when [illustration] is non-null. Pass `null` to hide the icon
  /// when no illustration is provided.
  final IconData? icon;

  /// Optional custom visual above the title (image, illustration, etc.).
  ///
  /// When non-null, this replaces [icon].
  final Widget? illustration;

  /// Size applied to [icon]. Defaults to `64`.
  final double iconSize;

  /// Color for [icon]. Defaults to [ColorScheme.error].
  final Color? iconColor;

  /// Label for the optional retry button.
  final String? actionLabel;

  /// Called when the retry button is pressed.
  final VoidCallback? onRetry;

  /// Vertical gap between icon, title, message, and action.
  final double spacing;

  /// Outer padding around the column.
  final EdgeInsetsGeometry padding;

  /// How much vertical space the column should occupy.
  final MainAxisSize mainAxisSize;

  /// How children are aligned along the vertical axis.
  final MainAxisAlignment mainAxisAlignment;

  /// How children are aligned along the horizontal axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// Overrides the title [TextStyle].
  final TextStyle? titleTextStyle;

  /// Overrides the message [TextStyle].
  final TextStyle? messageTextStyle;

  /// Alignment for title and message text.
  final TextAlign textAlign;

  bool get _showAction => actionLabel != null && onRetry != null;

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
      padding: padding,
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
                    color: iconColor ?? colorScheme.error,
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
          if (_showAction) ...[
            SizedBox(height: spacing),
            FilledButton(onPressed: onRetry, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
