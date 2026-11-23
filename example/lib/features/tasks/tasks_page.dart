import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_plus/ui_plus.dart';
import 'package:ui_plus_example/cubit/app_shell_cubit.dart';
import 'package:ui_plus_example/cubit/tasks_cubit.dart';
import 'package:ui_plus_example/data/task.dart';
import 'package:ui_plus_example/features/tasks/task_compose_sheet.dart';

/// Tasks inbox powered by [TasksCubit] + [ScaffoldPlus].
class TasksPage extends StatefulWidget {
  /// Creates the tasks page.
  const new({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(context.read<TasksCubit>().load());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<AppShellCubit>().state;

    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, tasksState) {
        return ScaffoldPlus<List<Task>>(
          connectivityBanner: true,
          useBuiltInInternetCheck: !shell.forceOffline,
          isConnected: shell.forceOffline ? false : null,
          maintenanceMode: shell.maintenanceMode,
          sessionExpired: !shell.isSignedIn,
          permissionDenied: !shell.notificationsAllowed,
          sessionExpiredBuilder: (_) => PlusSessionExpired(
            message: 'Sign in again to manage your Pulse Tasks inbox.',
            actionLabel: 'Sign in',
            onAction: () => context.read<AppShellCubit>().signIn(),
          ),
          permissionBuilder: (_) => PlusPermissionState(
            title: 'Notifications required',
            message:
                'Pulse Tasks needs notification access for due reminders. '
                'Toggle permission back on in Settings to continue.',
            actionLabel: 'Allow notifications',
            onAction: () {
              context.read<AppShellCubit>().setNotificationsAllowed(
                allowed: true,
              );
              PlusSnackbar.success(message: 'Notifications enabled');
            },
          ),
          appBar: AppBar(
            title: const Text('Tasks'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: PlusSearchField(
                  hintText: 'Search tasks',
                  onChanged: (query) {
                    unawaited(context.read<TasksCubit>().search(query));
                  },
                ),
              ),
            ),
          ),
          state: tasksState.status,
          useSkeleton: true,
          isEmpty: (items) => items.isEmpty,
          onRetry: () => unawaited(context.read<TasksCubit>().load()),
          onRefresh: () => context.read<TasksCubit>().refresh(),
          onRefreshError: (error, stackTrace) {
            PlusSnackbar.error(message: 'Refresh failed');
          },
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => unawaited(showTaskComposeSheet(context)),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New task'),
          ),
          bodyBuilder: (context, items) {
            return PlusPagedList<Task>(
              items: items,
              hasMore: tasksState.hasMore,
              isLoadingMore: tasksState.isLoadingMore,
              loadMoreError: tasksState.loadMoreError,
              onLoadMore: () =>
                  unawaited(context.read<TasksCubit>().loadMore()),
              onRetryLoadMore: () {
                unawaited(context.read<TasksCubit>().retryLoadMore());
              },
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
              emptyBuilder: (context) => const PlusEmptyState(
                title: 'No tasks',
                description: 'Create a task or clear your search.',
              ),
              itemBuilder: (context, task, index) {
                return _TaskTile(task: task);
              },
            );
          },
        );
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  const new({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: IconButton(
          tooltip: task.isDone ? 'Mark open' : 'Mark done',
          onPressed: () {
            unawaited(context.read<TasksCubit>().toggleDone(task));
          },
          icon: Icon(
            task.isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: task.isDone ? scheme.primary : scheme.outline,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: task.notes.isEmpty ? null : Text(task.notes),
        trailing: IconButton(
          tooltip: 'Delete',
          onPressed: () async {
            final confirmed = await PlusConfirmationDialog.show(
              context,
              title: 'Delete task?',
              message: '“${task.title}” will be removed from your inbox.',
              confirmLabel: 'Delete',
              isDestructive: true,
            );
            if (!context.mounted || !confirmed) {
              return;
            }
            await context.read<TasksCubit>().deleteTask(task);
          },
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ),
    );
  }
}
