import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';

/// One browsable component in the example gallery.
class ComponentEntry {
  /// Creates a catalog entry.
  const new({
    required this.name,
    required this.ability,
    required this.icon,
    required this.demoBuilder,
    this.details,
  });

  /// Public API name.
  final String name;

  /// One-line “what it does”.
  final String ability;

  /// Optional longer notes.
  final String? details;

  /// Leading icon on the hub list.
  final IconData icon;

  /// Builds the interactive demo body.
  final WidgetBuilder demoBuilder;
}

/// Group of related catalog entries.
class ComponentGroup {
  /// Creates a group.
  const new({required this.title, required this.entries});

  /// Section title.
  final String title;

  /// Entries in this section.
  final List<ComponentEntry> entries;
}

/// Full gallery catalog for the Components tab.
final List<ComponentGroup> componentCatalog = [
  ComponentGroup(
    title: 'States',
    entries: [
      ComponentEntry(
        name: 'PlusEmptyState',
        ability: 'Consistent empty UI with optional action',
        details:
            'Use for lists, search misses, and first-run screens. Theme-aware '
            'icon, title, description, and CTA.',
        icon: Icons.inbox_outlined,
        demoBuilder: (_) => const _EmptyStateDemo(),
      ),
      ComponentEntry(
        name: 'PlusErrorState',
        ability: 'Failure presentation with optional retry',
        details: 'No HTTP coupling — pass any message and wire retry yourself.',
        icon: Icons.error_outline_rounded,
        demoBuilder: (_) => const _ErrorStateDemo(),
      ),
      ComponentEntry(
        name: 'PlusOfflineState',
        ability: 'Dedicated offline / no-connection layout',
        icon: Icons.wifi_off_rounded,
        demoBuilder: (_) => PlusOfflineState(
          actionLabel: 'Try again',
          onRetry: () {
            PlusSnackbar.info(message: 'Retry tapped');
          },
        ),
      ),
      ComponentEntry(
        name: 'PlusMaintenanceMode',
        ability: 'Full-page maintenance gate',
        details: 'ScaffoldPlus.maintenanceMode uses this under the hood.',
        icon: Icons.construction_rounded,
        demoBuilder: (_) => const PlusMaintenanceMode(
          message: 'We are upgrading Pulse Tasks. Back shortly.',
        ),
      ),
      ComponentEntry(
        name: 'PlusPermissionState',
        ability: 'Permission-denied layout with CTA',
        icon: Icons.notifications_off_outlined,
        demoBuilder: (_) => PlusPermissionState(
          title: 'Notifications off',
          message: 'Enable notifications to get task reminders.',
          actionLabel: 'Open settings',
          onAction: () {
            PlusSnackbar.info(message: 'Would open system settings');
          },
        ),
      ),
      ComponentEntry(
        name: 'PlusSessionExpired',
        ability: 'Signed-out / session gate',
        icon: Icons.lock_outline_rounded,
        demoBuilder: (_) => PlusSessionExpired(
          actionLabel: 'Sign in',
          onAction: () {
            PlusSnackbar.success(message: 'Sign-in action');
          },
        ),
      ),
    ],
  ),
  ComponentGroup(
    title: 'Async & loaders',
    entries: [
      ComponentEntry(
        name: 'PlusLoader',
        ability: 'Compact theme-aware circular loader',
        icon: Icons.hourglass_empty_rounded,
        demoBuilder: (_) => const Center(
          child: Padding(padding: EdgeInsets.all(32), child: PlusLoader()),
        ),
      ),
      ComponentEntry(
        name: 'PlusSkeleton',
        ability: 'Shimmer placeholder blocks for loading layouts',
        icon: Icons.view_agenda_outlined,
        demoBuilder: (_) => const _SkeletonDemo(),
      ),
      ComponentEntry(
        name: 'PlusAsyncView',
        ability: 'Exhaustive loading / failure / empty / success switch',
        details:
            'Maps PlusAsyncState without locking you into Bloc or Riverpod.',
        icon: Icons.sync_rounded,
        demoBuilder: (_) => const _AsyncViewDemo(),
      ),
    ],
  ),
  ComponentGroup(
    title: 'Actions & feedback',
    entries: [
      ComponentEntry(
        name: 'PlusAsyncButton',
        ability: 'Owns in-flight UX — disable, spinner, optional success',
        details: 'Variants: filled, tonal, outlined, text, elevated.',
        icon: Icons.touch_app_outlined,
        demoBuilder: (_) => const _AsyncButtonDemo(),
      ),
      ComponentEntry(
        name: 'PlusSnackbar',
        ability: 'Tone-aware snackbars (success / info / error)',
        details: 'With PlusToastHost you can show without a BuildContext.',
        icon: Icons.notifications_active_outlined,
        demoBuilder: (_) => const _SnackbarDemo(),
      ),
      ComponentEntry(
        name: 'PlusDialog',
        ability: 'Simple alert dialog helper',
        icon: Icons.chat_bubble_outline_rounded,
        demoBuilder: (context) => _ActionCard(
          label: 'Show alert',
          onPressed: () {
            unawaited(
              PlusDialog.alert(
                context,
                title: 'Heads up',
                message: 'PlusDialog.alert wraps a Material alert.',
              ),
            );
          },
        ),
      ),
      ComponentEntry(
        name: 'PlusConfirmationDialog',
        ability: 'Confirm / cancel with optional destructive styling',
        icon: Icons.help_outline_rounded,
        demoBuilder: (context) => _ActionCard(
          label: 'Confirm delete',
          onPressed: () async {
            final ok = await PlusConfirmationDialog.show(
              context,
              title: 'Delete task?',
              message: 'This cannot be undone.',
              confirmLabel: 'Delete',
              isDestructive: true,
            );
            PlusSnackbar.info(message: ok ? 'Confirmed' : 'Cancelled');
          },
        ),
      ),
      ComponentEntry(
        name: 'PlusBottomSheet',
        ability: 'Modal sheet with title chrome and scroll body',
        icon: Icons.vertical_align_bottom_rounded,
        demoBuilder: (context) => _ActionCard(
          label: 'Open sheet',
          onPressed: () {
            unawaited(
              PlusBottomSheet.show<void>(
                context: context,
                title: 'Share',
                builder: (context) {
                  return ListTile(
                    leading: const Icon(Icons.link_rounded),
                    title: const Text('Copy link'),
                    onTap: () {
                      Navigator.pop(context);
                      PlusSnackbar.success(message: 'Link copied');
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    ],
  ),
  ComponentGroup(
    title: 'Inputs & lists',
    entries: [
      ComponentEntry(
        name: 'PlusSearchField',
        ability: 'Search field with optional debounce via PlusTheme',
        icon: Icons.search_rounded,
        demoBuilder: (_) => const _SearchFieldDemo(),
      ),
      ComponentEntry(
        name: 'PlusPagedList',
        ability: 'Infinite list shell — you own items and paging flags',
        icon: Icons.view_list_rounded,
        demoBuilder: (_) =>
            const SizedBox(height: 360, child: _PagedListDemo()),
      ),
      ComponentEntry(
        name: 'PlusRefreshIndicator',
        ability: 'Pull-to-refresh wrapper with PlusTheme duration hooks',
        icon: Icons.refresh_rounded,
        demoBuilder: (_) => const SizedBox(height: 280, child: _RefreshDemo()),
      ),
    ],
  ),
  ComponentGroup(
    title: 'Connectivity',
    entries: [
      ComponentEntry(
        name: 'PlusConnectivityBanner',
        ability: 'Offline / restored banner (inline or overlay layout)',
        details: 'ScaffoldPlus hosts the inline banner in the body by default.',
        icon: Icons.signal_wifi_statusbar_null_rounded,
        demoBuilder: (_) => const _ConnectivityBannerDemo(),
      ),
      ComponentEntry(
        name: 'PlusConnectivityBuilder',
        ability: 'Rebuild from a bool / Stream reachability source',
        icon: Icons.wifi_tethering_rounded,
        demoBuilder: (_) => const _ConnectivityBuilderDemo(),
      ),
    ],
  ),
  ComponentGroup(
    title: 'Floating & shell',
    entries: [
      ComponentEntry(
        name: 'PlusFloatingWindow',
        ability: 'PiP-style detachable overlay (drag / resize / dismiss)',
        details:
            'Requires PlusFloatingWindowHost in MaterialApp.builder. Also '
            'demoed on Settings → Focus timer.',
        icon: Icons.picture_in_picture_alt_rounded,
        demoBuilder: (_) => const _FloatingWindowDemo(),
      ),
      ComponentEntry(
        name: 'ScaffoldPlus',
        ability: 'Scaffold + async body + connectivity + product gates',
        details:
            'This gallery page is already a ScaffoldPlus. See Tasks / '
            'Activity for async + gate composition.',
        icon: Icons.dashboard_customize_outlined,
        demoBuilder: (_) => const _InfoCard(
          lines: [
            '• Forwards Flutter Scaffold APIs (Scaffold.of works)',
            '• Optional PlusAsyncState body with skeleton / empty / error',
            '• Inline connectivity banner + built-in internet checker',
            '• maintenanceMode / sessionExpired / permissionDenied gates',
          ],
        ),
      ),
      ComponentEntry(
        name: 'PlusAdaptiveScaffold',
        ability: 'NavigationBar ↔ NavigationRail by breakpoint',
        details: 'The Pulse Tasks root shell is a PlusAdaptiveScaffold.',
        icon: Icons.tablet_mac_rounded,
        demoBuilder: (_) => const _InfoCard(
          lines: [
            '• compactBreakpoint (default 600) → bottom NavigationBar',
            '• Wider widths → NavigationRail',
            '• Body stays app-owned (compose ScaffoldPlus per tab)',
          ],
        ),
      ),
      ComponentEntry(
        name: 'PlusTheme',
        ability: 'ThemeExtension for shared durations and defaults',
        icon: Icons.palette_outlined,
        demoBuilder: (_) => const _InfoCard(
          lines: [
            '• searchDebounceDuration for PlusSearchField',
            '• snackbarDuration for PlusSnackbar',
            '• Wire via ThemeData.extensions',
          ],
        ),
      ),
    ],
  ),
];

class _InfoCard extends StatelessWidget {
  const new({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final line in lines) ...[
              Text(line),
              if (line != lines.last) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const new({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}

class _EmptyStateDemo extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return PlusEmptyState(
      title: 'No tasks yet',
      description: 'Create your first task to get started.',
      actionLabel: 'Create task',
      onAction: () {
        PlusSnackbar.success(message: 'Create action');
      },
    );
  }
}

class _ErrorStateDemo extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return PlusErrorState(
      title: 'Could not load',
      message: 'The server returned an unexpected error.',
      actionLabel: 'Retry',
      onRetry: () {
        PlusSnackbar.info(message: 'Retry');
      },
    );
  }
}

class _SkeletonDemo extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PlusSkeleton(height: 20, width: double.infinity),
        SizedBox(height: 12),
        PlusSkeleton(height: 20, width: 220),
        SizedBox(height: 12),
        PlusSkeleton(height: 96, width: double.infinity),
      ],
    );
  }
}

class _AsyncViewDemo extends StatefulWidget {
  const new();

  @override
  State<_AsyncViewDemo> createState() => _AsyncViewDemoState();
}

class _AsyncViewDemoState extends State<_AsyncViewDemo> {
  PlusAsyncState<List<String>> _state = const PlusLoading();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load({bool empty = false, bool fail = false}) async {
    setState(() => _state = const PlusLoading());
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    if (fail) {
      setState(
        () => _state = PlusFailure(
          'Demo failure',
          stackTrace: StackTrace.current,
        ),
      );
      return;
    }
    setState(() {
      _state = PlusSuccess(
        empty ? <String>[] : const ['Alpha', 'Beta', 'Gamma'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonal(
              onPressed: () => unawaited(_load()),
              child: const Text('Success'),
            ),
            OutlinedButton(
              onPressed: () => unawaited(_load(empty: true)),
              child: const Text('Empty'),
            ),
            OutlinedButton(
              onPressed: () => unawaited(_load(fail: true)),
              child: const Text('Failure'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: PlusAsyncView<List<String>>(
            state: _state,
            isEmpty: (data) => data.isEmpty,
            onRetry: () => unawaited(_load()),
            builder: (context, data) {
              return ListView(
                children: [
                  for (final item in data) ListTile(title: Text(item)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AsyncButtonDemo extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final variant in PlusAsyncButtonVariant.values) ...[
          PlusAsyncButton(
            variant: variant,
            successChild: const Text('Done'),
            onPressed: () async {
              await Future<void>.delayed(const Duration(milliseconds: 900));
            },
            onError: (error, stack) {
              PlusSnackbar.error(message: '$error');
            },
            child: Text(variant.name),
          ),
          const SizedBox(height: 8),
        ],
        PlusAsyncButton(
          onPressed: () async {
            await Future<void>.delayed(const Duration(milliseconds: 400));
            throw StateError('Simulated failure');
          },
          onError: (error, stack) {
            PlusSnackbar.error(message: 'Caught: $error');
          },
          child: const Text('Fail with onError'),
        ),
      ],
    );
  }
}

class _SnackbarDemo extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.tonal(
          onPressed: () => PlusSnackbar.success(message: 'Saved'),
          child: const Text('Success'),
        ),
        FilledButton.tonal(
          onPressed: () => PlusSnackbar.info(message: 'Heads up'),
          child: const Text('Info'),
        ),
        FilledButton.tonal(
          onPressed: () => PlusSnackbar.error(message: 'Failed'),
          child: const Text('Error'),
        ),
      ],
    );
  }
}

class _SearchFieldDemo extends StatefulWidget {
  const new();

  @override
  State<_SearchFieldDemo> createState() => _SearchFieldDemoState();
}

class _SearchFieldDemoState extends State<_SearchFieldDemo> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlusSearchField(
          hintText: 'Search components',
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 12),
        Text(
          _query.isEmpty
              ? 'Type to see debounced / immediate updates'
              : 'Query: $_query',
        ),
      ],
    );
  }
}

class _PagedListDemo extends StatefulWidget {
  const new();

  @override
  State<_PagedListDemo> createState() => _PagedListDemoState();
}

class _PagedListDemoState extends State<_PagedListDemo> {
  final _items = List<String>.generate(12, (i) => 'Item ${i + 1}');
  var _hasMore = true;
  var _loadingMore = false;

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) {
      return;
    }
    setState(() => _loadingMore = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) {
      return;
    }
    setState(() {
      final start = _items.length + 1;
      _items.addAll(List.generate(8, (i) => 'Item ${start + i}'));
      _loadingMore = false;
      if (_items.length >= 40) {
        _hasMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlusPagedList<String>(
      items: _items,
      hasMore: _hasMore,
      isLoadingMore: _loadingMore,
      onLoadMore: _loadMore,
      itemBuilder: (context, item, index) {
        return ListTile(
          dense: true,
          title: Text(item),
          subtitle: Text('Index $index'),
        );
      },
    );
  }
}

class _RefreshDemo extends StatefulWidget {
  const new();

  @override
  State<_RefreshDemo> createState() => _RefreshDemoState();
}

class _RefreshDemoState extends State<_RefreshDemo> {
  var _stamp = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return PlusRefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (mounted) {
          setState(() => _stamp = DateTime.now());
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ListTile(
            title: const Text('Pull down to refresh'),
            subtitle: Text('Last refresh: $_stamp'),
          ),
          const ListTile(title: Text('Row A')),
          const ListTile(title: Text('Row B')),
          const ListTile(title: Text('Row C')),
        ],
      ),
    );
  }
}

class _ConnectivityBannerDemo extends StatefulWidget {
  const new();

  @override
  State<_ConnectivityBannerDemo> createState() =>
      _ConnectivityBannerDemoState();
}

class _ConnectivityBannerDemoState extends State<_ConnectivityBannerDemo> {
  var _connected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Connected'),
          value: _connected,
          onChanged: (value) => setState(() => _connected = value),
        ),
        const SizedBox(height: 8),
        PlusConnectivityBanner(isConnected: _connected),
        const SizedBox(height: 12),
        const Text(
          'Toggle to preview offline vs restored copy. Overlay layout is '
          'available via PlusConnectivityBannerLayout.overlay.',
        ),
      ],
    );
  }
}

class _ConnectivityBuilderDemo extends StatefulWidget {
  const new();

  @override
  State<_ConnectivityBuilderDemo> createState() =>
      _ConnectivityBuilderDemoState();
}

class _ConnectivityBuilderDemoState extends State<_ConnectivityBuilderDemo> {
  var _connected = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('isConnected source'),
          value: _connected,
          onChanged: (value) => setState(() => _connected = value),
        ),
        PlusConnectivityBuilder(
          isConnected: _connected,
          onlineBuilder: (context) => const Card(
            child: ListTile(
              leading: Icon(Icons.wifi_rounded),
              title: Text('Online'),
              subtitle: Text('onlineBuilder'),
            ),
          ),
          offlineBuilder: (context) => const Card(
            child: ListTile(
              leading: Icon(Icons.wifi_off_rounded),
              title: Text('Offline'),
              subtitle: Text('offlineBuilder'),
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingWindowDemo extends StatefulWidget {
  const new();

  @override
  State<_FloatingWindowDemo> createState() => _FloatingWindowDemoState();
}

class _FloatingWindowDemoState extends State<_FloatingWindowDemo> {
  late final PlusFloatingWindowController _controller =
      PlusFloatingWindowController(initialSize: const Size(240, 160));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Tap Float to detach into the host overlay. Drag the title bar, '
          'resize the corner, or expand / close.',
        ),
        const SizedBox(height: 12),
        PlusFloatingWindow(
          controller: _controller,
          title: 'Live preview',
          autoFloatOnRouteExit: false,
          builder: (context, {required floating}) {
            return Material(
              color: floating ? colors.surface : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        floating ? 'Floating' : 'Inline',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (!floating) ...[
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: _controller.enterFloating,
                          child: const Text('Float'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
