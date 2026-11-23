import 'package:flutter/material.dart';
import 'package:scaffold_plus/src/connectivity/plus_connectivity_config.dart';

/// Default Material 3 connectivity banner presentation.
///
/// Pass [isConnected] for the visual state. Lifecycle, streams, and auto-hide
/// belong in `PlusConnectivityOverlay` or the host app.
class PlusConnectivityBanner extends StatelessWidget {
  /// Creates a connectivity banner for the given [isConnected] status.
  const new({
    required this.isConnected,
    super.key,
    this.config = const PlusConnectivityConfig(),
    this.onDismiss,
  });

  /// Whether the banner should render the online appearance.
  final bool isConnected;

  /// Appearance and copy configuration.
  final PlusConnectivityConfig config;

  /// Called when the dismiss control is pressed (`config.dismissible` only).
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final background = isConnected
        ? (config.onlineBackgroundColor ?? colorScheme.primaryContainer)
        : (config.offlineBackgroundColor ?? colorScheme.errorContainer);
    final foreground = isConnected
        ? (config.onlineForegroundColor ?? colorScheme.onPrimaryContainer)
        : (config.offlineForegroundColor ?? colorScheme.onErrorContainer);

    final message = isConnected ? config.onlineMessage : config.offlineMessage;
    final subtitle = isConnected
        ? config.onlineSubtitle
        : config.offlineSubtitle;
    final icon = isConnected ? config.onlineIcon : config.offlineIcon;
    final messageStyle =
        (isConnected
            ? config.onlineMessageStyle
            : config.offlineMessageStyle) ??
        theme.textTheme.titleSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        );
    final subtitleStyle =
        (isConnected
            ? config.onlineSubtitleStyle
            : config.offlineSubtitleStyle) ??
        theme.textTheme.bodySmall?.copyWith(color: foreground);

    return Material(
      color: background,
      elevation: config.elevation,
      borderRadius: config.borderRadius,
      child: Padding(
        padding: config.padding,
        child: Row(
          children: [
            Icon(icon, size: config.iconSize, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, style: messageStyle),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: subtitleStyle),
                  ],
                ],
              ),
            ),
            if (config.dismissible && onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                icon: Icon(Icons.close, color: foreground, size: 20),
                visualDensity: VisualDensity.compact,
                tooltip: 'Dismiss',
              ),
          ],
        ),
      ),
    );
  }
}
