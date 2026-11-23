import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scaffold_plus/src/async/plus_async_body.dart';
import 'package:scaffold_plus/src/async/plus_async_state.dart';
import 'package:scaffold_plus/src/async/plus_async_types.dart';
import 'package:scaffold_plus/src/connectivity/plus_connectivity_config.dart';
import 'package:scaffold_plus/src/connectivity/plus_connectivity_overlay.dart';

/// A drop-in [Scaffold] replacement with optional async body rendering and
/// optional connectivity banners.
///
/// Forwards the full Flutter [Scaffold] API and composes a native [Scaffold]
/// internally, so [Scaffold.of] / [Scaffold.maybeOf] continue to work for
/// descendants.
///
/// ## Body vs async state
///
/// - When [state] is `null`, [body] is shown (normal scaffold usage).
/// - When [state] is non-null, async rendering takes priority and [body] is
///   **ignored** (no assert). Provide [bodyBuilder] for successful data.
///
/// ## Connectivity
///
/// Opt in with [connectivityBanner]. Supply [isConnected] and/or
/// [connectivityStream]. Prefer reachability-aware values when you need a
/// reliable internet indicator. Core does not depend on a connectivity plugin.
class ScaffoldPlus<T> extends StatelessWidget {
  /// Creates a scaffold that optionally renders async [state] in its body.
  const new({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    this.persistentFooterDecoration,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.drawerBarrierDismissible = true,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.bottomSheetScrimBuilder,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
    this.state,
    this.bodyBuilder,
    this.isEmpty,
    this.onRetry,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.useSkeleton = false,
    this.skeletonBuilder,
    this.connectivityBanner = false,
    this.isConnected,
    this.connectivityStream,
    this.connectivityBannerConfig = const PlusConnectivityConfig(),
    this.connectivityBannerBuilder,
  });

  /// {@macro flutter.material.scaffold.appBar}
  final PreferredSizeWidget? appBar;

  /// Primary content when [state] is `null`.
  ///
  /// Ignored when [state] is non-null; async rendering takes priority.
  final Widget? body;

  /// {@macro flutter.material.scaffold.floatingActionButton}
  final Widget? floatingActionButton;

  /// {@macro flutter.material.scaffold.floatingActionButtonLocation}
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// {@macro flutter.material.scaffold.floatingActionButtonAnimator}
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;

  /// {@macro flutter.material.scaffold.persistentFooterButtons}
  final List<Widget>? persistentFooterButtons;

  /// {@macro flutter.material.scaffold.persistentFooterAlignment}
  final AlignmentDirectional persistentFooterAlignment;

  /// Decoration for the persistent footer.
  final BoxDecoration? persistentFooterDecoration;

  /// {@macro flutter.material.scaffold.drawer}
  final Widget? drawer;

  /// {@macro flutter.material.scaffold.onDrawerChanged}
  final DrawerCallback? onDrawerChanged;

  /// {@macro flutter.material.scaffold.endDrawer}
  final Widget? endDrawer;

  /// {@macro flutter.material.scaffold.onEndDrawerChanged}
  final DrawerCallback? onEndDrawerChanged;

  /// {@macro flutter.material.scaffold.bottomNavigationBar}
  final Widget? bottomNavigationBar;

  /// {@macro flutter.material.scaffold.bottomSheet}
  final Widget? bottomSheet;

  /// {@macro flutter.material.scaffold.backgroundColor}
  final Color? backgroundColor;

  /// {@macro flutter.material.scaffold.resizeToAvoidBottomInset}
  final bool? resizeToAvoidBottomInset;

  /// {@macro flutter.material.scaffold.primary}
  final bool primary;

  /// {@macro flutter.material.DrawerController.dragStartBehavior}
  final DragStartBehavior drawerDragStartBehavior;

  /// {@macro flutter.material.scaffold.extendBody}
  final bool extendBody;

  /// Whether the drawer barrier is dismissible.
  final bool drawerBarrierDismissible;

  /// {@macro flutter.material.scaffold.extendBodyBehindAppBar}
  final bool extendBodyBehindAppBar;

  /// {@macro flutter.material.scaffold.drawerScrimColor}
  final Color? drawerScrimColor;

  /// Optional bottom-sheet scrim builder. When null, Flutter's [Scaffold]
  /// default scrim builder is used.
  final Widget? Function(BuildContext, Animation<double>)?
  bottomSheetScrimBuilder;

  /// {@macro flutter.material.scaffold.drawerEdgeDragWidth}
  final double? drawerEdgeDragWidth;

  /// {@macro flutter.material.scaffold.drawerEnableOpenDragGesture}
  final bool drawerEnableOpenDragGesture;

  /// {@macro flutter.material.scaffold.endDrawerEnableOpenDragGesture}
  final bool endDrawerEnableOpenDragGesture;

  /// {@macro flutter.material.scaffold.restorationId}
  final String? restorationId;

  /// Optional async presentation state for the scaffold body.
  final PlusAsyncState<T>? state;

  /// Builds successful async content. Required for useful success rendering
  /// when [state] is non-null.
  final PlusAsyncDataBuilder<T>? bodyBuilder;

  /// Optional predicate that marks success data as empty.
  final PlusAsyncEmptyPredicate<T>? isEmpty;

  /// Optional retry callback for the default error UI.
  final VoidCallback? onRetry;

  /// Optional loading UI override.
  final WidgetBuilder? loadingBuilder;

  /// Optional empty UI override.
  final WidgetBuilder? emptyBuilder;

  /// Optional error UI override.
  final PlusAsyncErrorBuilder? errorBuilder;

  /// When true and [loadingBuilder] is null, show a default skeleton.
  final bool useSkeleton;

  /// Optional custom skeleton for the loading state.
  final WidgetBuilder? skeletonBuilder;

  /// Enables the optional connectivity banner overlay.
  final bool connectivityBanner;

  /// Optional connectivity snapshot. Prefer reachability-aware values.
  final bool? isConnected;

  /// Optional live connectivity updates. Prefer reachability-aware values.
  final Stream<bool>? connectivityStream;

  /// Appearance and behavior for the connectivity banner.
  final PlusConnectivityConfig connectivityBannerConfig;

  /// Optional custom connectivity banner builder.
  final PlusConnectivityBannerBuilder? connectivityBannerBuilder;

  Widget? get _resolvedBody {
    final asyncState = state;
    if (asyncState == null) {
      return body;
    }

    return PlusAsyncBody<T>(
      state: asyncState,
      builder: bodyBuilder ?? (context, data) => const SizedBox.shrink(),
      isEmpty: isEmpty,
      onRetry: onRetry,
      loadingBuilder: loadingBuilder,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      useSkeleton: useSkeleton,
      skeletonBuilder: skeletonBuilder,
    );
  }

  Widget _buildScaffold() {
    final resolvedBody = _resolvedBody;
    final scrimBuilder = bottomSheetScrimBuilder;

    if (scrimBuilder != null) {
      return Scaffold(
        appBar: appBar,
        body: resolvedBody,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        floatingActionButtonAnimator: floatingActionButtonAnimator,
        persistentFooterButtons: persistentFooterButtons,
        persistentFooterAlignment: persistentFooterAlignment,
        persistentFooterDecoration: persistentFooterDecoration,
        drawer: drawer,
        onDrawerChanged: onDrawerChanged,
        endDrawer: endDrawer,
        onEndDrawerChanged: onEndDrawerChanged,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        primary: primary,
        drawerDragStartBehavior: drawerDragStartBehavior,
        extendBody: extendBody,
        drawerBarrierDismissible: drawerBarrierDismissible,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        drawerScrimColor: drawerScrimColor,
        bottomSheetScrimBuilder: scrimBuilder,
        drawerEdgeDragWidth: drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
        endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
        restorationId: restorationId,
      );
    }

    return Scaffold(
      appBar: appBar,
      body: resolvedBody,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      persistentFooterAlignment: persistentFooterAlignment,
      persistentFooterDecoration: persistentFooterDecoration,
      drawer: drawer,
      onDrawerChanged: onDrawerChanged,
      endDrawer: endDrawer,
      onEndDrawerChanged: onEndDrawerChanged,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      extendBody: extendBody,
      drawerBarrierDismissible: drawerBarrierDismissible,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = _buildScaffold();
    if (!connectivityBanner) {
      return scaffold;
    }

    return PlusConnectivityOverlay(
      isConnected: isConnected,
      connectivityStream: connectivityStream,
      config: connectivityBannerConfig,
      bannerBuilder: connectivityBannerBuilder,
      child: scaffold,
    );
  }
}
