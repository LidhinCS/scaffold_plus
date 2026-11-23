import 'package:flutter/material.dart';
import 'package:ui_plus/src/dialogs/plus_dialog_surface.dart';

/// Material 3 alert dialog helpers with polished chrome and motion.
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
  /// Shows a customizable alert dialog.
  ///
  /// Provide either [message] (plain text) or [content] (custom widget), not
  /// both as competing body content — when [content] is non-null it is used.
  ///
  /// When [actions] is null, a single dismiss button is shown using
  /// [primaryLabel] (default `OK`).
  ///
  /// When [icon] is null, a default info icon badge is shown. Pass an explicit
  /// icon or set [showIcon] to false to hide it.
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
    IconData? icon = Icons.info_rounded,
    bool showIcon = true,
    Color? iconBackgroundColor,
    Color? iconColor,
    TextStyle? titleTextStyle,
    TextStyle? messageTextStyle,
  }) {
    assert(
      message == null || content == null,
      'Provide message or content, not both.',
    );

    return showPlusDialogRoute<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (dialogContext) {
        final resolvedActions =
            actions ??
            [
              FilledButton(
                onPressed: () {
                  onPrimary?.call();
                  Navigator.of(dialogContext).pop();
                },
                child: Text(primaryLabel),
              ),
            ];

        return PlusDialogSurface(
          title: title,
          message: message,
          content: content,
          icon: showIcon ? icon : null,
          iconBackgroundColor: iconBackgroundColor,
          iconColor: iconColor,
          titleTextStyle: titleTextStyle,
          messageTextStyle: messageTextStyle,
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
    IconData? icon = Icons.info_rounded,
    bool showIcon = true,
  }) {
    return show<void>(
      context,
      title: title,
      message: message,
      primaryLabel: primaryLabel,
      onPrimary: onPrimary,
      barrierDismissible: barrierDismissible,
      icon: icon,
      showIcon: showIcon,
    );
  }
}
