# UI Plus

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

**More power to your Flutter UI.**

A collection of reusable Flutter UI components, application states,
connectivity features and productivity utilities — without locking developers
into an architecture.

## Goals

- Architecture-agnostic core (no Bloc, Riverpod, Provider, GetX, or networking clients)
- Composable widgets that work independently
- Flutter-native APIs with Material 3 theming and accessibility in mind
- Lightweight, tested, and documented public surface

## Status

**v0.4.0** Unique application patterns released. Flagship entry is
`ScaffoldPlus`; building blocks remain independently reusable.

| Component | Status |
| --- | --- |
| `ScaffoldPlus` | Available |
| `PlusAsyncView` | Available |
| `PlusConnectivityConfig` | Available |
| `PlusConnectivityBanner` / Overlay | Available |
| `PlusOfflineState` | Available |
| `PlusConnectivityBuilder` | Available |
| `PlusEmptyState` | Available |
| `PlusErrorState` | Available |
| `PlusLoader` | Available |
| `PlusSkeleton` | Available |
| `PlusSnackbar` | Available |
| `PlusDialog` | Available |
| `PlusConfirmationDialog` | Available |
| `PlusBottomSheet` | Available |
| `PlusSearchField` | Available |
| `PlusRefreshIndicator` | Available |
| `PlusTheme` | Available |
| `PlusAsyncButton` | Available |
| `PlusPagedList` | Available |
| `PlusAdaptiveScaffold` | Available |

See [plan.md](plan.md) (summary: [doc/roadmap.md](doc/roadmap.md)) for the
release plan. Connectivity design notes: [doc/connectivity.md](doc/connectivity.md).

## Installation 💻

**❗ In order to start using UI Plus you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

Supported versions match `pubspec.yaml` (`Flutter ^3.47.0`, `Dart ^3.13.0`).

Install via `dart pub add`:

```sh
dart pub add ui_plus
```

```dart
import 'package:ui_plus/ui_plus.dart';
```

## Quick start

Drop-in scaffold (async opt-in):

```dart
ScaffoldPlus<List<Item>>(
  appBar: AppBar(title: const Text('Items')),
  state: state,
  useSkeleton: true,
  isEmpty: (items) => items.isEmpty,
  onRetry: reload,
  bodyBuilder: (context, items) => ItemList(items: items),
)
```

Plain scaffold usage (no async state — `body` works like Flutter's `Scaffold`).
Type argument can be omitted when inference has enough context; otherwise use
`ScaffoldPlus<void>`:

```dart
ScaffoldPlus<void>(
  appBar: AppBar(title: const Text('Home')),
  body: const HomeView(),
)
```

Run the example host for interactive demos:

```sh
cd example
flutter run
```

## Components

### ScaffoldPlus

Flagship drop-in replacement for Flutter's `Scaffold` with optional async body
rendering. Composes a native `Scaffold` internally (so `Scaffold.of` works).

**Solves:** one widget for chrome + loading / empty / error / success.

**Body precedence:** when `state` is `null`, `body` is shown. When `state` is
non-null, async rendering takes priority and `body` is ignored (no assert).

**Async options:** `state`, `bodyBuilder`, `isEmpty`, `onRetry`,
`loadingBuilder`, `emptyBuilder`, `errorBuilder`, `useSkeleton`,
`skeletonBuilder`.

**Skeleton:** `useSkeleton: true` shows a default `PlusSkeleton` layout;
provide `skeletonBuilder` to override. `loadingBuilder` still wins when set.

Shares the same internal async renderer as `PlusAsyncView`.

**Connectivity (opt-in):**

```dart
ScaffoldPlus(
  connectivityBanner: true,
  isConnected: isConnected,
  connectivityStream: connectivityStream, // Stream<bool>
  connectivityBannerConfig: const PlusConnectivityConfig(
    offlineMessage: 'You are currently offline',
    onlineMessage: 'Back online!',
  ),
  body: const HomePage(),
)
```

Core does **not** include a connectivity plugin. Pass a `bool` / `Stream<bool>`
that represents **reachability** when you need a reliable internet indicator
(Wi-Fi association alone is not enough).

### PlusEmptyState

Centered empty-state layout for lists, searches, and similar screens.

**Solves:** consistent empty UI with optional icon/illustration and action.

**Minimal usage:**

```dart
const PlusEmptyState(title: 'Nothing here yet')
```

**Customization:** `description`, `icon` / `illustration`, `iconSize`,
`iconColor`, `actionLabel` + `onAction`, `spacing`, `padding`,
`mainAxisSize`, text styles, and alignment.

**Callbacks:** the action button renders only when both `actionLabel` and
`onAction` are non-null.

**Accessibility:** exposes a semantics label from title + description; action
uses a standard Material button.

**Limitations:** not a full page scaffold — place it inside your own layout.

### PlusErrorState

Centered error-state layout with an optional retry action.

**Solves:** consistent failure UI without coupling to HTTP or error models.

**Minimal usage:**

```dart
const PlusErrorState(title: 'Something went wrong')
```

**Customization:** `message`, `icon` / `illustration`, `iconSize`,
`iconColor` (defaults to `ColorScheme.error`), `actionLabel` + `onRetry`,
`spacing`, `padding`, `mainAxisSize`, text styles, and alignment.

**Callbacks:** the retry button renders only when both `actionLabel` and
`onRetry` are non-null. Map domain errors to display text in the app layer.

**Accessibility:** exposes a semantics label from title + message; retry uses
a standard Material button.

**Limitations:** does not parse exceptions or status codes — pass plain text.

### PlusLoader

Compact circular loading indicator based on `CircularProgressIndicator`.

**Solves:** consistent sized loaders with theme-aware color and semantics.

**Minimal usage:**

```dart
const PlusLoader()
```

**Customization:** `size`, `strokeWidth`, `color`, `backgroundColor`,
`semanticsLabel`.

**Accessibility:** default semantics label is `Loading`.

### PlusSkeleton

Basic shimmer placeholder for composing loading layouts.

**Solves:** lightweight skeleton shapes without shipping preset layouts.

**Minimal usage:**

```dart
const PlusSkeleton(height: 16)
```

**Customization:** `width`, `height`, `borderRadius`, `baseColor`,
`highlightColor`, `animate`, `duration`.

**Accessibility:** animation stops when `MediaQuery.disableAnimations` is
true, or when `animate: false` (useful in tests).

**Limitations:** provide layout by composing multiple skeletons — no
specialized list/card presets yet.

### PlusAsyncView

Switches between loading, failure, empty, and success UI from one sealed
`PlusAsyncState<T>` inside an existing layout/`Scaffold`.

**Solves:** async presentation when you already own the scaffold chrome.

**Minimal usage:**

```dart
PlusAsyncView<User>(
  state: state,
  isEmpty: (user) => user.items.isEmpty,
  onRetry: reload,
  builder: (context, user) => UserProfile(user: user),
)
```

**State model:** public `PlusLoading`, `PlusSuccess`, `PlusFailure`. Empty is
derived via `isEmpty` on success data only. Design notes:
[doc/async_view_design.md](doc/async_view_design.md).

**Precedence:** loading → failure → success (empty predicate) → success body.

**Customization:** `loadingBuilder`, `emptyBuilder`, `errorBuilder`, `onRetry`,
`useSkeleton`, `skeletonBuilder`. Defaults use `PlusLoader` /
`PlusSkeleton`, `PlusEmptyState`, and `PlusErrorState`.

**Limitations:** map Bloc/Riverpod/Future states at the UI boundary — core
stays architecture agnostic. Prefer `ScaffoldPlus` when you want scaffold +
async together.

### Connectivity widgets

Independently reusable UI for offline / restored messaging. Overlay hosts
lifecycle (debounce default 300ms, online auto-hide, no false “restored” on
launch). Banner uses a `Stack` overlay so the body does not resize. Details:
[doc/connectivity.md](doc/connectivity.md).

```dart
PlusConnectivityOverlay(
  isConnected: isConnected,
  connectivityStream: stream,
  config: const PlusConnectivityConfig(
    offlineMessage: 'No internet connection',
    onlineMessage: 'Connection restored',
  ),
  child: child,
)

PlusConnectivityBuilder(
  isConnected: isConnected,
  onlineBuilder: (context) => const HomePage(),
  offlineBuilder: (context) => PlusOfflineState(
    actionLabel: 'Retry',
    onRetry: () {
      /* reload */
    },
  ),
)

const PlusOfflineState(
  title: 'No internet connection',
  message: 'Please check your network and try again.',
)
```

### PlusSnackbar

Theme-aware snackbar helpers for success, info, and error feedback.

**Solves:** consistent Material 3 snackbars without repeating color / action
boilerplate.

**Minimal usage:**

```dart
PlusSnackbar.success(context, message: 'Saved');
PlusSnackbar.error(context, message: 'Something went wrong');
PlusSnackbar.show(
  context,
  message: 'Item deleted',
  actionLabel: 'Undo',
  onAction: restore,
);
```

**Customization:** `tone`, `duration`, `behavior`, `clearCurrent`, colors,
text style, margin/padding/width. Action renders only when both `actionLabel`
and `onAction` are set.

**Limitations:** requires a [ScaffoldMessenger] ancestor (usually from
[MaterialApp] / [Scaffold]).

### PlusDialog

Simple Material 3 alert helpers.

```dart
await PlusDialog.alert(
  context,
  title: 'Offline',
  message: 'Check your connection and try again.',
);
```

**Customization:** `show` accepts `content`, custom `actions`, barrier options,
and text styles. Default action label is `OK`.

### PlusConfirmationDialog

Confirm / cancel dialog that returns a `bool`.

```dart
final confirmed = await PlusConfirmationDialog.show(
  context,
  title: 'Delete item?',
  message: 'This cannot be undone.',
  confirmLabel: 'Delete',
  isDestructive: true,
);
```

Returns `true` on confirm, `false` on cancel or barrier dismiss.

### PlusBottomSheet

Modal bottom-sheet helpers with optional title, drag handle, and safe area.

```dart
await PlusBottomSheet.show(
  context: context,
  title: 'Share',
  builder: (context) => ListTile(
    title: const Text('Copy link'),
    onTap: () => Navigator.pop(context),
  ),
);

await PlusBottomSheet.showScrollable(
  context: context,
  title: 'Choose item',
  builder: (context) => ListView(...),
);
```

**Customization:** `showDragHandle`, `useSafeArea`, `isScrollControlled`,
colors, shape, padding, and `heightFactor` for scrollable sheets.

### PlusSearchField

Search input with optional debounce and a clear button.

```dart
PlusSearchField(
  hintText: 'Search items',
  debounceDuration: const Duration(milliseconds: 300),
  onChanged: (query) => filterItems(query),
  onSubmitted: (query) => runSearch(query),
)
```

**Customization:** controller/focus node, debounce, icons, fill color, border
radius, full `InputDecoration` override. Clear appears when text is non-empty.

**Limitations:** does not search or filter data — emit queries to the app.

### PlusRefreshIndicator

Pull-to-refresh wrapper with theme-aware colors and optional error handling.

```dart
PlusRefreshIndicator(
  onRefresh: reload,
  onError: (error, stack) {
    PlusSnackbar.error(context, message: 'Refresh failed');
  },
  child: ListView(...),
)
```

When `onError` is set, refresh failures are caught and the indicator still
dismisses. Without `onError`, errors are rethrown.

### PlusTheme

Optional `ThemeExtension` for shared UI Plus defaults.

```dart
ThemeData(
  extensions: const [
    PlusTheme(
      snackbarDuration: Duration(seconds: 3),
      searchDebounceDuration: Duration(milliseconds: 300),
    ),
  ],
)
```

Used when arguments are omitted by `PlusSnackbar` (duration),
`PlusSearchField` (debounce), empty/error/offline states (`statePadding`), and
`PlusBottomSheet` (`bottomSheetContentPadding`). Read with
`PlusTheme.of(context)`.

### PlusAsyncButton

Material button that owns in-flight async UX — not a plain `onPressed`.

```dart
PlusAsyncButton(
  onPressed: () async => await saveDraft(),
  successChild: const Text('Saved'),
  onError: (error, stack) {
    PlusSnackbar.error(context, message: 'Save failed');
  },
  child: const Text('Save'),
)
```

While the future is pending the button shows a loader and stays disabled
(prevents double-submit). Optional success flash and `onError` handling.

### PlusPagedList

Infinite / paged list shell. Apps own items and paging flags; the widget
triggers load-more near the end and renders footers.

```dart
PlusPagedList<Item>(
  items: items,
  hasMore: hasMore,
  isLoadingMore: isLoadingMore,
  loadMoreError: error,
  onLoadMore: fetchNextPage,
  onRetryLoadMore: fetchNextPage,
  itemBuilder: (context, item, index) => ListTile(title: Text(item.name)),
)
```

### PlusAdaptiveScaffold

Navigation shell that switches bottom bar ↔ rail by width. Compose
`ScaffoldPlus` (or any body) inside — async/connectivity stay orthogonal.

```dart
PlusAdaptiveScaffold(
  destinations: const [
    PlusNavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    PlusNavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ],
  selectedIndex: index,
  onDestinationSelected: (i) => setState(() => index = i),
  body: pages[index],
)
```

---

## Running Tests 🧪

For first time users, install the [very_good_cli][very_good_cli_link]:

```sh
dart pub global activate very_good_cli
```

To run all unit tests:

```sh
very_good test --coverage
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

You can also use the Flutter tooling directly:

```sh
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## Contributing

1. Keep changes scoped to the current milestone.
2. Add widget tests for every new public component.
3. Export public APIs from `lib/ui_plus.dart` only.
4. Update the example app and this README when APIs change.
5. Run format, analyze, and tests before opening a PR.

## License

MIT — see [LICENSE](LICENSE).

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style:very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
