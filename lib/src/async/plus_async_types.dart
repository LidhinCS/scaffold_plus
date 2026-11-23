import 'package:flutter/widgets.dart';

/// Builds the success body when async data is available.
typedef PlusAsyncDataBuilder<T> = Widget Function(BuildContext context, T data);

/// Builds the failure body for async rendering.
typedef PlusAsyncErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
);

/// Returns whether success [data] should render as empty.
typedef PlusAsyncEmptyPredicate<T> = bool Function(T data);
