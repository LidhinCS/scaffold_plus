# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2026-11-24

### Breaking

- Migrated from `package:flutter/material.dart` to
  [`package:material_ui/material_ui.dart`](https://pub.dev/packages/material_ui)
  (Flutter 3.47+ design-library split). Apps must use `material_ui` for
  `MaterialApp` / `ThemeData` / Material widgets that interoperate with
  `ui_plus`. Symbols are the same; they come from a different library.
- Connectivity banner default layout is **inline** and `ScaffoldPlus` hosts it
  in the scaffold **body** (below the app bar), pushing content instead of
  covering it. Use `PlusConnectivityBannerLayout.overlay` for the previous
  floating `Stack` behavior.

### Added

- `PlusConnectivityBannerLayout` (`inline` | `overlay`) on
  `PlusConnectivityConfig`.

### Changed

- Depends on `material_ui` so Flutter 3.47+ / pub.dev static analysis no longer
  flags deprecated in-framework Material imports.
- Docs, README, and Pulse Tasks example updated for `material_ui` + inline
  banners.

### Migration

```sh
dart pub add ui_plus material_ui
dart fix --apply --code=migrate_design_widgets
```

```dart
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';
```

## [0.5.0] - 2026-11-23

### Breaking

- `PlusSnackbar` — `context` is now an optional **named** parameter so global
  calls work as `PlusSnackbar.success(message: '…')` with `PlusToastHost`.
  Update call sites from `success(context, message: …)` to
  `success(context: context, message: …)` (same for `show` / `info` / `error` /
  `hide` / `clear`).

### Added

- `PlusToastHost` — optional root host / `messengerKey` for context-free
  snackbars (toastification-style). Dialogs stay context-based.
- `PlusInternetChecker` / `PlusInternetCheckerConfig` — plugin-free reachability
  probe (HTTP on IO, browser online signal on web).
- `ScaffoldPlus` / `PlusConnectivityOverlay`: `useBuiltInInternetCheck` (default
  true) and `internetCheckerConfig`. Custom `isConnected` /
  `connectivityStream` still win when provided.
- `PlusMaintenanceMode` and `ScaffoldPlus.maintenanceMode` /
  `maintenanceBuilder`.
- `PlusPermissionState` and `ScaffoldPlus.permissionDenied` /
  `permissionBuilder`.
- `PlusSessionExpired` and `ScaffoldPlus.sessionExpired` /
  `sessionExpiredBuilder`.
- `ScaffoldPlus.onRefresh` / `onRefreshError` and matching `PlusAsyncView`
  APIs — pull-to-refresh on async success / empty.
- Example **Pulse Tasks** app — Bloc showcase inbox (paging, search, gates,
  global toasts).
- Docs site (MkDocs) with Pulse Tasks walkthrough + pub.dev screenshots.

### Changed

- `PlusSnackbar` — tone icon badge with spring entrance, softer floating card
  chrome (radius / elevation / padding).
- `PlusDialog` / `PlusConfirmationDialog` — icon header, rounded surface, and
  scale+fade route transition; destructive confirm uses filled error action.
- `PlusConnectivityBanner` — animated icon badge and softer card defaults.
- README focused on package APIs (removed template / tooling noise).

## [0.4.0] - 2026-11-23

### Added

- `PlusAsyncButton` / `PlusAsyncButtonVariant` — awaits a `Future` on press,
  locks against double-submit, optional success flash and `onError`.
- `PlusPagedList` — infinite/paged list shell with load-more threshold and
  loading / error / end footers (app owns items + flags).
- `PlusAdaptiveScaffold` / `PlusNavigationDestination` — navigation bar ↔ rail
  shell by breakpoint; body stays orthogonal to async/connectivity.

### Changed

- Roadmap v0.4.0 pivoted to unique application patterns (not thin Material
  wrappers).

## [0.3.0] - 2026-11-23

### Added

- `PlusSnackbar` / `PlusSnackbarTone` helpers for success, info, and error
  snackbars (Material 3 theme colors, optional action, clear/hide).
- `PlusDialog` alert helpers (`show` / `alert`).
- `PlusConfirmationDialog` confirm/cancel helper returning `bool`, with
  optional destructive confirm styling.
- `PlusBottomSheet` modal helpers (`show` / `showScrollable`) with optional
  title, drag handle, and safe-area defaults.
- `PlusSearchField` search input with optional debounce, clear action, and
  Material 3 theming.
- `PlusRefreshIndicator` pull-to-refresh wrapper with theme colors and optional
  `onError` handling.
- `PlusTheme` (`ThemeExtension`) for shared defaults (snackbar duration, search
  debounce, state/sheet paddings).

### Changed

- README: removed Continuous Integration section from the package docs.
- Empty / error / offline state padding and bottom-sheet content padding fall
  back to `PlusTheme` when omitted.

## [0.2.0] - 2026-11-23

### Changed

- Renamed the Dart package from `scaffold_plus` to `ui_plus` (import
  `package:ui_plus/ui_plus.dart`). Public widget APIs such as `ScaffoldPlus`
  are unchanged. Branding: **UI Plus — More power to your Flutter UI.**

### Added

- Connectivity UI (plugin-free presentation only):
  - `PlusConnectivityConfig` / `PlusConnectivityBannerPosition`
  - `PlusConnectivityBanner`
  - `PlusConnectivityOverlay` (debounce, silent first status, online auto-hide,
    stack overlay so the body does not resize)
  - `PlusOfflineState` (tight-height safe via shared internal layout helper)
  - `PlusConnectivityBuilder`
- Opt-in `ScaffoldPlus` connectivity via `connectivityBanner`, `isConnected`,
  `connectivityStream`, `connectivityBannerConfig`, and
  `connectivityBannerBuilder`.
- Example connectivity demo and `doc/connectivity.md`.

### Notes

- Core does **not** depend on a connectivity plugin. Apps supply `bool` /
  `Stream<bool>` (prefer reachability-aware values).

## [0.1.0] - 2026-11-23

### Added

- `ScaffoldPlus<T>` drop-in `Scaffold` replacement with optional async body.
- Shared internal async renderer used by `ScaffoldPlus` and `PlusAsyncView`.
- Optional skeleton loading via `useSkeleton` / `skeletonBuilder`.
- `PlusEmptyState` empty-state widget with theming, action, and semantics.
- `PlusErrorState` error-state widget with retry, theming, and semantics.
- `PlusLoader` circular loading indicator with theme-aware defaults.
- `PlusSkeleton` composable shimmer placeholder with reduced-motion support.
- `PlusAsyncState` sealed model (`PlusLoading`, `PlusSuccess`, `PlusFailure`)
  and `PlusAsyncView` for async UI switching.
- Example app demos for scaffold, async view, and state widgets.
- Product-oriented package description and public entry-point docs.
- `CHANGELOG.md`, `doc/roadmap.md`, `plan.md`, and Cursor project rules.

### Changed

- Replaced the temporary `ScaffoldPlus` marker class with a real widget API
  (**breaking** for the placeholder-only constructor).
- Adapted the Very Good Flutter Package template toward product goals while
  preserving VGV analysis, testing, and CI workflows.
