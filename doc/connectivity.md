# Connectivity UI

UI Plus provides connectivity **presentation** only. The core package does not
depend on `connectivity_plus` or any networking client.

## Supplying status

Pass:

- `isConnected: bool` and/or
- `connectivityStream: Stream<bool>`

For reliable “internet available” UX, the boolean should represent
**reachability** (e.g. a lightweight probe), not merely Wi-Fi/mobile
association.

## Behavior

- First status is applied silently (no “Connection restored” on launch).
- Offline banner stays until connectivity returns.
- Online banner can auto-hide (default 2 seconds).
- Changes are debounced (default 300ms) to reduce flicker.
- Overlay uses a `Stack` so the body does not resize.

## ScaffoldPlus

```dart
ScaffoldPlus(
  connectivityBanner: true,
  isConnected: isConnected,
  connectivityStream: stream,
  body: child,
)
```

Async `state` / `bodyBuilder` continue to work independently under the same
scaffold.
