import 'dart:async';
import 'dart:math';

import 'package:ui_plus_example/data/task.dart';

/// In-memory fake API with latency, paging, search, and optional failures.
final class TaskRepository {
  /// Creates a repository with seeded demo tasks.
  new({Random? random, this.pageSize = 8}) : _random = random ?? Random(42) {
    _seed();
  }

  /// Items per page.
  final int pageSize;

  final Random _random;
  final List<Task> _tasks = [];
  final List<ActivityEvent> _activity = [];
  final StreamController<List<ActivityEvent>> _activityController =
      StreamController<List<ActivityEvent>>.broadcast();

  var _nextId = 1;
  var _failNextFetch = false;

  /// Live activity feed.
  Stream<List<ActivityEvent>> get activityStream => _activityController.stream;

  /// Snapshot of activity (newest first).
  List<ActivityEvent> get activity => List.unmodifiable(_activity);

  /// Forces the next fetchTasks call to fail once (for demo error UI).
  void failNextFetch() => _failNextFetch = true;

  /// Fetches a page of tasks, optionally filtered by [query].
  Future<TaskPage> fetchTasks({required int page, String query = ''}) async {
    await _delay();
    if (_failNextFetch) {
      _failNextFetch = false;
      throw StateError('Could not reach the Pulse Tasks API.');
    }

    final filtered = _filtered(query);
    final start = page * pageSize;
    if (start >= filtered.length) {
      return TaskPage(items: const [], hasMore: false, page: page);
    }
    final end = min(start + pageSize, filtered.length);
    return TaskPage(
      items: filtered.sublist(start, end),
      hasMore: end < filtered.length,
      page: page,
    );
  }

  /// Creates a task and records activity.
  Future<Task> createTask({required String title, String notes = ''}) async {
    await _delay(ms: 700);
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Title cannot be empty.');
    }
    final task = Task(
      id: 't${_nextId++}',
      title: trimmed,
      notes: notes.trim(),
      createdAt: DateTime.now(),
    );
    _tasks.insert(0, task);
    _pushActivity('Created “${task.title}”');
    return task;
  }

  /// Toggles completion.
  Future<Task> toggleDone(String id) async {
    await _delay(ms: 400);
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index < 0) {
      throw StateError('Task not found.');
    }
    final updated = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
    _tasks[index] = updated;
    _pushActivity(
      updated.isDone
          ? 'Completed “${updated.title}”'
          : 'Reopened “${updated.title}”',
    );
    return updated;
  }

  /// Deletes a task.
  Future<void> deleteTask(String id) async {
    await _delay(ms: 500);
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index < 0) {
      throw StateError('Task not found.');
    }
    final removed = _tasks.removeAt(index);
    _pushActivity('Deleted “${removed.title}”');
  }

  /// Loads the current activity list (async for ScaffoldPlus mapping).
  Future<List<ActivityEvent>> fetchActivity() async {
    await _delay(ms: 500);
    return activity;
  }

  /// Releases stream resources.
  void dispose() {
    unawaited(_activityController.close());
  }

  List<Task> _filtered(String query) {
    final q = query.trim().toLowerCase();
    final sorted = [..._tasks]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (q.isEmpty) {
      return sorted;
    }
    return sorted
        .where(
          (t) =>
              t.title.toLowerCase().contains(q) ||
              t.notes.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _delay({int ms = 550}) {
    final jitter = _random.nextInt(200);
    return Future<void>.delayed(Duration(milliseconds: ms + jitter));
  }

  void _pushActivity(String message) {
    final event = ActivityEvent(
      id: 'a${_activity.length + 1}',
      message: message,
      at: DateTime.now(),
    );
    _activity.insert(0, event);
    if (_activity.length > 40) {
      _activity.removeRange(40, _activity.length);
    }
    if (!_activityController.isClosed) {
      _activityController.add(activity);
    }
  }

  void _seed() {
    const titles = [
      'Ship ui_plus 0.4 notes',
      'Polish snackbar motion',
      'Wire PlusToastHost in app',
      'Review ScaffoldPlus gates',
      'Draft connectivity docs',
      'Add paged inbox demo',
      'Test adaptive rail layout',
      'Tighten empty states',
      'Confirm delete dialogs',
      'Map Bloc → PlusAsyncState',
      'Seed activity timeline',
      'Check dark theme tones',
      'Write example README',
      'Exercise pull-to-refresh',
      'Simulate offline banner',
      'Demo maintenance mode',
      'Permission denied sample',
      'Session expired re-auth',
      'Compose sheet with async button',
      'Search debounce pass',
    ];

    final now = DateTime.now();
    for (var i = 0; i < titles.length; i++) {
      _tasks.add(
        Task(
          id: 't${_nextId++}',
          title: titles[i],
          notes: i.isEven
              ? 'Tracked in the Pulse Tasks showcase.'
              : 'Open Settings to flip product-state gates.',
          createdAt: now.subtract(Duration(hours: i * 3, minutes: i * 7)),
          isDone: i % 5 == 0,
        ),
      );
    }
    _pushActivity('Welcome to Pulse Tasks');
    _pushActivity('Seeded ${titles.length} demo tasks');
  }
}
