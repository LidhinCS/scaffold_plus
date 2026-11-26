import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';
import 'package:ui_plus_example/cubit/app_shell_cubit.dart';
import 'package:ui_plus_example/cubit/tasks_cubit.dart';

/// Settings + developer toggles for product-state demos.
///
/// Intentionally skips maintenance / session gates so toggles stay reachable.
class SettingsPage extends StatelessWidget {
  /// Creates the settings page.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<AppShellCubit>().state;

    return ScaffoldPlus<void>(
      connectivityBanner: true,
      useBuiltInInternetCheck:
          context.read<AppShellCubit>().useBuiltInInternetCheck &&
          !shell.forceOffline,
      isConnected: shell.forceOffline ? false : null,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: const Text('Signed in as'),
            subtitle: Text(
              shell.isSignedIn ? 'demo@pulse.tasks' : 'Signed out',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: PlusAsyncButton(
              variant: PlusAsyncButtonVariant.tonal,
              onPressed: () async {
                if (!shell.isSignedIn) {
                  context.read<AppShellCubit>().signIn();
                  PlusSnackbar.success(message: 'Signed in');
                  return;
                }
                await PlusDialog.alert(
                  context,
                  title: 'Sign out?',
                  message:
                      'This triggers ScaffoldPlus.sessionExpired on Tasks and '
                      'Activity.',
                  primaryLabel: 'Continue',
                );
                if (!context.mounted) {
                  return;
                }
                context.read<AppShellCubit>().signOut();
                PlusSnackbar.info(message: 'Signed out');
              },
              child: Text(shell.isSignedIn ? 'Sign out' : 'Sign in'),
            ),
          ),
          const Divider(),
          const _SectionHeader('Developer gates'),
          SwitchListTile(
            secondary: const Icon(Icons.construction_rounded),
            title: const Text('Maintenance mode'),
            subtitle: const Text('ScaffoldPlus.maintenanceMode'),
            value: shell.maintenanceMode,
            onChanged: (value) {
              context.read<AppShellCubit>().setMaintenanceMode(enabled: value);
              PlusSnackbar.info(
                message: value ? 'Maintenance on' : 'Maintenance off',
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_off_outlined),
            title: const Text('Deny notifications'),
            subtitle: const Text('ScaffoldPlus.permissionDenied on Tasks'),
            value: !shell.notificationsAllowed,
            onChanged: (denied) {
              context.read<AppShellCubit>().setNotificationsAllowed(
                allowed: !denied,
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.wifi_off_rounded),
            title: const Text('Force offline'),
            subtitle: const Text('Connectivity banner via isConnected: false'),
            value: shell.forceOffline,
            onChanged: (value) {
              context.read<AppShellCubit>().setForceOffline(offline: value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('Fail next tasks fetch'),
            subtitle: const Text('Arms PlusFailure on the Tasks tab'),
            onTap: () {
              context.read<TasksCubit>().armFetchFailure();
              PlusSnackbar.info(message: 'Next Tasks load will fail once');
            },
          ),
          const Divider(),
          const _SectionHeader('Focus timer'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _FocusTimerPanel(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Start the timer, then switch to Tasks or Activity — '
              'the panel detaches into a resizable floating window.',
            ),
          ),
          const Divider(),
          const _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Pulse Tasks'),
            subtitle: Text(
              'Showcase app for ui_plus — Bloc owns domain state; '
              'widgets map to PlusAsyncState at the UI edge.',
            ),
          ),
        ],
      ),
    );
  }
}

/// Demo of [PlusFloatingWindow] — detach on navigate while active.
class _FocusTimerPanel extends StatefulWidget {
  const new();

  @override
  State<_FocusTimerPanel> createState() => _FocusTimerPanelState();
}

class _FocusTimerPanelState extends State<_FocusTimerPanel> {
  late final PlusFloatingWindowController _controller =
      PlusFloatingWindowController(
        initialSize: const Size(260, 180),
        minSize: const Size(200, 150),
        maxSize: const Size(360, 320),
      );

  int _seconds = 25 * 60;
  bool _running = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _tick();
    }
  }

  void _tick() {
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_running) {
        return;
      }
      setState(() {
        if (_seconds > 0) {
          _seconds -= 1;
        } else {
          _running = false;
        }
      });
      if (_running) {
        _tick();
      }
    });
  }

  void _reset() {
    setState(() {
      _running = false;
      _seconds = 25 * 60;
    });
  }

  String get _label {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Tabs share one route (IndexedStack) — float when leaving Settings
    // while the timer is running (route-aware float still covers pushes).
    return BlocListener<AppShellCubit, AppShellState>(
      listenWhen: (previous, current) => previous.tabIndex != current.tabIndex,
      listener: (context, state) {
        const settingsTab = 3;
        if (state.tabIndex != settingsTab &&
            _running &&
            !_controller.isFloating) {
          _controller.enterFloating();
        } else if (state.tabIndex == settingsTab && _controller.isFloating) {
          _controller.expand();
        }
      },
      child: PlusFloatingWindow(
        controller: _controller,
        title: 'Focus timer',
        // Tab shell shares one route; float via BlocListener / Float now.
        autoFloatOnRouteExit: false,
        onDismiss: () {
          if (mounted) {
            setState(() => _running = false);
          }
        },
        builder: (context, {required floating}) {
          final textStyle = floating
              ? Theme.of(context).textTheme.titleLarge
              : Theme.of(context).textTheme.headlineMedium;
          return Material(
            color: floating ? colors.surface : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(floating ? 8 : 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _label,
                    style: textStyle?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: floating ? 4 : 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.tonal(
                        onPressed: _toggle,
                        child: Text(_running ? 'Pause' : 'Start'),
                      ),
                      OutlinedButton(
                        onPressed: _reset,
                        child: const Text('Reset'),
                      ),
                      if (!floating)
                        TextButton(
                          onPressed: _controller.enterFloating,
                          child: const Text('Float now'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const new(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
