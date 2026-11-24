# Getting started

Install UI Plus, show your first screen, then optionally wire global toasts and
run the Pulse Tasks example.

## Requirements

- Flutter `>=3.47.0`
- Dart `^3.13.0`

## 1. Install

UI Plus **0.6.0+** uses the standalone
[`material_ui`](https://pub.dev/packages/material_ui) package (Flutter 3.47+),
not `package:flutter/material.dart`. Migrating an app:

```sh
dart pub add ui_plus material_ui
dart fix --apply --code=migrate_design_widgets
```

```dart
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';
```

## 2. First screen

=== "Plain body"

    ```dart
    ScaffoldPlus<void>(
      appBar: AppBar(title: const Text('Home')),
      body: const HomeView(),
    )
    ```

=== "Async body"

    ```dart
    ScaffoldPlus<List<Item>>(
      appBar: AppBar(title: const Text('Items')),
      state: state, // PlusAsyncState<List<Item>>
      useSkeleton: true,
      isEmpty: (items) => items.isEmpty,
      onRetry: reload,
      onRefresh: reload,
      bodyBuilder: (context, items) => ListView(
        children: [
          for (final item in items) ListTile(title: Text(item.name)),
        ],
      ),
    )
    ```

`PlusAsyncState` is a sealed hierarchy: `PlusLoading`, `PlusSuccess(data)`,
`PlusFailure(error)`. Prefer mapping domain state into it once at the UI edge —
see [State management](guides/state-management.md).

## 3. Theme defaults (optional)

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
  home: const HomePage(),
)
```

## 4. Global toasts (optional)

Wire [PlusToastHost](guides/feedback.md#global-toasts-optional) once so Cubits /
services can call `PlusSnackbar` without a `BuildContext`. Skip if you always
pass `context:` at the call site:

```dart
MaterialApp(
  scaffoldMessengerKey: PlusToastHost.messengerKey,
  builder: (context, child) => PlusToastHost(child: child!),
  home: const HomePage(),
);

// anywhere after the host is mounted
PlusSnackbar.success(message: 'Saved');
```

Contextual calls still work: `PlusSnackbar.success(context: context, message: '…')`.

## 5. Run Pulse Tasks

The package example is a **real Bloc inbox**, not a widget catalog.

```sh
git clone https://github.com/LidhinCS/ui_plus.git
cd ui_plus/example
flutter pub get
flutter run
```

| Tab | What to try |
| --- | --- |
| **Tasks** | Search, pull-to-refresh, load more, create, complete, delete |
| **Activity** | Timeline fed by repository events |
| **Settings** | Developer gates — maintenance, session, permission, force offline |

[Pulse Tasks walkthrough →](example/pulse-tasks.md)

## Next steps

1. [ScaffoldPlus](guides/scaffold-plus.md) — gates, refresh, connectivity
2. [Feedback & toasts](guides/feedback.md) — snackbars and dialogs
3. [Lists, search & shell](guides/productivity.md) — paging and adaptive nav
