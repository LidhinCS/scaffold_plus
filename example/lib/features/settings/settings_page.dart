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
      useBuiltInInternetCheck: !shell.forceOffline,
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
