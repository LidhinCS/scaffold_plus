# UI Plus

**More power to your Flutter UI.**

A collection of reusable Flutter UI components, application states, connectivity
features, and productivity utilities — without locking you into Bloc, Riverpod,
Provider, or GetX.

## Why UI Plus?

- **Architecture-agnostic** — map your app state at the UI boundary
- **Composable** — use `ScaffoldPlus` or individual widgets
- **Flutter-native** — Material 3, theming, accessibility
- **Lightweight** — no mandatory state-management or connectivity plugins

## Flagship API

```dart
ScaffoldPlus<List<Item>>(
  appBar: AppBar(title: const Text('Items')),
  state: state, // PlusAsyncState
  onRetry: reload,
  onRefresh: reload,
  bodyBuilder: (context, items) => ItemList(items: items),
)
```

## Explore

| Guide | Description |
| --- | --- |
| [Getting started](getting-started.md) | Install and first screen |
| [ScaffoldPlus](guides/scaffold-plus.md) | Async body, product states, refresh |
| [Connectivity](guides/connectivity.md) | Built-in check + custom streams |
| [Feedback UI](guides/feedback.md) | Snackbars, dialogs, banners |
| [State management](guides/state-management.md) | Bloc / Riverpod mapping |
| [API reference](reference.md) | Generated dartdoc |

## Links

- [pub.dev](https://pub.dev/packages/ui_plus)
- [GitHub](https://github.com/LidhinCS/ui_plus)
- [Example app](https://github.com/LidhinCS/ui_plus/tree/main/example)
