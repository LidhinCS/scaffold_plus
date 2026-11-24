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
