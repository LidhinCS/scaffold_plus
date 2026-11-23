# Lists, search & shell

Everyday multi-step helpers used heavily by **Pulse Tasks**.

!!! tip "Seen in Pulse Tasks"
    Adaptive tabs, debounced search, infinite task list, compose sheet with
    `PlusAsyncButton`. [Walkthrough →](../example/pulse-tasks.md)

## PlusAdaptiveScaffold

Switches between bottom `NavigationBar` and `NavigationRail` by width.
Body stays app-owned — compose `ScaffoldPlus` inside each tab.

```dart
PlusAdaptiveScaffold(
  destinations: const [
    PlusNavigationDestination(
      icon: Icon(Icons.check_circle_outline),
      label: 'Tasks',
    ),
    PlusNavigationDestination(
      icon: Icon(Icons.settings_outlined),
      label: 'Settings',
    ),
  ],
  selectedIndex: index,
  onDestinationSelected: onSelect,
  body: pages[index],
)
```

| Parameter | Default | Role |
| --- | --- | --- |
| `compactBreakpoint` | `600` | Below → navigation bar |
| `extendRailBreakpoint` | `840` | Rail label type expands |

## PlusPagedList

Infinite / paged list shell. **You** own items and flags; the widget detects
near-end scroll and renders footers.

```dart
PlusPagedList<Task>(
  items: items,
  hasMore: hasMore,
  isLoadingMore: isLoadingMore,
  loadMoreError: loadMoreError,
  onLoadMore: fetchNextPage,
  onRetryLoadMore: fetchNextPage,
  itemBuilder: (context, task, index) => TaskTile(task: task),
)
```

Works well as `ScaffoldPlus.bodyBuilder` content so pull-to-refresh and paging
share one scroll view.

## PlusSearchField

Debounced search input — does not filter for you.

```dart
PlusSearchField(
  hintText: 'Search tasks',
  // null → PlusTheme.searchDebounceDuration
  onChanged: (query) => cubit.search(query),
)
```

## PlusAsyncButton

Owns in-flight UX for async presses (loading lock, optional success flash).

```dart
PlusAsyncButton(
  onPressed: () async => cubit.createTask(title: title),
  onError: (error, stack) {
    PlusSnackbar.error(message: '$error');
  },
  successChild: const Text('Created'),
  child: const Text('Create task'),
)
```

Variants: `filled`, `tonal`, `outlined`, `text`, `elevated`.

## PlusRefreshIndicator

Used directly, or via `ScaffoldPlus.onRefresh` / `PlusAsyncView.onRefresh`.

```dart
PlusRefreshIndicator(
  onRefresh: reload,
  child: ListView(...),
)
```

## PlusTheme

Register once for shared defaults:

```dart
PlusTheme(
  snackbarDuration: Duration(seconds: 3),
  searchDebounceDuration: Duration(milliseconds: 250),
  statePadding: EdgeInsets.all(24),
  bottomSheetContentPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
)
```

## See also

- [Pulse Tasks](../example/pulse-tasks.md)
- [ScaffoldPlus](scaffold-plus.md) — wrap these helpers in async chrome
- [Feedback & toasts](feedback.md) — sheets and snackbars around create/delete
