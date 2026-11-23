import 'package:flutter/material.dart';
import 'package:ui_plus/src/async/plus_async_state.dart';
import 'package:ui_plus/src/async/plus_async_types.dart';
import 'package:ui_plus/src/loaders/plus_loader.dart';
import 'package:ui_plus/src/loaders/plus_skeleton.dart';
import 'package:ui_plus/src/states/plus_empty_state.dart';
import 'package:ui_plus/src/states/plus_error_state.dart';

/// Shared async state renderer used by `PlusAsyncView` and `ScaffoldPlus`.
///
/// Not exported from the package barrel. Precedence:
/// 1. [PlusLoading] → [loadingBuilder] → skeleton (if enabled) → [PlusLoader]
/// 2. [PlusFailure] → [errorBuilder] → [PlusErrorState]
/// 3. [PlusSuccess] → empty if [isEmpty] → else [builder]
class PlusAsyncBody<T> extends StatelessWidget {
  /// Creates the shared async body renderer.
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

  /// Optional loading UI.
  final WidgetBuilder? loadingBuilder;

  /// Optional empty UI.
  final WidgetBuilder? emptyBuilder;

  /// Optional error UI.
  final PlusAsyncErrorBuilder? errorBuilder;

  /// When true and [loadingBuilder] is null, show a skeleton instead of
  /// [PlusLoader].
  final bool useSkeleton;

  /// Optional custom skeleton that overrides the default when [useSkeleton]
  /// is true.
  final WidgetBuilder? skeletonBuilder;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      PlusLoading<T>() => _buildLoading(context),
      PlusFailure<T>(:final error, :final stackTrace) =>
        errorBuilder?.call(context, error, stackTrace) ?? _defaultError(),
      PlusSuccess<T>(:final data) =>
        (isEmpty?.call(data) ?? false)
            ? (emptyBuilder?.call(context) ?? _defaultEmpty())
            : builder(context, data),
    };
  }

  Widget _buildLoading(BuildContext context) {
    if (loadingBuilder != null) {
      return loadingBuilder!(context);
    }
    if (useSkeleton) {
      return skeletonBuilder?.call(context) ?? _defaultSkeleton();
    }
    return _defaultLoading();
  }

  Widget _defaultLoading() {
    return const Center(child: PlusLoader());
  }

  Widget _defaultSkeleton() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlusSkeleton(height: 20, width: 180),
          SizedBox(height: 12),
          PlusSkeleton(height: 14),
          SizedBox(height: 8),
          PlusSkeleton(height: 14, width: 220),
          SizedBox(height: 24),
          PlusSkeleton(height: 120),
        ],
      ),
    );
  }

  Widget _defaultEmpty() {
    return const Center(
      child: PlusEmptyState(
        title: 'Nothing here yet',
        description: 'There is no content to show.',
      ),
    );
  }

  Widget _defaultError() {
    return Center(
      child: PlusErrorState(
        title: 'Something went wrong',
        message: 'Unable to load your data.',
        actionLabel: onRetry == null ? null : 'Try again',
        onRetry: onRetry,
      ),
    );
  }
}
