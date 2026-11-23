# Getting started

## Requirements

- Flutter `>=3.47.0`
- Dart `^3.13.0`

## Install

```sh
dart pub add ui_plus
```

```dart
import 'package:ui_plus/ui_plus.dart';
```

## First screen

Plain scaffold (no async):

```dart
ScaffoldPlus<void>(
  appBar: AppBar(title: const Text('Home')),
  body: const HomeView(),
)
```

Async scaffold:

```dart
ScaffoldPlus<List<Item>>(
  appBar: AppBar(title: const Text('Items')),
  state: state,
  useSkeleton: true,
  isEmpty: (items) => items.isEmpty,
  onRetry: reload,
  onRefresh: reload,
  bodyBuilder: (context, items) => ListView(
    children: [for (final item in items) ListTile(title: Text(item.name))],
  ),
)
```

## Theme defaults (optional)

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    extensions: const [
      PlusTheme(
        snackbarDuration: Duration(seconds: 3),
        searchDebounceDuration: Duration(milliseconds: 300),
      ),
    ],
  ),
  home: const MyApp(),
)
```

## Try the example

```sh
git clone https://github.com/LidhinCS/ui_plus.git
cd ui_plus/example
flutter run
```

Open **Feedback screenflow** and **Connectivity** demos to see polished UI and
built-in reachability.
