# Pulse Tasks (ui_plus example)

A small **Bloc**-powered inbox that showcases `ui_plus` in a real app flow —
not a component catalog.

```sh
cd example
flutter pub get
flutter run
```

## What it demonstrates

| Flow | ui_plus APIs |
| --- | --- |
| Adaptive shell | `PlusAdaptiveScaffold` |
| Tasks inbox | `ScaffoldPlus`, `PlusAsyncState`, skeleton / empty / error, `onRefresh` |
| Search + paging | `PlusSearchField`, `PlusPagedList` |
| Create / delete | `PlusBottomSheet`, `PlusAsyncButton`, `PlusConfirmationDialog` |
| Global toasts | `PlusToastHost`, `PlusSnackbar` (no context from Cubits) |
| Connectivity | Built-in checker + Settings “Force offline” |
| Product gates | Maintenance / session / permission toggles in Settings |
| Activity feed | Second `ScaffoldPlus` + Bloc mapping surface |

## Architecture

- `TaskRepository` — fake API (latency, paging, search, failures)
- `AppShellCubit` — tabs + developer gates
- `TasksCubit` / `ActivityCubit` — domain state
- Widgets map Cubit state → `PlusAsyncState` at the UI edge (core package stays Bloc-free)

Open **Settings → Developer gates** to flip maintenance, notifications, offline,
and to arm a one-shot fetch failure on Tasks.

Full docs walkthrough:
[Pulse Tasks on the docs site](https://lidhincs.github.io/ui_plus/example/pulse-tasks/).
