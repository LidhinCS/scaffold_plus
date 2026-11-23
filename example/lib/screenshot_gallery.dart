import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ui_plus/ui_plus.dart';

/// Auto-advancing gallery used to capture pub.dev screenshots via simctl.
///
/// ```sh
/// flutter run -t lib/screenshot_gallery.dart -d <device>
/// ```
void main() {
  runApp(const ScreenshotGalleryApp());
}

/// Host app for screenshot scenes.
class ScreenshotGalleryApp extends StatelessWidget {
  /// Creates the gallery app.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        extensions: const [
          PlusTheme(searchDebounceDuration: Duration(milliseconds: 250)),
        ],
      ),
      home: const _Gallery(),
    );
  }
}

class _Gallery extends StatefulWidget {
  const new();

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  static const _sceneNames = [
    '01_tasks_inbox',
    '02_compose_task',
    '03_settings_gates',
    '04_offline_banner',
    '05_maintenance_gate',
    '06_permission_gate',
  ];

  final _controller = PageController();
  var _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Hold each scene long enough for simctl capture scripts.
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) {
        return;
      }
      final next = _index + 1;
      if (next >= _sceneNames.length) {
        _timer?.cancel();
        // Stay on last scene.
        return;
      }
      setState(() => _index = next);
      _controller.animateToPage(
        _index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      debugPrint('SCREENSHOT_SCENE ${_sceneNames[_index]}');
    });
    debugPrint('SCREENSHOT_SCENE ${_sceneNames[0]}');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _TasksInboxScene(),
        _ComposeScene(),
        _SettingsScene(),
        _OfflineScene(),
        _MaintenanceScene(),
        _PermissionScene(),
      ],
    );
  }
}

class _PhoneChrome extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(child: child),
    );
  }
}

class _TasksInboxScene extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    const tasks = [
      _DemoTask('Ship ui_plus 0.4 notes', done: true),
      _DemoTask('Polish snackbar motion'),
      _DemoTask('Wire PlusToastHost in app'),
      _DemoTask('Review ScaffoldPlus gates'),
      _DemoTask('Draft connectivity docs'),
      _DemoTask('Add paged inbox demo', done: true),
    ];

    return _PhoneChrome(
      child: ScaffoldPlus<List<_DemoTask>>(
        appBar: AppBar(
          title: const Text('Tasks'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(64),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: PlusSearchField(hintText: 'Search tasks', enabled: false),
            ),
          ),
        ),
        state: const PlusSuccess(tasks),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded),
          label: const Text('New task'),
        ),
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline_rounded),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.bolt_outlined),
              label: 'Activity',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
        bodyBuilder: (context, items) {
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final task = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    task.done
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: task.done
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.done
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    index.isEven
                        ? 'Tracked in the Pulse Tasks showcase.'
                        : 'Open Settings to flip product-state gates.',
                  ),
                  trailing: const Icon(Icons.delete_outline_rounded),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ComposeScene extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return _PhoneChrome(
      child: Scaffold(
        appBar: AppBar(title: const Text('Tasks')),
        body: Stack(
          children: [
            const ColoredBox(color: Color(0x33000000)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                elevation: 8,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'New task',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          'Polish snackbar motion',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        child: Text(
                          'Tracked in the Pulse Tasks showcase.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Create task'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsScene extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return _PhoneChrome(
      child: ScaffoldPlus<void>(
        appBar: AppBar(title: const Text('Settings')),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 2,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline_rounded),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.bolt_outlined),
              label: 'Activity',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Developer gates',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SwitchListTile(
              secondary: Icon(Icons.construction_rounded),
              title: Text('Maintenance mode'),
              subtitle: Text('ScaffoldPlus.maintenanceMode'),
              value: false,
              onChanged: null,
            ),
            const SwitchListTile(
              secondary: Icon(Icons.notifications_off_outlined),
              title: Text('Deny notifications'),
              subtitle: Text('ScaffoldPlus.permissionDenied on Tasks'),
              value: false,
              onChanged: null,
            ),
            const SwitchListTile(
              secondary: Icon(Icons.wifi_off_rounded),
              title: Text('Force offline'),
              subtitle: Text('Connectivity banner via isConnected: false'),
              value: true,
              onChanged: null,
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineScene extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return _PhoneChrome(
      child: ScaffoldPlus<void>(
        connectivityBanner: true,
        useBuiltInInternetCheck: false,
        isConnected: false,
        appBar: AppBar(title: const Text('Tasks')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded),
          label: const Text('New task'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ListTile(
              leading: Icon(Icons.check_circle_rounded),
              title: Text('Ship ui_plus 0.4 notes'),
            ),
            ListTile(
              leading: Icon(Icons.circle_outlined),
              title: Text('Polish snackbar motion'),
            ),
            ListTile(
              leading: Icon(Icons.circle_outlined),
              title: Text('Wire PlusToastHost in app'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaintenanceScene extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return _PhoneChrome(
      child: ScaffoldPlus<void>(
        maintenanceMode: true,
        appBar: AppBar(title: const Text('Tasks')),
        body: const SizedBox.shrink(),
      ),
    );
  }
}

class _PermissionScene extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return _PhoneChrome(
      child: ScaffoldPlus<void>(
        permissionDenied: true,
        permissionBuilder: (_) => PlusPermissionState(
          title: 'Notifications required',
          message:
              'Pulse Tasks needs notification access for due reminders. '
              'Toggle permission back on in Settings to continue.',
          actionLabel: 'Allow notifications',
          onAction: () {},
        ),
        appBar: AppBar(title: const Text('Tasks')),
        body: const SizedBox.shrink(),
      ),
    );
  }
}

class _DemoTask {
  const new(this.title, {this.done = false});

  final String title;
  final bool done;
}
