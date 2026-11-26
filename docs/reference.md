# API reference

Generated **dartdoc** for every public export from
`package:ui_plus/ui_plus.dart`.

<div class="hero-actions" markdown>
[Open API docs →](/ui_plus/api/){ .md-button .md-button--primary }
[Browse on GitHub](https://github.com/LidhinCS/ui_plus/tree/main/lib){ .md-button }
</div>

## Public surface (by area)

| Area | Types |
| --- | --- |
| Scaffold & shell | `ScaffoldPlus`, `PlusAdaptiveScaffold`, `PlusNavigationDestination` |
| Async | `PlusAsyncState`, `PlusLoading`, `PlusSuccess`, `PlusFailure`, `PlusAsyncView` |
| Connectivity | `PlusInternetChecker`, `PlusConnectivityOverlay`, `PlusConnectivityBanner`, `PlusConnectivityBuilder`, `PlusOfflineState`, `PlusConnectivityConfig`, `PlusConnectivityBannerLayout`, `PlusConnectivityBannerPosition` |
| Feedback | `PlusSnackbar`, `PlusSnackbarTone`, `PlusToastHost`, `PlusDialog`, `PlusConfirmationDialog`, `PlusBottomSheet` |
| Floating | `PlusFloatingWindowHost`, `PlusFloatingWindowController`, `PlusFloatingWindow` |
| States | `PlusEmptyState`, `PlusErrorState`, `PlusMaintenanceMode`, `PlusSessionExpired`, `PlusPermissionState` |
| Productivity | `PlusPagedList`, `PlusSearchField`, `PlusAsyncButton`, `PlusRefreshIndicator`, `PlusLoader`, `PlusSkeleton`, `PlusTheme` |

## Local regenerate

```sh
mkdocs build -d site
dart doc -o site/api
```

Or with the GitHub Actions [docs](https://github.com/LidhinCS/ui_plus/blob/main/.github/workflows/docs.yaml) workflow on `main`.

## Prefer guides for how-to

Dartdoc is the contract. For patterns and the Pulse Tasks example, start at
[Getting started](getting-started.md) or [Pulse Tasks](example/pulse-tasks.md).
