import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_plus/ui_plus.dart';
import 'package:ui_plus_example/data/task.dart';
import 'package:ui_plus_example/data/task_repository.dart';

/// Domain state for the tasks inbox (mapped to PlusAsyncState at the UI).
final class TasksState extends Equatable {
  /// Creates tasks state.
  const new({
    this.status = const PlusLoading(),
    this.items = const [],
    this.query = '',
    this.page = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  /// Initial / refresh async status for ScaffoldPlus.
  final PlusAsyncState<List<Task>> status;

  /// Accumulated items across pages.
  final List<Task> items;

  /// Active search query.
  final String query;

  /// Last successfully loaded page index.
  final int page;

  /// Whether more pages exist.
  final bool hasMore;

  /// Load-more in flight.
  final bool isLoadingMore;

  /// Last load-more failure, if any.
  final Object? loadMoreError;

  /// Convenience: success payload or [items].
  List<Task> get visibleItems => switch (status) {
    PlusSuccess(:final data) => data,
    _ => items,
  };

  /// Copy with overrides.
  TasksState copyWith({
    PlusAsyncState<List<Task>>? status,
    List<Task>? items,
    String? query,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return TasksState(
      status: status ?? this.status,
      items: items ?? this.items,
      query: query ?? this.query,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearLoadMoreError
          ? null
          : (loadMoreError ?? this.loadMoreError),
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    query,
    page,
    hasMore,
    isLoadingMore,
    loadMoreError,
  ];
}

/// Loads, searches, pages, and mutates tasks via [TaskRepository].
final class TasksCubit extends Cubit<TasksState> {
  /// Creates the cubit.
  new(this._repository) : super(const TasksState());

  final TaskRepository _repository;
  var _loadGeneration = 0;

  /// Initial / retry load.
  Future<void> load({bool showLoading = true}) async {
    final generation = ++_loadGeneration;
    if (showLoading) {
      emit(
        state.copyWith(
          status: const PlusLoading(),
          items: const [],
          page: 0,
          hasMore: false,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ),
      );
    }

    try {
      final page = await _repository.fetchTasks(page: 0, query: state.query);
      if (generation != _loadGeneration || isClosed) {
        return;
      }
      emit(
        state.copyWith(
          status: PlusSuccess(page.items),
          items: page.items,
          page: 0,
          hasMore: page.hasMore,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ),
      );
    } on Object catch (error, stackTrace) {
      if (generation != _loadGeneration || isClosed) {
        return;
      }
      emit(
        state.copyWith(
          status: PlusFailure(error, stackTrace: stackTrace),
          items: const [],
          hasMore: false,
        ),
      );
      PlusSnackbar.error(message: 'Could not load tasks');
    }
  }

  /// Pull-to-refresh without blanking the list into a full-page loader.
  Future<void> refresh() => load(showLoading: false);

  /// Updates search query and reloads from page 0.
  Future<void> search(String query) async {
    emit(state.copyWith(query: query));
    await load();
  }

  /// Loads the next page when available.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.loadMoreError != null) {
      return;
    }
    if (state.status is! PlusSuccess) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    final nextPage = state.page + 1;
    try {
      final page = await _repository.fetchTasks(
        page: nextPage,
        query: state.query,
      );
      if (isClosed) {
        return;
      }
      final merged = [...state.items, ...page.items];
      emit(
        state.copyWith(
          status: PlusSuccess(merged),
          items: merged,
          page: nextPage,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Object catch (error) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(isLoadingMore: false, loadMoreError: error));
    }
  }

  /// Retries a failed load-more.
  Future<void> retryLoadMore() async {
    emit(state.copyWith(clearLoadMoreError: true));
    await loadMore();
  }

  /// Creates a task then reloads.
  Future<void> createTask({required String title, String notes = ''}) async {
    final task = await PlusFeedback.run(
      action: () => _repository.createTask(title: title, notes: notes),
      successMessage: 'Created “$title”',
      rethrowError: true,
    );
    if (task == null || isClosed) {
      return;
    }
    await load(showLoading: false);
  }

  /// Toggles done and patches local list.
  Future<void> toggleDone(Task task) async {
    try {
      final updated = await _repository.toggleDone(task.id);
      final next = state.items
          .map((t) => t.id == updated.id ? updated : t)
          .toList();
      emit(state.copyWith(status: PlusSuccess(next), items: next));
      PlusSnackbar.info(
        message: updated.isDone ? 'Marked done' : 'Marked open',
      );
    } on Object catch (error) {
      PlusSnackbar.error(message: '$error');
    }
  }

  /// Deletes after UI confirmation.
  Future<void> deleteTask(Task task) async {
    final deleted = await PlusFeedback.run(
      action: () async {
        await _repository.deleteTask(task.id);
        return task;
      },
      successMessage: 'Deleted “${task.title}”',
    );
    if (deleted == null || isClosed) {
      return;
    }
    final next = state.items.where((t) => t.id != task.id).toList();
    emit(state.copyWith(status: PlusSuccess(next), items: next));
  }

  /// Demo helper: next fetch fails once.
  void armFetchFailure() => _repository.failNextFetch();
}
