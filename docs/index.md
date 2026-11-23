# UI Plus

<div class="feature-kicker">Flutter UI toolkit</div>

**More power to your Flutter UI** — async scaffolds, connectivity, feedback,
and product-state patterns without locking you into a state-management library.

<div class="hero-actions" markdown>
[Get started](getting-started.md){ .md-button .md-button--primary }
[Run Pulse Tasks](example/pulse-tasks.md){ .md-button }
[API reference](reference.md){ .md-button }
</div>

## What you get

<div class="grid cards" markdown>

-   :material-view-dashboard: **ScaffoldPlus**

    ---

    Drop-in `Scaffold` with async body, pull-to-refresh, connectivity banner,
    and maintenance / session / permission gates.

-   :material-puzzle: **Composable pieces**

    ---

    Use `PlusAsyncView`, empty/error/loader/skeleton, snackbars, dialogs, and
    lists on their own — no all-or-nothing adoption.

-   :material-vector-polyline: **Architecture-agnostic**

    ---

    Map Bloc, Riverpod, or plain `setState` to `PlusAsyncState` at the UI edge.
    Core never depends on those packages.

-   :material-cellphone-link: **Built-in reachability**

    ---

    Plugin-free internet probe with optional custom `bool` / `Stream<bool>`.
    Custom sources always win.

</div>

## Flagship pattern

```dart
ScaffoldPlus<List<Item>>(
  appBar: AppBar(title: const Text('Items')),
  state: state, // PlusLoading | PlusSuccess | PlusFailure
  useSkeleton: true,
  isEmpty: (items) => items.isEmpty,
  onRetry: reload,
  onRefresh: reload,
  connectivityBanner: true,
  bodyBuilder: (context, items) => ItemList(items: items),
)
```

## Learn by running the example

**Pulse Tasks** is a real Bloc-powered inbox that wires the package end-to-end:
paging, search, global toasts, adaptive navigation, and developer toggles for
product states.

```sh
cd example && flutter pub get && flutter run
```

Then open **Settings → Developer gates**.

[Full Pulse Tasks walkthrough →](example/pulse-tasks.md)

## Guides

| Guide | Use it when you need… |
| --- | --- |
| [Getting started](getting-started.md) | Install, first screen, theme, toast host |
| [ScaffoldPlus](guides/scaffold-plus.md) | Async body, gates, refresh |
| [Connectivity](guides/connectivity.md) | Built-in or custom online/offline UI |
| [Feedback & toasts](guides/feedback.md) | Snackbars (incl. global), dialogs |
| [State management](guides/state-management.md) | Bloc / Riverpod → `PlusAsyncState` |
| [Lists, search & shell](guides/productivity.md) | Paged lists, search, adaptive nav, async buttons |

## Links

- [pub.dev/packages/ui_plus](https://pub.dev/packages/ui_plus)
- [GitHub](https://github.com/LidhinCS/ui_plus)
- [Example source](https://github.com/LidhinCS/ui_plus/tree/main/example)
