# Scaffold Plus

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

Reusable Flutter building blocks for common application states and layouts,
without locking developers into an architecture.

## Goals

- Architecture-agnostic core (no Bloc, Riverpod, Provider, GetX, or networking clients)
- Composable widgets that work independently
- Flutter-native APIs with Material 3 theming and accessibility in mind
- Lightweight, tested, and documented public surface

## Status

**v0.2.0** — core foundation plus plugin-free connectivity UI. Primary entry is
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

See [plan.md](plan.md) (summary: [doc/roadmap.md](doc/roadmap.md)) for the
release plan. Connectivity design notes: [doc/connectivity.md](doc/connectivity.md).

## Installation 💻

**❗ In order to start using Scaffold Plus you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

Supported versions match `pubspec.yaml` (`Flutter ^3.47.0`, `Dart ^3.13.0`).

Install via `dart pub add`:

```sh
dart pub add scaffold_plus
```

```dart
import 'package:scaffold_plus/scaffold_plus.dart';
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

Drop-in replacement for Flutter's `Scaffold` with optional async body
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

---

## Continuous Integration 🤖

Scaffold Plus comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_workflows_link].

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
3. Export public APIs from `lib/scaffold_plus.dart` only.
4. Update the example app and this README when APIs change.
5. Run format, analyze, and tests before opening a PR.

## License

MIT — see [LICENSE](LICENSE).

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style:very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
