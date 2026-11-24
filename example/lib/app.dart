import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';
import 'package:ui_plus_example/cubit/app_shell_cubit.dart';
import 'package:ui_plus_example/features/activity/activity_page.dart';
import 'package:ui_plus_example/features/settings/settings_page.dart';
import 'package:ui_plus_example/features/tasks/tasks_page.dart';

/// Root adaptive shell for Pulse Tasks.
class PulseTasksAppShell extends StatelessWidget {
  /// Creates the shell.
  const new({super.key});

  static const _destinations = [
    PlusNavigationDestination(
      icon: Icon(Icons.check_circle_outline_rounded),
      selectedIcon: Icon(Icons.check_circle_rounded),
      label: 'Tasks',
    ),
    PlusNavigationDestination(
      icon: Icon(Icons.bolt_outlined),
      selectedIcon: Icon(Icons.bolt_rounded),
      label: 'Activity',
    ),
    PlusNavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppShellCubit, AppShellState>(
      buildWhen: (previous, current) => previous.tabIndex != current.tabIndex,
      builder: (context, state) {
        return PlusAdaptiveScaffold(
          destinations: _destinations,
          selectedIndex: state.tabIndex,
          onDestinationSelected: context.read<AppShellCubit>().selectTab,
          body: IndexedStack(
            index: state.tabIndex,
            children: const [TasksPage(), ActivityPage(), SettingsPage()],
          ),
        );
      },
    );
  }
}
