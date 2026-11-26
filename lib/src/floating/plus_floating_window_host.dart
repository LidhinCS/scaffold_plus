import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/src/floating/plus_floating_window_controller.dart';

/// Root host that paints active floating-window overlays.
///
/// Wire once via `MaterialApp.builder` (can wrap `PlusToastHost`):
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => PlusFloatingWindowHost(
///     child: PlusToastHost(child: child!),
///   ),
/// )
/// ```
class PlusFloatingWindowHost extends StatefulWidget {
  /// Creates a floating-window host around [child].
  const new({required this.child, super.key});

  /// App content under the floating layer.
  final Widget child;

  /// Nearest host scope, if any.
  static PlusFloatingWindowHostScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_PlusFloatingWindowHostInherited>()
        ?.scope;
  }

  /// Nearest host scope; throws if missing.
  static PlusFloatingWindowHostScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(
      scope != null,
      'PlusFloatingWindowHost not found. Wrap your app with '
      'PlusFloatingWindowHost via MaterialApp.builder.',
    );
    return scope!;
  }

  @override
  State<PlusFloatingWindowHost> createState() => _PlusFloatingWindowHostState();
}

/// Registry used by page-local floating windows to attach to the host.
class PlusFloatingWindowHostScope {
  // Private generative ctor; `_(…)` is not valid on a public class name.
  // ignore: unnecessary_type_name_in_constructor
  PlusFloatingWindowHostScope._(this._state);

  final _PlusFloatingWindowHostState _state;

  /// Registers [controller] so the host can paint it while floating.
  void register(PlusFloatingWindowController controller) {
    _state._register(controller);
  }

  /// Unregisters [controller] when the owning window is disposed.
  ///
  /// Does not dismiss an active floating session — the host keeps painting
  /// until `PlusFloatingWindowController.dismiss` or `expand`.
  void unregister(PlusFloatingWindowController controller) {
    _state._unregister(controller);
  }
}

class _PlusFloatingWindowHostState extends State<PlusFloatingWindowHost> {
  late final PlusFloatingWindowHostScope _scope = PlusFloatingWindowHostScope._(
    this,
  );
  final Set<PlusFloatingWindowController> _controllers =
      <PlusFloatingWindowController>{};

  void _register(PlusFloatingWindowController controller) {
    if (_controllers.add(controller)) {
      controller.addListener(_onControllerChanged);
      // Do not setState here — register runs from descendant
      // didChangeDependencies during the host's build.
    }
  }

  void _unregister(PlusFloatingWindowController controller) {
    // Keep the controller while it is still floating so PiP survives
    // owning-route dispose.
    if (controller.isFloating && controller.builder != null) {
      return;
    }
    if (_controllers.remove(controller)) {
      controller.removeListener(_onControllerChanged);
      _scheduleHostRebuild();
    }
  }

  void _onControllerChanged() {
    _scheduleHostRebuild();
  }

  void _scheduleHostRebuild() {
    if (!mounted) {
      return;
    }
    // Drop fully dismissed controllers that no longer have a page owner.
    _controllers.removeWhere(
      (controller) =>
          !controller.active &&
          !controller.isFloating &&
          controller.builder == null,
    );

    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      setState(() {});
      return;
    }

    // Defer when a descendant is mid-build (e.g. activate from initState).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_onControllerChanged);
    }
    _controllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final floating = _controllers
        .where((c) => c.isFloating && c.builder != null)
        .toList(growable: false);

    return _PlusFloatingWindowHostInherited(
      scope: _scope,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          for (final controller in floating)
            _PlusFloatingWindowOverlay(controller: controller),
        ],
      ),
    );
  }
}

class _PlusFloatingWindowHostInherited extends InheritedWidget {
  const new({required this.scope, required super.child});

  final PlusFloatingWindowHostScope scope;

  @override
  bool updateShouldNotify(_PlusFloatingWindowHostInherited oldWidget) => false;
}

class _PlusFloatingWindowOverlay extends StatelessWidget {
  const new({required this.controller});

  final PlusFloatingWindowController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isFloating || controller.builder == null) {
          return const SizedBox.shrink();
        }

        final media = MediaQuery.of(context);
        final screen = media.size;
        final padding = media.padding;
        final size = controller.size;

        final maxLeft = (screen.width - size.width).clamp(0.0, double.infinity);
        final maxTop = (screen.height - size.height - padding.bottom).clamp(
          0.0,
          double.infinity,
        );
        // Visual clamp only — drag/resize write clamped values via the chrome.
        final left = controller.offset.dx.clamp(0.0, maxLeft);
        final top = controller.offset.dy.clamp(padding.top, maxTop);

        return Positioned(
          left: left,
          top: top,
          width: size.width,
          height: size.height,
          child: _PlusFloatingWindowChrome(
            controller: controller,
            screenSize: screen,
            safePadding: padding,
            child: controller.builder!(context, floating: true),
          ),
        );
      },
    );
  }
}

class _PlusFloatingWindowChrome extends StatefulWidget {
  const new({
    required this.controller,
    required this.screenSize,
    required this.safePadding,
    required this.child,
  });

  final PlusFloatingWindowController controller;
  final Size screenSize;
  final EdgeInsets safePadding;
  final Widget child;

  @override
  State<_PlusFloatingWindowChrome> createState() =>
      _PlusFloatingWindowChromeState();
}

class _PlusFloatingWindowChromeState extends State<_PlusFloatingWindowChrome> {
  Offset? _dragStart;
  Offset? _offsetStart;
  Offset? _resizeStartGlobal;
  Size? _resizeStartSize;
  Offset? _resizeStartOffset;

  PlusFloatingWindowController get controller => widget.controller;

  void _clampAndSetOffset(Offset next) {
    final size = controller.size;
    final maxLeft = (widget.screenSize.width - size.width).clamp(
      0.0,
      double.infinity,
    );
    final maxTop =
        (widget.screenSize.height - size.height - widget.safePadding.bottom)
            .clamp(0.0, double.infinity);
    controller.updateOffset(
      Offset(
        next.dx.clamp(0.0, maxLeft),
        next.dy.clamp(widget.safePadding.top, maxTop),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
    _offsetStart = controller.offset;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final start = _dragStart;
    final origin = _offsetStart;
    if (start == null || origin == null) {
      return;
    }
    _clampAndSetOffset(origin + (details.globalPosition - start));
  }

  void _onResizeStart(DragStartDetails details) {
    _resizeStartGlobal = details.globalPosition;
    _resizeStartSize = controller.size;
    _resizeStartOffset = controller.offset;
  }

  void _onResizeUpdate(DragUpdateDetails details) {
    final startGlobal = _resizeStartGlobal;
    final startSize = _resizeStartSize;
    final startOffset = _resizeStartOffset;
    if (startGlobal == null || startSize == null || startOffset == null) {
      return;
    }
    final delta = details.globalPosition - startGlobal;
    controller.updateSize(
      Size(startSize.width + delta.dx, startSize.height + delta.dy),
    );
    _clampAndSetOffset(startOffset);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final title = controller.title;

    return Material(
      elevation: 8,
      shadowColor: colors.shadow.withValues(alpha: 0.35),
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _onDragStart,
                onPanUpdate: _onDragUpdate,
                child: Container(
                  height: 40,
                  padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
                  color: colors.surfaceContainerHighest,
                  child: Row(
                    children: [
                      Icon(
                        Icons.drag_indicator_rounded,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title ?? 'Floating window',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // No Tooltip — host is above Navigator Overlay.
                      _ChromeIconButton(
                        semanticLabel: 'Expand',
                        icon: Icons.open_in_full_rounded,
                        onPressed: controller.expand,
                      ),
                      _ChromeIconButton(
                        semanticLabel: 'Close',
                        icon: Icons.close_rounded,
                        onPressed: controller.dismiss,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: widget.child),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: _onResizeStart,
              onPanUpdate: _onResizeUpdate,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChromeIconButton extends StatelessWidget {
  const new({
    required this.semanticLabel,
    required this.icon,
    required this.onPressed,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}
