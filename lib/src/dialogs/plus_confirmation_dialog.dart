import 'package:flutter/material.dart';
import 'package:ui_plus/src/dialogs/plus_dialog_surface.dart';

/// Confirm / cancel dialog helpers with polished chrome and motion.
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
  /// When [isDestructive] is true, the confirm action uses the error color and
  /// a warning icon badge.
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
    IconData? icon,
    bool showIcon = true,
    TextStyle? titleTextStyle,
    TextStyle? messageTextStyle,
  }) async {
    assert(
      message == null || content == null,
      'Provide message or content, not both.',
    );

    final result = await showPlusDialogRoute<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;

        final confirmButton = isDestructive
            ? FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: Text(confirmLabel),
              )
            : FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(confirmLabel),
              );

        return PlusDialogSurface(
          title: title,
          message: message,
          content: content,
          isDestructive: isDestructive,
          icon: showIcon
              ? (icon ??
                    (isDestructive
                        ? Icons.warning_rounded
                        : Icons.help_rounded))
              : null,
          titleTextStyle: titleTextStyle,
          messageTextStyle: messageTextStyle,
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
