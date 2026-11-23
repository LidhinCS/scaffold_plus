import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ui_plus/src/async/plus_async_body.dart';
import 'package:ui_plus/src/async/plus_async_state.dart';
import 'package:ui_plus/src/async/plus_async_types.dart';
import 'package:ui_plus/src/connectivity/plus_connectivity_config.dart';
import 'package:ui_plus/src/connectivity/plus_connectivity_overlay.dart';
import 'package:ui_plus/src/connectivity/plus_internet_checker.dart';
import 'package:ui_plus/src/states/plus_maintenance_mode.dart';
import 'package:ui_plus/src/states/plus_permission_state.dart';
import 'package:ui_plus/src/states/plus_session_expired.dart';

/// A drop-in [Scaffold] replacement with optional async body rendering,
/// optional connectivity banners, and optional product-state overlays.
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
/// - Optional [onRefresh] wraps success / empty async content in pull-to-refresh.
///
/// ## Product states
///
/// Opt in with [maintenanceMode], [sessionExpired], or [permissionDenied].
/// When active, the body is replaced and the FAB is suppressed. Precedence:
/// maintenance → session expired → permission → async [state] → [body].
///
/// ## Connectivity
///
/// Opt in with [connectivityBanner]. By default a built-in
/// [PlusInternetChecker] probes reachability (no plugin). Pass
/// [isConnected] and/or [connectivityStream] to use your own source instead —
/// custom values always win. Set [useBuiltInInternetCheck] to false to disable
/// the built-in checker when no custom source is provided.
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
    this.onRefresh,
    this.onRefreshError,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.useSkeleton = false,
    this.skeletonBuilder,
    this.maintenanceMode = false,
    this.maintenanceBuilder,
    this.sessionExpired = false,
    this.sessionExpiredBuilder,
    this.permissionDenied = false,
    this.permissionBuilder,
    this.connectivityBanner = false,
    this.isConnected,
    this.connectivityStream,
    this.useBuiltInInternetCheck = true,
    this.internetCheckerConfig = const PlusInternetCheckerConfig(),
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

  /// Optional pull-to-refresh for async success / empty content.
  ///
  /// Ignored when [state] is null. Success [bodyBuilder] content should be
  /// scrollable (e.g. [ListView]).
  final Future<void> Function()? onRefresh;

  /// Optional error handler for [onRefresh] failures.
  final void Function(Object error, StackTrace stackTrace)? onRefreshError;

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

  /// When true, replaces the body with maintenance UI and hides the FAB.
  ///
  /// Takes priority over [state] and [body]. The app owns the flag (remote
  /// config, feature flag, etc.).
  final bool maintenanceMode;

  /// Optional custom maintenance UI. Defaults to [PlusMaintenanceMode].
  final WidgetBuilder? maintenanceBuilder;

  /// When true, replaces the body with session-expired UI and hides the FAB.
  ///
  /// Takes priority over [permissionDenied], [state], and [body], but not over
  /// [maintenanceMode]. The app owns the flag (auth layer).
  final bool sessionExpired;

  /// Optional custom session-expired UI. Defaults to [PlusSessionExpired].
  final WidgetBuilder? sessionExpiredBuilder;

  /// When true, replaces the body with permission UI and hides the FAB.
  ///
  /// Takes priority over [state] and [body], but not over [maintenanceMode] or
  /// [sessionExpired]. The app owns the flag (permission plugin / OS status).
  final bool permissionDenied;

  /// Optional custom permission UI. Defaults to [PlusPermissionState].
  final WidgetBuilder? permissionBuilder;

  /// Enables the optional connectivity banner overlay.
  final bool connectivityBanner;

  /// Optional custom connectivity snapshot.
  ///
  /// When set (alone or with [connectivityStream]), built-in checking is
  /// skipped.
  final bool? isConnected;

  /// Optional custom live connectivity updates.
  ///
  /// When set, built-in checking is skipped.
  final Stream<bool>? connectivityStream;

  /// When true and no custom [isConnected] / [connectivityStream] is provided,
  /// uses the built-in [PlusInternetChecker].
  final bool useBuiltInInternetCheck;

  /// Configuration for the built-in internet checker.
  final PlusInternetCheckerConfig internetCheckerConfig;

  /// Appearance and behavior for the connectivity banner.
  final PlusConnectivityConfig connectivityBannerConfig;

  /// Optional custom connectivity banner builder.
  final PlusConnectivityBannerBuilder? connectivityBannerBuilder;

  bool get _blocksContent =>
      maintenanceMode || sessionExpired || permissionDenied;

  Widget? get _resolvedBody {
    if (maintenanceMode) {
      return Builder(
        builder: (context) =>
            maintenanceBuilder?.call(context) ?? const PlusMaintenanceMode(),
      );
    }

    if (sessionExpired) {
      return Builder(
        builder: (context) =>
            sessionExpiredBuilder?.call(context) ?? const PlusSessionExpired(),
      );
    }

    if (permissionDenied) {
      return Builder(
        builder: (context) =>
            permissionBuilder?.call(context) ?? const PlusPermissionState(),
      );
    }

    final asyncState = state;
    if (asyncState == null) {
      return body;
    }

    return PlusAsyncBody<T>(
      state: asyncState,
      builder: bodyBuilder ?? (context, data) => const SizedBox.shrink(),
      isEmpty: isEmpty,
      onRetry: onRetry,
      onRefresh: onRefresh,
      onRefreshError: onRefreshError,
      loadingBuilder: loadingBuilder,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      useSkeleton: useSkeleton,
      skeletonBuilder: skeletonBuilder,
    );
  }

  Widget? get _resolvedFab => _blocksContent ? null : floatingActionButton;

  Widget _buildScaffold() {
    final resolvedBody = _resolvedBody;
    final resolvedFab = _resolvedFab;
    final scrimBuilder = bottomSheetScrimBuilder;

    if (scrimBuilder != null) {
      return Scaffold(
        appBar: appBar,
        body: resolvedBody,
        floatingActionButton: resolvedFab,
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
      floatingActionButton: resolvedFab,
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
      useBuiltInInternetCheck: useBuiltInInternetCheck,
      internetCheckerConfig: internetCheckerConfig,
      config: connectivityBannerConfig,
      bannerBuilder: connectivityBannerBuilder,
      child: scaffold,
    );
  }
}
