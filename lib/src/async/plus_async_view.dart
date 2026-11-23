import 'package:flutter/material.dart';
import 'package:ui_plus/src/async/plus_async_body.dart';
import 'package:ui_plus/src/async/plus_async_state.dart';
import 'package:ui_plus/src/async/plus_async_types.dart';

/// Renders loading, failure, empty, or success UI from a single [state].
///
/// Use inside an existing [Scaffold] (or any parent). For a scaffold that owns
/// async switching, prefer `ScaffoldPlus`.
///
/// Both widgets share the same internal renderer. Precedence:
/// 1. [PlusLoading] → [loadingBuilder] → skeleton → loader
/// 2. [PlusFailure] → [errorBuilder] → default error
/// 3. [PlusSuccess] → [emptyBuilder] when [isEmpty] is true, else [builder]
///
/// See `doc/async_view_design.md` for the design rationale.
///
/// {@tool snippet}
/// ```dart
/// PlusAsyncView<User>(
///   state: state,
///   isEmpty: (user) => user.items.isEmpty,
///   onRetry: reload,
///   builder: (context, user) => UserProfile(user: user),
/// )
/// ```
/// {@end-tool}
class PlusAsyncView<T> extends StatelessWidget {
  /// Creates an async view for [state].
  const new({
    required this.state,
    required this.builder,
    super.key,
    this.isEmpty,
    this.onRetry,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.useSkeleton = false,
    this.skeletonBuilder,
  });

  /// Current async presentation state.
  final PlusAsyncState<T> state;

  /// Builds the success UI for non-empty data.
  final PlusAsyncDataBuilder<T> builder;

  /// Optional predicate that marks success data as empty.
  final PlusAsyncEmptyPredicate<T>? isEmpty;

  /// Optional retry callback used by the default error UI.
  final VoidCallback? onRetry;

  /// Optional loading UI. Defaults to a centered loader (or skeleton).
  final WidgetBuilder? loadingBuilder;

  /// Optional empty UI. Defaults to an empty-state widget.
  final WidgetBuilder? emptyBuilder;

  /// Optional error UI. Defaults to an error-state widget.
  final PlusAsyncErrorBuilder? errorBuilder;

  /// When true and [loadingBuilder] is null, show a default skeleton.
  final bool useSkeleton;

  /// Optional custom skeleton for the loading state.
  final WidgetBuilder? skeletonBuilder;

  @override
  Widget build(BuildContext context) {
    return PlusAsyncBody<T>(
      state: state,
      builder: builder,
      isEmpty: isEmpty,
      onRetry: onRetry,
      loadingBuilder: loadingBuilder,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      useSkeleton: useSkeleton,
      skeletonBuilder: skeletonBuilder,
    );
  }
}
