# Feedback UI

Polished snackbars, dialogs, and connectivity banners — Material 3 with motion.

## Snackbars

```dart
PlusSnackbar.success(context, message: 'Saved');
PlusSnackbar.error(context, message: 'Could not sync');
PlusSnackbar.info(
  context,
  message: 'Draft discarded',
  actionLabel: 'Undo',
  onAction: restore,
);
```

Tone icon badge, floating card chrome, optional `showIcon: false`.

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

Scale + fade entrance and icon headers.

## Banners

Used by `PlusConnectivityOverlay` / `ScaffoldPlus.connectivityBanner`. Soft card
chrome with an animated icon badge.

## Example screenflow

In the example app, open **Feedback screenflow** for a guided tour:
toast → dialog → confirm → banner.
