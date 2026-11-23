import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scaffold_plus/src/connectivity/plus_connectivity_banner.dart';
import 'package:scaffold_plus/src/connectivity/plus_connectivity_config.dart';

/// Builds a custom connectivity banner for the given status.
typedef PlusConnectivityBannerBuilder = Widget Function(
  BuildContext context, {
  required bool isConnected,
});

/// Overlays a connectivity banner on [child] without resizing the body.
///
/// Supply connectivity via [isConnected] and/or [connectivityStream]. The
/// values should represent actual internet reachability when reliable online
/// indicators are required — Wi-Fi association alone is not enough.
///
/// The first observed status is applied silently (no "connection restored"
/// flash on launch). Subsequent `false → true` transitions may show the
/// temporary online banner.
class PlusConnectivityOverlay extends StatefulWidget {
  /// Creates a connectivity overlay host.
  const new({
    required this.child,
    super.key,
    this.isConnected,
    this.connectivityStream,
    this.config = const PlusConnectivityConfig(),
    this.bannerBuilder,
  });

  /// Underlying content (typically a [Scaffold]).
  final Widget child;

  /// Optional snapshot status. Used when no stream is provided, and as the
  /// initial value before the first stream event.
  final bool? isConnected;

  /// Optional live connectivity updates.
  final Stream<bool>? connectivityStream;

  /// Banner appearance and behavior.
  final PlusConnectivityConfig config;

  /// Optional custom banner. Defaults to [PlusConnectivityBanner].
  final PlusConnectivityBannerBuilder? bannerBuilder;

  @override
  State<PlusConnectivityOverlay> createState() =>
      _PlusConnectivityOverlayState();
}

class _PlusConnectivityOverlayState extends State<PlusConnectivityOverlay>
    with SingleTickerProviderStateMixin {
  StreamSubscription<bool>? _subscription;
  Timer? _debounceTimer;
  Timer? _autoHideTimer;

  late final AnimationController _controller;

  bool? _connected;
  var _initialized = false;
  var _bannerVisible = false;
  var _showingOnline = false;
  var _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.config.animationDuration,
    );
    _applyStatus(widget.isConnected, immediate: true);
    _subscribe(widget.connectivityStream);
  }

  @override
  void didUpdateWidget(covariant PlusConnectivityOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.config.animationDuration != widget.config.animationDuration) {
      _controller.duration = widget.config.animationDuration;
    }

    if (oldWidget.connectivityStream != widget.connectivityStream) {
      _subscribe(widget.connectivityStream);
    }

    if (oldWidget.isConnected != widget.isConnected &&
        widget.connectivityStream == null) {
      _applyStatus(widget.isConnected);
    }
  }

  Animation<Offset> get _slideAnimation {
    final begin = widget.config.position == PlusConnectivityBannerPosition.top
        ? const Offset(0, -1)
        : const Offset(0, 1);
    return Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  void _subscribe(Stream<bool>? stream) {
    // Cancel is fire-and-forget; awaiting would block rebuilds.
    // ignore: discarded_futures
    _subscription?.cancel();
    _subscription = null;
    if (stream == null) {
      return;
    }

    _subscription = stream.listen(
      _onStreamEvent,
      onError: _onStreamError,
      cancelOnError: false,
    );
  }

  void _onStreamEvent(bool value) => _applyStatus(value);

  void _onStreamError(Object error) {
    // Preserve the last known status; do not tear down the overlay.
  }

  void _applyStatus(bool? value, {bool immediate = false}) {
    if (value == null) {
      return;
    }

    _debounceTimer?.cancel();
    if (immediate || widget.config.debounceDuration == Duration.zero) {
      _commitStatus(value);
      return;
    }

    _debounceTimer = Timer(widget.config.debounceDuration, () {
      if (!mounted) {
        return;
      }
      _commitStatus(value);
    });
  }

  void _commitStatus(bool value) {
    if (!_initialized) {
      _initialized = true;
      _connected = value;
      _dismissed = false;
      if (!value && widget.config.showOfflineMessage) {
        _showingOnline = false;
        _bannerVisible = true;
        _controller.value = 1;
      } else {
        _bannerVisible = false;
        _showingOnline = false;
        _controller.value = 0;
      }
      if (mounted) {
        setState(() {});
      }
      return;
    }

    if (_connected == value) {
      return;
    }

    final wasConnected = _connected;
    _connected = value;
    _dismissed = false;
    _autoHideTimer?.cancel();

    if (!value) {
      if (!widget.config.showOfflineMessage) {
        unawaited(_hideBanner());
        return;
      }
      _presentBanner(showingOnline: false);
      return;
    }

    if (wasConnected == false && widget.config.showOnlineMessage) {
      _presentBanner(showingOnline: true);
      if (widget.config.autoHideOnline) {
        _autoHideTimer = Timer(widget.config.autoHideDuration, () {
          if (!mounted || _connected != true) {
            return;
          }
          unawaited(_hideBanner());
        });
      }
      return;
    }

    unawaited(_hideBanner());
  }

  void _presentBanner({required bool showingOnline}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _showingOnline = showingOnline;
      _bannerVisible = true;
      _dismissed = false;
    });
    _controller.forward(from: 0);
  }

  Future<void> _hideBanner() async {
    _autoHideTimer?.cancel();
    if (!_bannerVisible) {
      return;
    }
    await _controller.reverse();
    if (!mounted) {
      return;
    }
    setState(() {
      _bannerVisible = false;
      _showingOnline = false;
    });
  }

  void _onDismiss() {
    _dismissed = true;
    unawaited(_hideBanner());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _autoHideTimer?.cancel();
    // Cancel is fire-and-forget during dispose.
    // ignore: discarded_futures
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBanner(BuildContext context, bool connected) {
    final builder = widget.bannerBuilder;
    if (builder != null) {
      return builder(context, isConnected: connected);
    }

    final showOnlineAppearance = connected && _showingOnline;
    return PlusConnectivityBanner(
      isConnected: showOnlineAppearance,
      config: widget.config,
      onDismiss: widget.config.dismissible ? _onDismiss : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final connected = _connected ?? true;
    final showBanner =
        _bannerVisible &&
        !_dismissed &&
        ((connected && _showingOnline && widget.config.showOnlineMessage) ||
            (!connected && widget.config.showOfflineMessage));

    return Stack(
      children: [
        widget.child,
        if (showBanner)
          Positioned(
            top: widget.config.position == PlusConnectivityBannerPosition.top
                ? 0
                : null,
            bottom:
                widget.config.position == PlusConnectivityBannerPosition.bottom
                ? 0
                : null,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom:
                  widget.config.position ==
                  PlusConnectivityBannerPosition.bottom,
              top: widget.config.position == PlusConnectivityBannerPosition.top,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: widget.config.margin,
                  child: _buildBanner(context, connected),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
