# ScaffoldPlus

Drop-in `Scaffold` replacement with optional async body, connectivity banner,
and product-state gates.

## Body precedence

1. `maintenanceMode`
2. `sessionExpired`
3. `permissionDenied`
4. Async `state` (when non-null)
5. `body`

Product states suppress the FAB.

## Async body

```dart
ScaffoldPlus<User>(
  state: state,
  isEmpty: (user) => user.items.isEmpty,
  onRetry: reload,
  onRefresh: reload,
  onRefreshError: (error, stack) {
    PlusSnackbar.error(context, message: 'Refresh failed');
  },
  bodyBuilder: (context, user) => UserProfile(user: user),
)
```

`onRefresh` wraps success / empty content in `PlusRefreshIndicator`. Success
content should be scrollable (e.g. `ListView`).

## Product states

```dart
ScaffoldPlus(
  maintenanceMode: isDown,
  sessionExpired: !isSignedIn,
  permissionDenied: !cameraGranted,
  permissionBuilder: (_) => PlusPermissionState(
    title: 'Camera access needed',
    actionLabel: 'Open settings',
    onAction: openAppSettings,
  ),
  body: const CameraPage(),
)
```

Standalone widgets: `PlusMaintenanceMode`, `PlusSessionExpired`,
`PlusPermissionState`.

## Connectivity

```dart
ScaffoldPlus(
  connectivityBanner: true, // built-in PlusInternetChecker by default
  body: child,
)
```

Custom `isConnected` / `connectivityStream` always win. See
[Connectivity](connectivity.md).

## Independent pieces

Prefer these when you already have a `Scaffold`:

- `PlusAsyncView` — same async renderer as `ScaffoldPlus`
- `PlusEmptyState` / `PlusErrorState` / `PlusLoader` / `PlusSkeleton`
