import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/src/loaders/plus_loader.dart';

/// Infinite / paged list shell with load-more threshold and footer states.
///
/// Apps own the item list and paging flags. This widget detects near-end
/// scrolling, calls [onLoadMore], and renders loading / error / end footers —
/// patterns that plain [ListView] does not provide.
///
/// {@tool snippet}
/// ```dart
/// PlusPagedList<Item>(
///   items: items,
///   hasMore: hasMore,
///   isLoadingMore: isLoadingMore,
///   loadMoreError: error,
///   onLoadMore: fetchNextPage,
///   onRetryLoadMore: fetchNextPage,
///   itemBuilder: (context, item, index) => ListTile(title: Text(item.name)),
/// )
/// ```
/// {@end-tool}
class PlusPagedList<T> extends StatefulWidget {
  /// Creates a paged list shell.
  const new({
    required this.items,
    required this.itemBuilder,
    super.key,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.onLoadMore,
    this.onRetryLoadMore,
    this.loadMoreThreshold = 240,
    this.padding,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.primary,
    this.separatorBuilder,
    this.loadingFooter,
    this.endFooter,
    this.errorFooterBuilder,
    this.emptyBuilder,
  });

  /// Current page items (app-owned).
  final List<T> items;

  /// Builds a row for each item (`context`, item, index).
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Whether more pages are available.
  final bool hasMore;

  /// Whether a load-more request is in flight.
  final bool isLoadingMore;

  /// Optional error from the last load-more attempt.
  final Object? loadMoreError;

  /// Called when the user scrolls within [loadMoreThreshold] of the end and
  /// more pages are available. Not called while [isLoadingMore] is true or
  /// when [loadMoreError] is non-null.
  final VoidCallback? onLoadMore;

  /// Called from the default error footer retry action.
  final VoidCallback? onRetryLoadMore;

  /// Distance from the max scroll extent that triggers [onLoadMore].
  final double loadMoreThreshold;

  /// List padding.
  final EdgeInsetsGeometry? padding;

  /// Optional external scroll controller.
  final ScrollController? controller;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// Whether the list should shrink-wrap its contents.
  final bool shrinkWrap;

  /// Whether this is the primary scroll view.
  final bool? primary;

  /// Optional separator between items (not after the footer).
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Footer shown while [isLoadingMore] is true.
  final Widget? loadingFooter;

  /// Footer shown when [hasMore] is false and [items] is not empty.
  final Widget? endFooter;

  /// Footer builder when [loadMoreError] is non-null.
  final Widget Function(BuildContext context, Object error)? errorFooterBuilder;

  /// Built when [items] is empty and not loading more.
  final WidgetBuilder? emptyBuilder;

  @override
  State<PlusPagedList<T>> createState() => _PlusPagedListState<T>();
}

class _PlusPagedListState<T> extends State<PlusPagedList<T>> {
  bool _loadMoreRequested = false;

  @override
  void didUpdateWidget(covariant PlusPagedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length ||
        widget.isLoadingMore != oldWidget.isLoadingMore ||
        widget.loadMoreError != oldWidget.loadMoreError ||
        widget.hasMore != oldWidget.hasMore) {
      _loadMoreRequested = false;
    }
  }

  void _maybeLoadMore(ScrollMetrics metrics) {
    if (!widget.hasMore ||
        widget.isLoadingMore ||
        widget.loadMoreError != null ||
        widget.onLoadMore == null ||
        widget.items.isEmpty ||
        _loadMoreRequested) {
      return;
    }

    final remaining = metrics.maxScrollExtent - metrics.pixels;
    if (remaining <= widget.loadMoreThreshold) {
      _loadMoreRequested = true;
      widget.onLoadMore!();
    }
  }

  Widget _buildFooter(BuildContext context) {
    final error = widget.loadMoreError;
    if (error != null) {
      return widget.errorFooterBuilder?.call(context, error) ??
          _DefaultErrorFooter(
            error: error,
            onRetry: widget.onRetryLoadMore ?? widget.onLoadMore,
          );
    }
    if (widget.isLoadingMore) {
      return widget.loadingFooter ?? const _DefaultLoadingFooter();
    }
    if (!widget.hasMore && widget.items.isNotEmpty) {
      return widget.endFooter ?? const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoadingMore) {
      return widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }

    final hasSeparator = widget.separatorBuilder != null;

    // ListView.separated style: n items and n-1 separators, then footer.
    final childCount = hasSeparator
        ? (widget.items.isEmpty
              ? 1
              : widget.items.length * 2) // items + separators + footer slot
        : widget.items.length + 1;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          _maybeLoadMore(notification.metrics);
        }
        return false;
      },
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            _maybeLoadMore(notification.metrics);
          }
          return false;
        },
        child: ListView.builder(
          controller: widget.controller,
          padding: widget.padding,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          primary: widget.primary,
          itemCount: childCount,
          itemBuilder: (context, index) {
            if (hasSeparator) {
              final lastIndex = childCount - 1;
              if (index == lastIndex) {
                return _buildFooter(context);
              }
              if (index.isOdd) {
                return widget.separatorBuilder!(context, index ~/ 2);
              }
              final itemIndex = index ~/ 2;
              return widget.itemBuilder(
                context,
                widget.items[itemIndex],
                itemIndex,
              );
            }

            if (index == widget.items.length) {
              return _buildFooter(context);
            }
            return widget.itemBuilder(context, widget.items[index], index);
          },
        ),
      ),
    );
  }
}

class _DefaultLoadingFooter extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: PlusLoader(size: 28)),
    );
  }
}

class _DefaultErrorFooter extends StatelessWidget {
  const new({required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Could not load more',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
