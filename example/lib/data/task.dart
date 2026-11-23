import 'package:equatable/equatable.dart';

/// A single inbox task in the Pulse Tasks showcase.
final class Task extends Equatable {
  /// Creates a task.
  const new({
    required this.id,
    required this.title,
    required this.notes,
    required this.createdAt,
    this.isDone = false,
  });

  /// Stable id.
  final String id;

  /// Short title.
  final String title;

  /// Optional details.
  final String notes;

  /// Whether the task is completed.
  final bool isDone;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Returns a copy with selective overrides.
  Task copyWith({
    String? id,
    String? title,
    String? notes,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, notes, isDone, createdAt];
}

/// A feed item for the Activity tab.
final class ActivityEvent extends Equatable {
  /// Creates an activity event.
  const new({required this.id, required this.message, required this.at});

  /// Stable id.
  final String id;

  /// Human-readable description.
  final String message;

  /// When the event happened.
  final DateTime at;

  @override
  List<Object?> get props => [id, message, at];
}

/// Page result from TaskRepository.fetchTasks.
final class TaskPage extends Equatable {
  /// Creates a page.
  const new({required this.items, required this.hasMore, required this.page});

  /// Tasks for this page.
  final List<Task> items;

  /// Whether another page exists.
  final bool hasMore;

  /// Zero-based page index that was loaded.
  final int page;

  @override
  List<Object?> get props => [items, hasMore, page];
}
