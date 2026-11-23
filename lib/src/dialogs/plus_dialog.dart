import 'package:flutter/material.dart';

/// Material 3 alert dialog helpers.
///
/// Use [PlusDialog.show] for a simple title / message / actions dialog, or
/// [PlusDialog.alert] when a single dismiss action is enough.
///
/// {@tool snippet}
/// ```dart
/// await PlusDialog.alert(
///   context,
///   title: 'Offline',
///   message: 'Connect to the internet and try again.',
/// );
/// ```
/// {@end-tool}
abstract final class PlusDialog {
  /// Shows a customizable [AlertDialog].
  ///
  /// Provide either [message] (plain text) or [content] (custom widget), not
  /// both as competing body content — when [content] is non-null it is used.
  ///
  /// When [actions] is null, a single dismiss button is shown using
  /// [primaryLabel] (default `OK`).
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    List<Widget>? actions,
    String primaryLabel = 'OK',
    VoidCallback? onPrimary,
    bool barrierDismissible = true,
    Color? barrierColor,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? actionsPadding,
    TextStyle? titleTextStyle,
    TextStyle? messageTextStyle,
    Clip clipBehavior = Clip.none,
  }) {
    assert(
      message == null || content == null,
      'Provide message or content, not both.',
    );

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final resolvedActions =
            actions ??
            [
              TextButton(
                onPressed: () {
                  onPrimary?.call();
                  Navigator.of(dialogContext).pop();
                },
                child: Text(primaryLabel),
              ),
            ];

        return AlertDialog(
          title: Text(title, style: titleTextStyle),
          content:
              content ??
              (message == null || message.isEmpty
                  ? null
                  : Text(
                      message,
                      style:
                          messageTextStyle ??
                          theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                    )),
          contentPadding: contentPadding,
          actionsPadding: actionsPadding,
          clipBehavior: clipBehavior,
          actions: resolvedActions,
        );
      },
    );
  }

  /// Shows a simple alert with a single dismiss action.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? message,
    String primaryLabel = 'OK',
    VoidCallback? onPrimary,
    bool barrierDismissible = true,
  }) {
    return show<void>(
      context,
      title: title,
      message: message,
      primaryLabel: primaryLabel,
      onPrimary: onPrimary,
      barrierDismissible: barrierDismissible,
    );
  }
}
