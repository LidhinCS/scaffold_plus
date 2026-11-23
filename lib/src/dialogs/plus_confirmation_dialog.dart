import 'package:flutter/material.dart';

/// Confirm / cancel dialog helpers.
///
/// Returns `true` when the user confirms, `false` when they cancel or dismiss
/// the barrier (when barrier dismiss is allowed).
///
/// {@tool snippet}
/// ```dart
/// final confirmed = await PlusConfirmationDialog.show(
///   context,
///   title: 'Delete item?',
///   message: 'This cannot be undone.',
///   confirmLabel: 'Delete',
///   isDestructive: true,
/// );
/// if (confirmed) {
///   deleteItem();
/// }
/// ```
/// {@end-tool}
abstract final class PlusConfirmationDialog {
  /// Shows a confirm / cancel dialog.
  ///
  /// When [isDestructive] is true, the confirm action uses the error color.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    bool barrierDismissible = true,
    Color? barrierColor,
    TextStyle? titleTextStyle,
    TextStyle? messageTextStyle,
  }) async {
    assert(
      message == null || content == null,
      'Provide message or content, not both.',
    );

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        final confirmButton = isDestructive
            ? TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                child: Text(confirmLabel),
              )
            : FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(confirmLabel),
              );

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
                            color: colorScheme.onSurfaceVariant,
                          ),
                    )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel),
            ),
            confirmButton,
          ],
        );
      },
    );

    return result ?? false;
  }
}
