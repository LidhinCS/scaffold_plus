import 'package:flutter/material.dart';

/// Vertical placement for connectivity banners.
enum PlusConnectivityBannerPosition {
  /// Align the banner to the top of the overlay (below the status bar).
  top,

  /// Align the banner to the bottom of the overlay (above the home indicator).
  bottom,
}

/// Appearance and behavior options for connectivity banners.
///
/// Colors default from the ambient [ColorScheme] when left null so light and
/// dark themes work without hard-coded values.
class PlusConnectivityConfig {
  /// Creates connectivity banner configuration with sensible defaults.
  const new({
    this.offlineMessage = 'No internet connection',
    this.offlineSubtitle = 'Check your network settings',
    this.onlineMessage = 'Connection restored',
    this.onlineSubtitle,
    this.offlineBackgroundColor,
    this.onlineBackgroundColor,
    this.offlineForegroundColor,
    this.onlineForegroundColor,
    this.offlineMessageStyle,
    this.onlineMessageStyle,
    this.offlineSubtitleStyle,
    this.onlineSubtitleStyle,
    this.offlineIcon = Icons.wifi_off,
    this.onlineIcon = Icons.wifi,
    this.iconSize = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.elevation = 4,
    this.margin = const EdgeInsets.fromLTRB(12, 8, 12, 12),
    this.position = PlusConnectivityBannerPosition.top,
    this.showOfflineMessage = true,
    this.showOnlineMessage = true,
    this.autoHideOnline = true,
    this.autoHideDuration = const Duration(seconds: 2),
    this.animationDuration = const Duration(milliseconds: 320),
    this.dismissible = false,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  /// Primary offline banner copy.
  final String offlineMessage;

  /// Optional offline supporting copy.
  final String? offlineSubtitle;

  /// Primary online / restored banner copy.
  final String onlineMessage;

  /// Optional online supporting copy.
  final String? onlineSubtitle;

  /// Offline banner background. Defaults to [ColorScheme.errorContainer].
  final Color? offlineBackgroundColor;

  /// Online banner background. Defaults to [ColorScheme.primaryContainer].
  final Color? onlineBackgroundColor;

  /// Offline icon/text color. Defaults to [ColorScheme.onErrorContainer].
  final Color? offlineForegroundColor;

  /// Online icon/text color. Defaults to [ColorScheme.onPrimaryContainer].
  final Color? onlineForegroundColor;

  /// Offline message text style.
  final TextStyle? offlineMessageStyle;

  /// Online message text style.
  final TextStyle? onlineMessageStyle;

  /// Offline subtitle text style.
  final TextStyle? offlineSubtitleStyle;

  /// Online subtitle text style.
  final TextStyle? onlineSubtitleStyle;

  /// Icon shown while offline.
  final IconData offlineIcon;

  /// Icon shown while online / restored.
  final IconData onlineIcon;

  /// Icon size for both states.
  final double iconSize;

  /// Inner padding of the banner card.
  final EdgeInsetsGeometry padding;

  /// Banner corner radius.
  final BorderRadiusGeometry borderRadius;

  /// Material elevation of the banner card.
  final double elevation;

  /// Outer margin around the banner within the overlay.
  final EdgeInsetsGeometry margin;

  /// Top or bottom overlay placement.
  final PlusConnectivityBannerPosition position;

  /// Whether to show the offline banner.
  final bool showOfflineMessage;

  /// Whether to show the temporary online banner.
  final bool showOnlineMessage;

  /// Whether the online banner hides automatically.
  final bool autoHideOnline;

  /// Online banner visible duration when [autoHideOnline] is true.
  final Duration autoHideDuration;

  /// Slide animation duration.
  final Duration animationDuration;

  /// Whether the user can dismiss the banner with a close action.
  final bool dismissible;

  /// Minimum stable duration before applying a connectivity change.
  final Duration debounceDuration;
}
