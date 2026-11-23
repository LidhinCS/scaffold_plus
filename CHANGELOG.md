# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `PlusMaintenanceMode` full-page maintenance presentation (app-owned flag).
- `ScaffoldPlus.maintenanceMode` / `maintenanceBuilder` — replaces body and
  suppresses FAB; takes priority over async `state` and `body`.
- `PlusPermissionState` permission denied / request presentation (app-owned
  status; optional secondary action).
- `ScaffoldPlus.permissionDenied` / `permissionBuilder` — same body/FAB
  behavior; after maintenance, before async/`body`.
- `PlusSessionExpired` session-expired presentation (app-owned auth flag).
- `ScaffoldPlus.sessionExpired` / `sessionExpiredBuilder` — after maintenance,
  before permission.
- `ScaffoldPlus.onRefresh` / `onRefreshError` and matching `PlusAsyncView`
  APIs — pull-to-refresh on async success / empty via `PlusRefreshIndicator`.

### Added

- `PlusInternetChecker` / `PlusInternetCheckerConfig` — plugin-free reachability
  probe (HTTP on IO, browser online signal on web).
- `ScaffoldPlus` / `PlusConnectivityOverlay`: `useBuiltInInternetCheck` (default
  true) and `internetCheckerConfig`. Custom `isConnected` /
  `connectivityStream` still win when provided.

### Changed

- `PlusSnackbar` — tone icon badge with spring entrance, softer floating card
  chrome (radius / elevation / padding).
- `PlusDialog` / `PlusConfirmationDialog` — icon header, rounded surface, and
  scale+fade route transition; destructive confirm uses filled error action.
- `PlusConnectivityBanner` — animated icon badge and softer card defaults.

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
