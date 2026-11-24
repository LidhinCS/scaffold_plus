import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';
import 'package:ui_plus_example/cubit/tasks_cubit.dart';

/// Opens a compose bottom sheet and creates a task on submit.
Future<void> showTaskComposeSheet(BuildContext context) {
  return PlusBottomSheet.show<void>(
    context: context,
    title: 'New task',
    isScrollControlled: true,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: context.read<TasksCubit>(),
        child: const _TaskComposeForm(),
      );
    },
  );
}

class _TaskComposeForm extends StatefulWidget {
  const new();

  @override
  State<_TaskComposeForm> createState() => _TaskComposeFormState();
}

class _TaskComposeFormState extends State<_TaskComposeForm> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          PlusAsyncButton(
            onPressed: () async {
              await context.read<TasksCubit>().createTask(
                title: _titleController.text,
                notes: _notesController.text,
              );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            onError: (error, stackTrace) {
              PlusSnackbar.error(message: '$error');
            },
            successChild: const Text('Created'),
            child: const Text('Create task'),
          ),
        ],
      ),
    );
  }
}
