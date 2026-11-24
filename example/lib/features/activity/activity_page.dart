import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';
import 'package:ui_plus_example/cubit/activity_cubit.dart';
import 'package:ui_plus_example/cubit/app_shell_cubit.dart';
import 'package:ui_plus_example/data/task.dart';

/// Activity timeline using [ActivityCubit] + [ScaffoldPlus].
class ActivityPage extends StatefulWidget {
  /// Creates the activity page.
  const new({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(context.read<ActivityCubit>().load());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<AppShellCubit>().state;

    return BlocBuilder<ActivityCubit, ActivityState>(
      builder: (context, state) {
        return ScaffoldPlus<List<ActivityEvent>>(
          connectivityBanner: true,
          useBuiltInInternetCheck: !shell.forceOffline,
          isConnected: shell.forceOffline ? false : null,
          maintenanceMode: shell.maintenanceMode,
          sessionExpired: !shell.isSignedIn,
          sessionExpiredBuilder: (_) => PlusSessionExpired(
            actionLabel: 'Sign in',
            onAction: () => context.read<AppShellCubit>().signIn(),
          ),
          appBar: AppBar(title: const Text('Activity')),
          state: state.status,
          useSkeleton: true,
          isEmpty: (events) => events.isEmpty,
          onRetry: () => unawaited(context.read<ActivityCubit>().load()),
          onRefresh: () => context.read<ActivityCubit>().load(),
          bodyBuilder: (context, events) {
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: events.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.bolt_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(event.message),
                  subtitle: Text(_formatTime(event.at)),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime at) {
    final local = at.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} · $h:$m';
  }
}
