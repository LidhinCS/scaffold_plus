# ScaffoldPlus

Drop-in replacement for Flutter's `Scaffold` with optional async body,
connectivity banner, and product-state gates. Composes a native `Scaffold`
internally (`Scaffold.of` still works).

!!! tip "Seen in Pulse Tasks"
    The Tasks and Activity tabs are full `ScaffoldPlus` screens with async
    state, refresh, and gates driven by `AppShellCubit`.
    [Open the walkthrough →](../example/pulse-tasks.md)

## Body precedence

When multiple modes are active, the first match wins:

1. `maintenanceMode`
2. `sessionExpired`
3. `permissionDenied`
4. Async `state` (when non-null)
5. `body`

Product states also suppress the FAB.

## Async body

Pass a `PlusAsyncState<T>` and a `bodyBuilder` for success data:

```dart
ScaffoldPlus<User>(
  state: state,
  useSkeleton: true,
  isEmpty: (user) => user.items.isEmpty,
  onRetry: reload,
  onRefresh: reload,
  onRefreshError: (error, stack) {
    PlusSnackbar.error(context: context, message: 'Refresh failed');
  },
  bodyBuilder: (context, user) => UserProfile(user: user),
)
```

| Parameter | Role |
| --- | --- |
| `state` | `PlusLoading` / `PlusSuccess` / `PlusFailure` |
| `bodyBuilder` | Builds success UI from `T` |
| `isEmpty` | Treats success data as empty → empty state |
| `useSkeleton` | Skeleton instead of spinner while loading |
| `onRetry` | Error-state action |
| `onRefresh` | Wraps success/empty in `PlusRefreshIndicator` |

!!! warning "Scrollable refresh"
    `onRefresh` needs a scrollable success body (e.g. `ListView` /
    `PlusPagedList`). Non-scrollable content will not pull.

When `state != null`, the plain `body` parameter is ignored.

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

Standalone widgets (usable without `ScaffoldPlus`):

- `PlusMaintenanceMode`
- `PlusSessionExpired`
- `PlusPermissionState`

## Connectivity banner

```dart
ScaffoldPlus(
  connectivityBanner: true, // built-in PlusInternetChecker by default
  body: child,
)
```

Custom `isConnected` / `connectivityStream` always win. Details:
[Connectivity](connectivity.md).

## Independent pieces

Already have a `Scaffold`? Use the shared renderer:

- `PlusAsyncView` — same async switching as `ScaffoldPlus`
- `PlusEmptyState` / `PlusErrorState` / `PlusLoader` / `PlusSkeleton`

## See also

- [Pulse Tasks](../example/pulse-tasks.md) — end-to-end gates + async
- [State management](state-management.md) — map Cubit/Riverpod → `PlusAsyncState`
- [Feedback & toasts](feedback.md) — `onRefreshError` UX
