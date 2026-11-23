# Connectivity

Presentation + optional built-in reachability. **No** `connectivity_plus`
dependency.

## Built-in check

```dart
ScaffoldPlus(
  connectivityBanner: true,
  internetCheckerConfig: const PlusInternetCheckerConfig(
    interval: Duration(seconds: 8),
  ),
  body: child,
)
```

- **IO / mobile / desktop:** HTTP probes (`generate_204` endpoints)
- **Web:** default assumes online (CORS); pass a custom stream for accuracy

Standalone:

```dart
final checker = PlusInternetChecker()..start();
// checker.onStatusChange, checker.isConnected, checker.checkNow()
```

## Custom source (always wins)

```dart
ScaffoldPlus(
  connectivityBanner: true,
  isConnected: isConnected,
  connectivityStream: stream,
  body: child,
)
```

Disable built-in when you are not ready to supply a custom source:

```dart
ScaffoldPlus(
  connectivityBanner: true,
  useBuiltInInternetCheck: false,
  body: child,
)
```

## Behavior

- First status is silent (no false “restored” on launch)
- Offline banner stays until online
- Online banner can auto-hide
- Overlay uses a `Stack` (body does not resize)

Design notes also live in the repo at [`doc/connectivity.md`](https://github.com/LidhinCS/ui_plus/blob/main/doc/connectivity.md).
