# UI Plus example

Minimal Flutter app that depends on the local `ui_plus` package (`v0.4.0`).

```sh
cd example
flutter run
```

Demos currently cover:

- `ScaffoldPlus` (plain + async modes)
- `PlusAsyncView`
- `PlusEmptyState` / `PlusErrorState`
- `PlusLoader` / `PlusSkeleton`
- Connectivity (`ScaffoldPlus` banner, `PlusConnectivityBuilder`,
  `PlusOfflineState`, `PlusConnectivityBanner`)
- Feedback screenflow (toast → dialog → confirm → banner)
- `PlusSnackbar`
- `PlusDialog` / `PlusConfirmationDialog`
- `PlusBottomSheet`
- `PlusSearchField`
- `PlusRefreshIndicator` / `PlusTheme`
- `PlusAsyncButton`
- `PlusPagedList`
- `PlusAdaptiveScaffold`
- `PlusMaintenanceMode` / `ScaffoldPlus.maintenanceMode`
- `PlusPermissionState` / `ScaffoldPlus.permissionDenied`
- `PlusSessionExpired` / `ScaffoldPlus.sessionExpired`
- `ScaffoldPlus.onRefresh` (pull-to-refresh on async success)
