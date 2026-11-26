import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/src/floating/plus_floating_window_controller.dart';
import 'package:ui_plus/src/floating/plus_floating_window_host.dart';

/// Page-local floating window that can detach into [PlusFloatingWindowHost].
///
/// While the owning route is current and the controller is not floating, the
/// [builder] is shown inline. When the route is no longer current and
/// [PlusFloatingWindowController.active] is true, content moves into the
/// host overlay (PiP). You can also call
/// [PlusFloatingWindowController.enterFloating] manually.
///
/// ```dart
/// PlusFloatingWindow(
///   controller: controller,
///   title: 'Focus timer',
///   builder: (context, {required floating}) => TimerView(compact: floating),
/// )
/// ```
class PlusFloatingWindow extends StatefulWidget {
  /// Creates a floating window bound to [controller].
  const new({
    required this.controller,
    required this.builder,
    super.key,
    this.title,
    this.placeholder,
    this.autoFloatOnRouteExit = true,
    this.onDismiss,
    this.onFloatingChanged,
  });

  /// Session controller (size, offset, active/floating).
  final PlusFloatingWindowController controller;

  /// Builds content for inline and floating presentations.
  final PlusFloatingWindowContentBuilder builder;

  /// Optional chrome title while floating.
  final String? title;

  /// Inline placeholder while floating and the page is still mounted.
  ///
  /// Defaults to a compact “floating” chip that expands on tap.
  final Widget? placeholder;

  /// When true, leaving the current route while [controller] is active
  /// automatically enters floating mode.
  final bool autoFloatOnRouteExit;

  /// Forwarded to [PlusFloatingWindowController.activate].
  final VoidCallback? onDismiss;

  /// Forwarded to [PlusFloatingWindowController.activate].
  final ValueChanged<bool>? onFloatingChanged;

  @override
  State<PlusFloatingWindow> createState() => _PlusFloatingWindowState();
}

class _PlusFloatingWindowState extends State<PlusFloatingWindow> {
  ModalRoute<dynamic>? _route;
  Listenable? _routeListenables;
  PlusFloatingWindowHostScope? _host;

  /// True after the owning route has been non-current at least once.
  ///
  /// Used so auto-expand only runs when returning to the page, not when the
  /// user manually calls [PlusFloatingWindowController.enterFloating] on the
  /// current route.
  var _leftOwningRoute = false;

  @override
  void initState() {
    super.initState();
    // Activate before listening so notifyListeners does not setState here.
    _syncActivation(floating: widget.controller.isFloating);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PlusFloatingWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      _syncActivation(floating: widget.controller.isFloating);
      widget.controller.addListener(_onControllerChanged);
      _host?.register(widget.controller);
    } else if (oldWidget.builder != widget.builder ||
        oldWidget.title != widget.title ||
        oldWidget.onDismiss != widget.onDismiss ||
        oldWidget.onFloatingChanged != widget.onFloatingChanged) {
      _syncActivation(floating: widget.controller.isFloating);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _host = PlusFloatingWindowHost.maybeOf(context);
    _host?.register(widget.controller);
    _bindRoute(ModalRoute.of(context));
  }

  @override
  void dispose() {
    _unbindRoute();
    widget.controller.removeListener(_onControllerChanged);
    // Owning page disposed while still active → keep session in the host.
    if (widget.autoFloatOnRouteExit &&
        widget.controller.active &&
        !widget.controller.isFloating) {
      widget.controller.enterFloating();
    }
    if (!widget.controller.isFloating) {
      _host?.unregister(widget.controller);
    }
    super.dispose();
  }

  void _bindRoute(ModalRoute<dynamic>? route) {
    if (identical(route, _route)) {
      return;
    }
    _unbindRoute();
    _route = route;
    final animations = <Listenable>[
      if (route?.animation != null) route!.animation!,
      if (route?.secondaryAnimation != null) route!.secondaryAnimation!,
    ];
    if (animations.isEmpty) {
      return;
    }
    _routeListenables = Listenable.merge(animations)..addListener(_onRouteTick);
  }

  void _unbindRoute() {
    _routeListenables?.removeListener(_onRouteTick);
    _routeListenables = null;
    _route = null;
  }

  void _onRouteTick() {
    if (!mounted) {
      return;
    }
    _syncRouteVisibility();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _syncActivation({required bool floating}) {
    widget.controller.activate(
      builder: widget.builder,
      title: widget.title,
      floating: floating,
      onDismiss: widget.onDismiss,
      onFloatingChanged: widget.onFloatingChanged,
    );
  }

  void _syncRouteVisibility() {
    if (!widget.autoFloatOnRouteExit) {
      return;
    }
    if (!widget.controller.active || widget.controller.builder == null) {
      return;
    }
    final route = _route;
    if (route == null) {
      return;
    }
    if (!route.isCurrent) {
      _leftOwningRoute = true;
      if (!widget.controller.isFloating) {
        widget.controller.enterFloating();
      }
    } else if (_leftOwningRoute && widget.controller.isFloating) {
      _leftOwningRoute = false;
      widget.controller.expand();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.isFloating) {
      return widget.placeholder ??
          _DefaultFloatingPlaceholder(
            title: widget.title ?? 'Floating window',
            onExpand: widget.controller.expand,
          );
    }

    return widget.builder(context, floating: false);
  }
}

class _DefaultFloatingPlaceholder extends StatelessWidget {
  const new({required this.title, required this.onExpand});

  final String title;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onExpand,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.picture_in_picture_alt_rounded, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$title is floating',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(onPressed: onExpand, child: const Text('Expand')),
            ],
          ),
        ),
      ),
    );
  }
}
