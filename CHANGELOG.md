# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-11-23

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
- Example app demos for scaffold-plus, async view, and state widgets.
- Product-oriented package description and public entry-point docs.
- `CHANGELOG.md`, `doc/roadmap.md`, `plan.md`, and Cursor project rules.

### Changed

- Replaced the temporary `ScaffoldPlus` marker class with a real widget API
  (**breaking** for the placeholder-only constructor).
- Adapted the Very Good Flutter Package template toward `scaffold_plus`
  product goals while preserving VGV analysis, testing, and CI workflows.
