import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';
import 'package:ui_plus_example/app.dart';
import 'package:ui_plus_example/cubit/activity_cubit.dart';
import 'package:ui_plus_example/cubit/app_shell_cubit.dart';
import 'package:ui_plus_example/cubit/tasks_cubit.dart';
import 'package:ui_plus_example/data/task_repository.dart';

void main() {
  runApp(const PulseTasksApp());
}

/// Pulse Tasks — Bloc showcase host for `ui_plus`.
class PulseTasksApp extends StatefulWidget {
  /// Creates the app.
  ///
  /// Pass [useBuiltInInternetCheck]: false for widget tests / screenshot
  /// capture to avoid hanging on `PlusInternetChecker` HTTP probes.
  const new({super.key, this.useBuiltInInternetCheck = true});

  /// Whether pages should enable the built-in internet checker.
  final bool useBuiltInInternetCheck;

  @override
  State<PulseTasksApp> createState() => _PulseTasksAppState();
}

class _PulseTasksAppState extends State<PulseTasksApp> {
  late final TaskRepository _repository = TaskRepository();

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AppShellCubit(
              useBuiltInInternetCheck: widget.useBuiltInInternetCheck,
            ),
          ),
          BlocProvider(
            create: (context) => TasksCubit(context.read<TaskRepository>()),
          ),
          BlocProvider(
            create: (context) => ActivityCubit(context.read<TaskRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Pulse Tasks',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: PlusToastHost.messengerKey,
          builder: (context, child) => PlusToastHost(child: child!),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
            extensions: const [
              PlusTheme(
                searchDebounceDuration: Duration(milliseconds: 250),
                snackbarDuration: Duration(seconds: 3),
              ),
            ],
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            extensions: const [
              PlusTheme(
                searchDebounceDuration: Duration(milliseconds: 250),
                snackbarDuration: Duration(seconds: 3),
              ),
            ],
          ),
          home: const PulseTasksAppShell(),
        ),
      ),
    );
  }
}
