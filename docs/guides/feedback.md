# Feedback & toasts

Material 3 snackbars, dialogs, and connectivity banners with polished motion.

!!! tip "Seen in Pulse Tasks"
    Cubits call `PlusSnackbar.success(message: …)` with no context after
    `PlusToastHost` is wired in `main.dart`. Deletes use
    `PlusConfirmationDialog`; compose uses `PlusBottomSheet` + `PlusAsyncButton`.

## Snackbars

=== "With context"

    ```dart
    PlusSnackbar.success(context: context, message: 'Saved');
    PlusSnackbar.error(context: context, message: 'Could not sync');
    PlusSnackbar.info(
      context: context,
      message: 'Draft discarded',
      actionLabel: 'Undo',
      onAction: restore,
    );
    ```

=== "Global (no context)"

    ```dart
    PlusSnackbar.success(message: 'Saved');
    PlusSnackbar.error(message: 'Could not sync');
    PlusSnackbar.hide();
    PlusSnackbar.clear();
    ```

Tone icon badge, floating card chrome, optional `showIcon: false`.

## PlusFeedback (result helper)

Maps operation outcomes so call sites do not repeat snackbar / dialog wiring:

```dart
await PlusFeedback.run(
  context: context, // optional with PlusToastHost for snackbars
  action: () => repository.save(item),
  successMessage: 'Saved',
);

await PlusFeedback.result(
  error: failure, // null → success path
  successMessage: 'Done',
  mapError: (e) => 'Could not save: $e',
);

await PlusFeedback.failure(
  context: context,
  error: exception,
  blocking: true, // PlusDialog instead of snackbar
  title: 'Could not complete',
);
```

| API | Role |
| --- | --- |
| `success` | Success snackbar |
| `failure` / `exception` | Error snackbar, or blocking dialog when `blocking: true` |
| `result` | `error == null` → success message; else failure |
| `run` | Await action; report success / failure; optional `rethrowError` |

### Global toasts (optional)

Wire the host once (toastification-style). Call sites can omit `context`:

```dart
MaterialApp(
  scaffoldMessengerKey: PlusToastHost.messengerKey, // optional but explicit
  builder: (context, child) => PlusToastHost(child: child!),
  home: const HomePage(),
);
```

| Setup | Result |
| --- | --- |
| `PlusToastHost` via `MaterialApp.builder` | Attaches the ambient `ScaffoldMessenger` |
| `scaffoldMessengerKey: PlusToastHost.messengerKey` | Key-only fallback without the host widget |
| Neither | Contextual `context:` argument required |

!!! note "Dialogs stay contextual"
    Only toasts are global. `PlusDialog` / `PlusConfirmationDialog` still need a
    `BuildContext` (navigator).

## UI error boundary

Replace Flutter’s red `ErrorWidget` with `PlusErrorState` styling:

```dart
void main() {
  PlusErrorBoundary.install(); // debug shows exception text; release stays calm
  runApp(const MyApp());
}
```

| API | Role |
| --- | --- |
| `PlusErrorBoundary.install` | Sets global `ErrorWidget.builder` |
| `PlusErrorBoundary.uninstall` | Restores the previous builder (tests) |
| `PlusErrorBoundaryView` | Default / reusable presentable layout |

Catches build/layout/paint failures that become an `ErrorWidget`. Pair with
`FlutterError.onError` in the app if you need crash reporting — core stays
presentation-only.

## Dialogs

```dart
await PlusDialog.alert(
  context,
  title: 'Offline',
  message: 'Connect and try again.',
);

final ok = await PlusConfirmationDialog.show(
  context,
  title: 'Delete item?',
  message: 'This cannot be undone.',
  confirmLabel: 'Delete',
  isDestructive: true,
);
```

Scale + fade entrance and icon headers. Destructive confirm uses a filled
error action.

## Bottom sheets

```dart
await PlusBottomSheet.show(
  context: context,
  title: 'New task',
  isScrollControlled: true,
  builder: (context) => const ComposeForm(),
);
```

## Banners

`PlusConnectivityBanner` / host used by `ScaffoldPlus.connectivityBanner` —
soft card chrome with an animated icon badge.

## See also

- [Pulse Tasks](../example/pulse-tasks.md) — global toasts from Cubits
- [Getting started](../getting-started.md#4-global-toasts-optional) — host setup
- [ScaffoldPlus](scaffold-plus.md) — `onRefreshError` + snackbars
