# Connectivity

Presentation helpers plus an optional **plugin-free** reachability probe.
There is no `connectivity_plus` dependency in core.

!!! tip "Seen in Pulse Tasks"
    Settings → **Force offline** sets `isConnected: false` so the banner
    appears without waiting for a real network drop.
    [Walkthrough →](../example/pulse-tasks.md)

## Quick start on ScaffoldPlus

```dart
ScaffoldPlus(
  connectivityBanner: true,
  internetCheckerConfig: const PlusInternetCheckerConfig(
    interval: Duration(seconds: 8),
  ),
  body: child,
)
```

| Platform | Built-in behavior |
| --- | --- |
| IO (mobile / desktop) | HTTP probes (`generate_204`-style endpoints) |
| Web | Assumes online by default (CORS); supply a custom stream for accuracy |

## Custom source (always wins)

```dart
ScaffoldPlus(
  connectivityBanner: true,
  isConnected: isConnected,
  connectivityStream: stream,
  body: child,
)
```

Pulse Tasks uses the same override for the force-offline demo:

```dart
isConnected: shell.forceOffline ? false : null,
useBuiltInInternetCheck: !shell.forceOffline,
```

## Disable built-in without a custom source

```dart
ScaffoldPlus(
  connectivityBanner: true,
  useBuiltInInternetCheck: false,
  body: child,
)
```

## Standalone APIs

```dart
final checker = PlusInternetChecker()..start();
// checker.onStatusChange, checker.isConnected, checker.checkNow()

PlusConnectivityBuilder(
  isConnected: isConnected,
  connectivityStream: stream,
  builder: (context, online) => online ? OnlineView() : OfflineView(),
)

PlusOfflineState(
  onRetry: retry,
)
```

`PlusConnectivityOverlay` / `PlusConnectivityBanner` power the scaffold banner.

## Behavior notes

- First status is silent (avoids a false “restored” flash on launch)
- Offline banner stays until online again
- Online banner can auto-hide via `PlusConnectivityConfig`
- Overlay uses a `Stack` — body layout does not resize

Design deep-dive in the repo:
[`doc/connectivity.md`](https://github.com/LidhinCS/ui_plus/blob/main/doc/connectivity.md).

## See also

- [ScaffoldPlus](scaffold-plus.md) — `connectivityBanner` flag
- [Pulse Tasks](../example/pulse-tasks.md) — force-offline toggle
