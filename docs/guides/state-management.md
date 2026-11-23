# State management

UI Plus stays **architecture-agnostic**. Your Bloc / Cubit / Riverpod / etc.
owns domain state; map it to presentation types at the UI edge.

## Bloc / Cubit

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

## Rules of thumb

- One owner of domain state (the Cubit / notifier)
- One map into `PlusAsyncState` (avoid parallel `isLoading` + `error` + `data`)
- Product gates (`sessionExpired`, etc.) come from the same app layer as bools

Companion packages (e.g. `ui_plus_bloc`) may appear later for shared mappers —
core will not depend on a state-management library.
