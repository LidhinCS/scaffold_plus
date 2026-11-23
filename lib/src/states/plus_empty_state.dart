import 'package:flutter/material.dart';
import 'package:ui_plus/src/states/plus_state_layout.dart';
import 'package:ui_plus/src/theme/plus_theme.dart';

/// A centered empty-state layout for lists, searches, and similar screens.
///
/// Use when there is no content to show. Provide an optional [description],
/// [icon] or [illustration], and an optional action via [actionLabel] and
/// [onAction].
///
/// Colors and text styles follow the ambient [ThemeData] / [ColorScheme]
/// unless overridden.
///
/// {@tool snippet}
/// ```dart
/// PlusEmptyState(
///   title: 'Nothing here yet',
///   description: 'Your items will appear here.',
///   icon: Icons.inbox_outlined,
///   actionLabel: 'Refresh',
///   onAction: refresh,
/// )
/// ```
/// {@end-tool}
class PlusEmptyState extends StatelessWidget {
  /// Creates an empty-state presentation.
  ///
  /// The action button is shown only when both [actionLabel] and [onAction]
  /// are non-null.
  const new({
    required this.title,
    super.key,
    this.description,
    this.icon = Icons.inbox_outlined,
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
    this.descriptionTextStyle,
    this.textAlign = TextAlign.center,
  });

  /// Primary message shown to the user.
  final String title;

  /// Optional supporting copy below the title.
  final String? description;

  /// Optional Material icon shown above the title.
  ///
  /// Ignored when [illustration] is non-null. Pass `null` to hide the icon
  /// when no illustration is provided.
  final IconData? icon;

  /// Optional custom visual above the title (image, Lottie, etc.).
  ///
  /// When non-null, this replaces [icon].
  final Widget? illustration;

  /// Size applied to [icon]. Defaults to `64`.
  final double iconSize;

  /// Color for [icon]. Defaults to [ColorScheme.onSurfaceVariant].
  final Color? iconColor;

  /// Label for the optional action button.
  final String? actionLabel;

  /// Called when the action button is pressed.
  final VoidCallback? onAction;

  /// Vertical gap between icon, title, description, and action.
  final double spacing;

  /// Outer padding around the column.
  ///
  /// Null uses [PlusTheme.statePadding].
  final EdgeInsetsGeometry? padding;

  /// How much vertical space the column should occupy.
  final MainAxisSize mainAxisSize;

  /// How children are aligned along the vertical axis.
  final MainAxisAlignment mainAxisAlignment;

  /// How children are aligned along the horizontal axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// Overrides the title [TextStyle].
  final TextStyle? titleTextStyle;

  /// Overrides the description [TextStyle].
  final TextStyle? descriptionTextStyle;

  /// Alignment for title and description text.
  final TextAlign textAlign;

  bool get _showAction => actionLabel != null && onAction != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedTitleStyle =
        titleTextStyle ??
        theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface);
    final resolvedDescriptionStyle =
        descriptionTextStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );

    final semanticsLabel = description == null || description!.isEmpty
        ? title
        : '$title. $description';

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
                if (description != null && description!.isNotEmpty) ...[
                  SizedBox(height: spacing / 2),
                  Text(
                    description!,
                    style: resolvedDescriptionStyle,
                    textAlign: textAlign,
                  ),
                ],
              ],
            ),
          ),
          if (_showAction) ...[
            SizedBox(height: spacing),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
