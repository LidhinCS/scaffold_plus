/// Explicit async presentation state for `PlusAsyncView`.
///
/// Prefer mapping app/domain async values into this sealed hierarchy instead of
/// passing overlapping booleans (`isLoading` + `error` + `data`).
sealed class PlusAsyncState<T> {
  /// Creates a base async state.
  const new();
}

/// Content is currently loading.
final class PlusLoading<T> extends PlusAsyncState<T> {
  /// Creates a loading state.
  const new();
}

/// Content loaded successfully.
final class PlusSuccess<T> extends PlusAsyncState<T> {
  /// Creates a success state with [data].
  const new(this.data);

  /// The loaded value.
  final T data;
}

/// Content failed to load.
final class PlusFailure<T> extends PlusAsyncState<T> {
  /// Creates a failure state.
  const new(this.error, {this.stackTrace});

  /// Error object from the failed operation.
  final Object error;

  /// Optional stack trace associated with [error].
  final StackTrace? stackTrace;
}
