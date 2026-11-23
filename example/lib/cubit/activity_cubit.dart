import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_plus/ui_plus.dart';
import 'package:ui_plus_example/data/task.dart';
import 'package:ui_plus_example/data/task_repository.dart';

/// Activity feed presentation state.
final class ActivityState extends Equatable {
  /// Creates activity state.
  const new({this.status = const PlusLoading()});

  /// Async status for ScaffoldPlus / PlusAsyncView.
  final PlusAsyncState<List<ActivityEvent>> status;

  /// Copy with a new status.
  ActivityState copyWith({PlusAsyncState<List<ActivityEvent>>? status}) {
    return ActivityState(status: status ?? this.status);
  }

  @override
  List<Object?> get props => [status];
}

/// Loads activity events from [TaskRepository].
final class ActivityCubit extends Cubit<ActivityState> {
  /// Creates the cubit.
  new(this._repository) : super(const ActivityState());

  final TaskRepository _repository;

  /// Loads the activity list.
  Future<void> load() async {
    emit(state.copyWith(status: const PlusLoading()));
    try {
      final events = await _repository.fetchActivity();
      if (isClosed) {
        return;
      }
      emit(state.copyWith(status: PlusSuccess(events)));
    } on Object catch (error, stackTrace) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(status: PlusFailure(error, stackTrace: stackTrace)));
    }
  }
}
