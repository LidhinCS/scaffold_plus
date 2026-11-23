import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  runApp(const UiPlusExampleApp());
}

/// Minimal host app used to demonstrate UI Plus components.
class UiPlusExampleApp extends StatelessWidget {
  /// Creates the example application.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI Plus example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        extensions: const [
          PlusTheme(searchDebounceDuration: Duration(milliseconds: 250)),
        ],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        extensions: const [
          PlusTheme(searchDebounceDuration: Duration(milliseconds: 250)),
        ],
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI Plus')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Components',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          _DemoTile(
            title: 'ScaffoldPlus',
            subtitle: 'Drop-in Scaffold with optional async body',
            builder: (_) => const _ScaffoldPlusDemoPage(),
          ),
          _DemoTile(
            title: 'PlusAsyncView',
            subtitle: 'Async switching inside an existing Scaffold',
            builder: (_) => const _AsyncViewDemoPage(),
          ),
          _DemoTile(
            title: 'PlusEmptyState',
            subtitle: 'Empty list / no results presentation',
            builder: (_) => const _EmptyStateDemoPage(),
          ),
          _DemoTile(
            title: 'PlusErrorState',
            subtitle: 'Failure presentation with retry',
            builder: (_) => const _ErrorStateDemoPage(),
          ),
          _DemoTile(
            title: 'PlusLoader',
            subtitle: 'Circular loading indicator',
            builder: (_) => const _LoaderDemoPage(),
          ),
          _DemoTile(
            title: 'PlusSkeleton',
            subtitle: 'Composable skeleton placeholders',
            builder: (_) => const _SkeletonDemoPage(),
          ),
          _DemoTile(
            title: 'Connectivity',
            subtitle: 'Banner, offline state, and builder demos',
            builder: (_) => const _ConnectivityDemoPage(),
          ),
          _DemoTile(
            title: 'PlusSnackbar',
            subtitle: 'Success, info, and error snackbars',
            builder: (_) => const _SnackbarDemoPage(),
          ),
          _DemoTile(
            title: 'Dialogs',
            subtitle: 'Alert and confirmation dialogs',
            builder: (_) => const _DialogsDemoPage(),
          ),
          _DemoTile(
            title: 'PlusBottomSheet',
            subtitle: 'Modal and scrollable bottom sheets',
            builder: (_) => const _BottomSheetDemoPage(),
          ),
          _DemoTile(
            title: 'PlusSearchField',
            subtitle: 'Search input with debounce and clear',
            builder: (_) => const _SearchFieldDemoPage(),
          ),
          _DemoTile(
            title: 'PlusRefreshIndicator',
            subtitle: 'Pull-to-refresh with error handling',
            builder: (_) => const _RefreshIndicatorDemoPage(),
          ),
          _DemoTile(
            title: 'PlusAsyncButton',
            subtitle: 'Async action with loading lock and success flash',
            builder: (_) => const _AsyncButtonDemoPage(),
          ),
          _DemoTile(
            title: 'PlusPagedList',
            subtitle: 'Infinite list with load-more footers',
            builder: (_) => const _PagedListDemoPage(),
          ),
          _DemoTile(
            title: 'PlusAdaptiveScaffold',
            subtitle: 'Nav bar ↔ rail by breakpoint',
            builder: (_) => const _AdaptiveScaffoldDemoPage(),
          ),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const new({
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
        },
      ),
    );
  }
}

class _ScaffoldPlusDemoPage extends StatefulWidget {
  const new();

  @override
  State<_ScaffoldPlusDemoPage> createState() => _ScaffoldPlusDemoPageState();
}

class _ScaffoldPlusDemoPageState extends State<_ScaffoldPlusDemoPage> {
  /// Starts on success so the demo is immediately interactive.
  PlusAsyncState<List<String>>? _state = const PlusSuccess(['Alpha', 'Beta']);
  var _useSkeleton = true;

  String get _modeLabel {
    final state = _state;
    if (state == null) {
      return 'Mode: plain body (state == null)';
    }
    return switch (state) {
      PlusLoading() =>
        _useSkeleton ? 'Mode: loading (skeleton)' : 'Mode: loading (loader)',
      PlusSuccess(:final data) when data.isEmpty => 'Mode: empty',
      PlusSuccess() => 'Mode: success',
      PlusFailure() => 'Mode: error',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlus<List<String>>(
      appBar: AppBar(
        title: const Text('ScaffoldPlus'),
        // Keep demo controls in the app bar so they are never covered by a FAB
        // or cramped into bottomNavigationBar.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_modeLabel, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Skeleton'),
                        selected: _useSkeleton,
                        onSelected: (value) {
                          setState(() => _useSkeleton = value);
                        },
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('Loading'),
                        onPressed: () {
                          setState(() => _state = const PlusLoading());
                        },
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('Success'),
                        onPressed: () {
                          setState(
                            () => _state = const PlusSuccess(['Alpha', 'Beta']),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('Empty'),
                        onPressed: () {
                          setState(() => _state = const PlusSuccess([]));
                        },
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('Error'),
                        onPressed: () {
                          setState(
                            () => _state = const PlusFailure('Network error'),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('Plain body'),
                        onPressed: () {
                          setState(() => _state = null);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Shown only when state is null (body precedence demo).
      body: const Center(
        child: Text(
          'Plain scaffold body\n(state is null)',
          textAlign: TextAlign.center,
        ),
      ),
      state: _state,
      useSkeleton: _useSkeleton,
      isEmpty: (items) => items.isEmpty,
      onRetry: () => setState(() => _state = const PlusLoading()),
      bodyBuilder: (context, items) {
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(items[index]),
            );
          },
        );
      },
    );
  }
}

class _AsyncViewDemoPage extends StatefulWidget {
  const new();

  @override
  State<_AsyncViewDemoPage> createState() => _AsyncViewDemoPageState();
}

class _AsyncViewDemoPageState extends State<_AsyncViewDemoPage> {
  PlusAsyncState<List<String>> _state = const PlusLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PlusAsyncView')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => setState(() => _state = const PlusLoading()),
                  child: const Text('Loading'),
                ),
                FilledButton.tonal(
                  onPressed: () => setState(
                    () => _state = const PlusSuccess(['Alpha', 'Beta']),
                  ),
                  child: const Text('Success'),
                ),
                FilledButton.tonal(
                  onPressed: () =>
                      setState(() => _state = const PlusSuccess([])),
                  child: const Text('Empty'),
                ),
                FilledButton.tonal(
                  onPressed: () => setState(
                    () => _state = const PlusFailure('Network error'),
                  ),
                  child: const Text('Error'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: PlusAsyncView<List<String>>(
              state: _state,
              isEmpty: (items) => items.isEmpty,
              onRetry: () => setState(() => _state = const PlusLoading()),
              builder: (context, items) {
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(items[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateDemoPage extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PlusEmptyState')),
      body: Center(
        child: PlusEmptyState(
          title: 'Nothing here yet',
          description: 'Your items will appear here once you add some.',
          actionLabel: 'Refresh',
          onAction: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Refresh tapped')));
          },
        ),
      ),
    );
  }
}

class _ErrorStateDemoPage extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PlusErrorState')),
      body: Center(
        child: PlusErrorState(
          title: 'Something went wrong',
          message: 'Unable to load your data.',
          actionLabel: 'Try again',
          onRetry: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Retry tapped')));
          },
        ),
      ),
    );
  }
}

class _LoaderDemoPage extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PlusLoader')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlusLoader(),
            SizedBox(height: 32),
            PlusLoader(size: 48, strokeWidth: 4),
          ],
        ),
      ),
    );
  }
}

class _SkeletonDemoPage extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PlusSkeleton')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlusSkeleton(height: 20, width: 180),
            SizedBox(height: 12),
            PlusSkeleton(height: 14),
            SizedBox(height: 8),
            PlusSkeleton(height: 14, width: 220),
            SizedBox(height: 24),
            Row(
              children: [
                PlusSkeleton(
                  width: 64,
                  height: 64,
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      PlusSkeleton(height: 14),
                      SizedBox(height: 8),
                      PlusSkeleton(height: 14, width: 140),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Simulates reachability with a local stream (no connectivity plugin).
class _ConnectivityDemoPage extends StatefulWidget {
  const new();

  @override
  State<_ConnectivityDemoPage> createState() => _ConnectivityDemoPageState();
}

class _ConnectivityDemoPageState extends State<_ConnectivityDemoPage> {
  final _controller = StreamController<bool>.broadcast();
  var _isConnected = true;
  var _useCustomBanner = false;

  @override
  void dispose() {
    unawaited(_controller.close());
    super.dispose();
  }

  void _setConnected(bool value) {
    setState(() => _isConnected = value);
    _controller.add(value);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlus<void>(
      connectivityBanner: true,
      isConnected: _isConnected,
      connectivityStream: _controller.stream,
      connectivityBannerConfig: const PlusConnectivityConfig(
        offlineMessage: 'You are currently offline',
        onlineMessage: 'Back online!',
      ),
      connectivityBannerBuilder: _useCustomBanner
          ? (context, {required isConnected}) {
              return Material(
                color: isConnected
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    isConnected ? 'Custom: online' : 'Custom: offline',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          : null,
      appBar: AppBar(title: const Text('Connectivity')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Core stays plugin-free. This demo feeds a Stream<bool> that '
            'should represent reachability in real apps.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: () => _setConnected(true),
                child: const Text('Go online'),
              ),
              FilledButton.tonal(
                onPressed: () => _setConnected(false),
                child: const Text('Go offline'),
              ),
              FilterChip(
                label: const Text('Custom banner'),
                selected: _useCustomBanner,
                onSelected: (value) {
                  setState(() => _useCustomBanner = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'PlusConnectivityBuilder',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: PlusConnectivityBuilder(
                isConnected: _isConnected,
                onlineBuilder: (_) =>
                    const Center(child: Text('Online content')),
                offlineBuilder: (context) => PlusOfflineState(
                  actionLabel: 'Retry',
                  onRetry: () => _setConnected(true),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Standalone banner',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          PlusConnectivityBanner(isConnected: _isConnected),
        ],
      ),
    );
  }
}

class _SnackbarDemoPage extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PlusSnackbar')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          FilledButton(
            onPressed: () =>
                PlusSnackbar.success(context, message: 'Changes saved'),
            child: const Text('Success'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => PlusSnackbar.info(
              context,
              message: 'Sync is paused while offline',
            ),
            child: const Text('Info'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => PlusSnackbar.error(
              context,
              message: 'Could not save changes',
              actionLabel: 'Retry',
              onAction: () =>
                  PlusSnackbar.info(context, message: 'Retry queued'),
            ),
            child: const Text('Error with action'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => PlusSnackbar.hide(context),
            child: const Text('Hide current'),
          ),
        ],
      ),
    );
  }
}

class _DialogsDemoPage extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialogs')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          FilledButton(
            onPressed: () => PlusDialog.alert(
              context,
              title: 'Heads up',
              message: 'Your session will expire in 5 minutes.',
            ),
            child: const Text('Alert dialog'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () async {
              final confirmed = await PlusConfirmationDialog.show(
                context,
                title: 'Discard draft?',
                message: 'Unsaved changes will be lost.',
                confirmLabel: 'Discard',
                cancelLabel: 'Keep editing',
              );
              if (!context.mounted) return;
              PlusSnackbar.info(
                context,
                message: confirmed ? 'Draft discarded' : 'Kept editing',
              );
            },
            child: const Text('Confirmation dialog'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              final confirmed = await PlusConfirmationDialog.show(
                context,
                title: 'Delete account?',
                message: 'This action cannot be undone.',
                confirmLabel: 'Delete',
                isDestructive: true,
              );
              if (!context.mounted) return;
              PlusSnackbar.info(
                context,
                message: confirmed ? 'Account deleted' : 'Cancelled',
              );
            },
            child: const Text('Destructive confirmation'),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetDemoPage extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PlusBottomSheet')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          FilledButton(
            onPressed: () => PlusBottomSheet.show<void>(
              context: context,
              title: 'Share',
              builder: (sheetContext) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.link),
                      title: const Text('Copy link'),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        if (!context.mounted) return;
                        PlusSnackbar.success(context, message: 'Link copied');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('Share elsewhere'),
                      onTap: () => Navigator.pop(sheetContext),
                    ),
                  ],
                );
              },
            ),
            child: const Text('Simple sheet'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => PlusBottomSheet.showScrollable<void>(
              context: context,
              title: 'Choose item',
              heightFactor: 0.55,
              builder: (sheetContext) {
                return ListView.builder(
                  itemCount: 40,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Item ${index + 1}'),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        if (!context.mounted) return;
                        PlusSnackbar.info(
                          context,
                          message: 'Picked item ${index + 1}',
                        );
                      },
                    );
                  },
                );
              },
            ),
            child: const Text('Scrollable sheet'),
          ),
        ],
      ),
    );
  }
}

class _SearchFieldDemoPage extends StatefulWidget {
  const new();

  @override
  State<_SearchFieldDemoPage> createState() => _SearchFieldDemoPageState();
}

class _SearchFieldDemoPageState extends State<_SearchFieldDemoPage> {
  static const _items = ['Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon', 'Zeta'];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _items
        .where((item) => item.toLowerCase().contains(_query.toLowerCase()))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('PlusSearchField')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PlusSearchField(
            hintText: 'Search items',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 16),
          Text(
            _query.isEmpty
                ? 'All items'
                : '${filtered.length} result${filtered.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            const PlusEmptyState(
              title: 'No matches',
              description: 'Try a different search term.',
              icon: Icons.search_off,
            )
          else
            ...filtered.map(
              (item) =>
                  ListTile(contentPadding: EdgeInsets.zero, title: Text(item)),
            ),
        ],
      ),
    );
  }
}

class _RefreshIndicatorDemoPage extends StatefulWidget {
  const new();

  @override
  State<_RefreshIndicatorDemoPage> createState() =>
      _RefreshIndicatorDemoPageState();
}

class _RefreshIndicatorDemoPageState extends State<_RefreshIndicatorDemoPage> {
  final List<String> _items = List.generate(12, (index) => 'Item ${index + 1}');
  bool _failNext = false;

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (_failNext) {
      _failNext = false;
      throw StateError('Simulated refresh failure');
    }
    if (!mounted) return;
    setState(() {
      _items.insert(0, 'Item ${_items.length + 1}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlusRefreshIndicator'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _failNext = true),
            child: const Text('Fail next'),
          ),
        ],
      ),
      body: PlusRefreshIndicator(
        onRefresh: _refresh,
        onError: (error, stackTrace) {
          PlusSnackbar.error(context, message: 'Refresh failed');
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(_items[index]));
          },
        ),
      ),
    );
  }
}

class _AsyncButtonDemoPage extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PlusAsyncButton')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlusAsyncButton(
                onPressed: () async {
                  await Future<void>.delayed(const Duration(seconds: 1));
                },
                successChild: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 18),
                    SizedBox(width: 8),
                    Text('Saved'),
                  ],
                ),
                child: const Text('Save draft'),
              ),
              const SizedBox(height: 16),
              PlusAsyncButton(
                variant: PlusAsyncButtonVariant.tonal,
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 800));
                  throw StateError('Simulated failure');
                },
                onError: (error, stack) {
                  PlusSnackbar.error(context, message: 'Save failed');
                },
                child: const Text('Save (will fail)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PagedListDemoPage extends StatefulWidget {
  const new();

  @override
  State<_PagedListDemoPage> createState() => _PagedListDemoPageState();
}

class _PagedListDemoPageState extends State<_PagedListDemoPage> {
  final List<String> _items = List.generate(15, (i) => 'Item ${i + 1}');
  bool _loadingMore = false;
  bool _hasMore = true;
  Object? _error;
  var _failNext = false;

  Future<void> _loadMore() async {
    setState(() {
      _loadingMore = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    if (_failNext) {
      _failNext = false;
      setState(() {
        _loadingMore = false;
        _error = StateError('Simulated page failure');
      });
      return;
    }
    setState(() {
      final start = _items.length;
      _items.addAll(List.generate(10, (i) => 'Item ${start + i + 1}'));
      _loadingMore = false;
      if (_items.length >= 45) {
        _hasMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlusPagedList'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _failNext = true),
            child: const Text('Fail next'),
          ),
        ],
      ),
      body: PlusPagedList<String>(
        items: _items,
        hasMore: _hasMore,
        isLoadingMore: _loadingMore,
        loadMoreError: _error,
        onLoadMore: _loadMore,
        onRetryLoadMore: _loadMore,
        endFooter: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('End of list')),
        ),
        itemBuilder: (context, item, index) => ListTile(title: Text(item)),
      ),
    );
  }
}

class _AdaptiveScaffoldDemoPage extends StatefulWidget {
  const new();

  @override
  State<_AdaptiveScaffoldDemoPage> createState() =>
      _AdaptiveScaffoldDemoPageState();
}

class _AdaptiveScaffoldDemoPageState extends State<_AdaptiveScaffoldDemoPage> {
  var _index = 0;

  static const _destinations = [
    PlusNavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    PlusNavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search),
      label: 'Search',
    ),
    PlusNavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Center(child: Text('Home — resize for rail')),
      const Center(child: Text('Search')),
      const Center(child: Text('Profile')),
    ];

    return PlusAdaptiveScaffold(
      destinations: _destinations,
      selectedIndex: _index,
      onDestinationSelected: (index) => setState(() => _index = index),
      appBar: AppBar(title: const Text('PlusAdaptiveScaffold')),
      body: pages[_index],
    );
  }
}
