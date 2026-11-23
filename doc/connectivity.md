# Connectivity UI

UI Plus provides connectivity **presentation** plus an optional **built-in
reachability checker**. The core package does **not** depend on
`connectivity_plus` or other connectivity plugins.

## Built-in internet check

`PlusInternetChecker` periodically probes lightweight endpoints on IO / mobile /
desktop. On web, endpoint probes are CORS-limited so the default assumes online —
pass a custom stream or same-origin check when you need accurate web offline UX.

```dart
ScaffoldPlus(
  connectivityBanner: true, // uses built-in checker by default
  body: child,
)
```

Tune the checker:

```dart
ScaffoldPlus(
  connectivityBanner: true,
  internetCheckerConfig: const PlusInternetCheckerConfig(
    interval: Duration(seconds: 8),
    timeout: Duration(seconds: 2),
  ),
  body: child,
)
```

Or use it standalone:

```dart
final checker = PlusInternetChecker()..start();
// checker.onStatusChange / checker.isConnected / checker.checkNow()
```

## Custom status (always wins)

Pass your own reachability source to skip the built-in checker:

```dart
ScaffoldPlus(
  connectivityBanner: true,
  isConnected: isConnected,
  connectivityStream: stream,
  body: child,
)
```

Disable built-in checking when you are not supplying a custom source yet:

```dart
ScaffoldPlus(
  connectivityBanner: true,
  useBuiltInInternetCheck: false,
  body: child,
)
```

For reliable “internet available” UX, prefer a reachability probe (built-in or
your own) over Wi-Fi/mobile association alone.

## Behavior

- First status is applied silently (no “Connection restored” on launch).
- Offline banner stays until connectivity returns.
- Online banner can auto-hide (default 2 seconds).
- Changes are debounced (default 300ms) to reduce flicker.
- Overlay uses a `Stack` so the body does not resize.

## ScaffoldPlus

Async `state` / `bodyBuilder` continue to work independently under the same
scaffold.
