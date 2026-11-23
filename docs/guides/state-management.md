# State management

UI Plus is **architecture-agnostic**. Your Bloc / Cubit / Riverpod / `setState`
owns domain state; map it to presentation types at the UI edge.

!!! tip "Seen in Pulse Tasks"
    `TasksCubit` stores `PlusAsyncState` on the domain state object and
    `TasksPage` passes `state: tasksState.status` into `ScaffoldPlus`.
    [Full walkthrough →](../example/pulse-tasks.md)

## Rules of thumb

1. **One owner** of domain state (Cubit / notifier / service)
2. **One map** into `PlusAsyncState` (avoid parallel `isLoading` + `error` + `data`)
3. **Product gates** (`sessionExpired`, etc.) are plain bools from the same app layer
4. **Feedback** can be global via `PlusToastHost` so Cubits never need `BuildContext`

## Bloc / Cubit

=== "Map in the widget"

    ```dart
    BlocBuilder<ItemsCubit, ItemsState>(
      builder: (context, state) {
        return ScaffoldPlus<List<Item>>(
          state: switch (state) {
            ItemsLoading() => const PlusLoading(),
            ItemsSuccess(:final items) => PlusSuccess(items),
            ItemsFailure(:final error) => PlusFailure(error),
          },
          onRetry: () => context.read<ItemsCubit>().load(),
          onRefresh: () => context.read<ItemsCubit>().load(),
          bodyBuilder: (context, items) => ItemList(items: items),
        );
      },
    )
    ```

=== "Pulse Tasks style"

    Store presentation state on the Cubit state, map once when emitting:

    ```dart
    // tasks_cubit.dart
    emit(state.copyWith(status: const PlusLoading()));
    // ...
    emit(state.copyWith(status: PlusSuccess(page.items), items: page.items));
    // ...
    PlusSnackbar.success(message: 'Created “${task.title}”'); // global toast
    ```

    ```dart
    // tasks_page.dart
    ScaffoldPlus<List<Task>>(
      state: tasksState.status,
      bodyBuilder: (context, items) => /* ... */,
    )
    ```

## Riverpod

```dart
final asyncItems = ref.watch(itemsProvider);

return ScaffoldPlus<List<Item>>(
  state: asyncItems.when(
    loading: () => const PlusLoading(),
    error: (e, st) => PlusFailure(e, stackTrace: st),
    data: PlusSuccess.new,
  ),
  onRetry: () => ref.invalidate(itemsProvider),
  bodyBuilder: (context, items) => ItemList(items: items),
);
```

## Product gates + shell state

Keep session / maintenance / permission flags next to navigation (as Pulse
Tasks does with `AppShellCubit`), then pass them into `ScaffoldPlus`:

```dart
ScaffoldPlus(
  maintenanceMode: shell.maintenanceMode,
  sessionExpired: !shell.isSignedIn,
  permissionDenied: !notificationsAllowed,
  state: asyncState,
  bodyBuilder: ...,
)
```

## What stays out of core

Companion packages (e.g. a future `ui_plus_bloc` mapper) may appear later.
**Core will not depend** on Bloc, Riverpod, Provider, or GetX.

## See also

- [Pulse Tasks](../example/pulse-tasks.md) — end-to-end Cubit mapping
- [ScaffoldPlus](scaffold-plus.md) — async + gates API
- [Feedback & toasts](feedback.md) — context-free snackbars
