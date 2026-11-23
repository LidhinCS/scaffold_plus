import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scaffold_plus/scaffold_plus.dart';

void main() {
  runApp(const ScaffoldPlusExampleApp());
}

/// Minimal host app used to demonstrate `scaffold_plus` components.
class ScaffoldPlusExampleApp extends StatelessWidget {
  /// Creates the example application.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'scaffold_plus example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
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
      appBar: AppBar(title: const Text('scaffold_plus')),
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
