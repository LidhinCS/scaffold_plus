import 'package:material_ui/material_ui.dart';

/// A basic skeleton placeholder shape for loading layouts.
///
/// Compose multiple [PlusSkeleton] widgets for custom layouts. Animation
/// respects reduced-motion via [MediaQuery.disableAnimationsOf] and can be
/// forced off via [animate] for tests or accessibility preferences.
///
/// {@tool snippet}
/// ```dart
/// PlusSkeleton(
///   width: double.infinity,
///   height: 16,
///   borderRadius: BorderRadius.circular(8),
/// )
/// ```
/// {@end-tool}
class PlusSkeleton extends StatefulWidget {
  /// Creates a skeleton placeholder.
  const new({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.baseColor,
    this.highlightColor,
    this.animate = true,
    this.duration = const Duration(milliseconds: 1200),
  });

  /// Skeleton width. Defaults to expanding within the parent when `null`.
  final double? width;

  /// Skeleton height. Defaults to `16`.
  final double height;

  /// Corner radius of the placeholder.
  final BorderRadiusGeometry borderRadius;

  /// Base fill color. Defaults to [ColorScheme.surfaceContainerHighest].
  final Color? baseColor;

  /// Highlight color used by the shimmer. Defaults to
  /// [ColorScheme.surfaceContainerLow].
  final Color? highlightColor;

  /// Whether to run the shimmer animation when motion is allowed.
  final bool animate;

  /// Duration of one shimmer cycle.
  final Duration duration;

  @override
  State<PlusSkeleton> createState() => _PlusSkeletonState();
}

class _PlusSkeletonState extends State<PlusSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant PlusSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate ||
        oldWidget.duration != widget.duration) {
      _syncAnimation();
    }
  }

  bool get _shouldAnimate {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return widget.animate && !disableAnimations;
  }

  void _syncAnimation() {
    if (_shouldAnimate) {
      _controller ??= AnimationController(
        vsync: this,
        duration: widget.duration,
      )..repeat();
      if (_controller!.duration != widget.duration) {
        _controller!
          ..duration = widget.duration
          ..repeat();
      } else if (!_controller!.isAnimating) {
        _controller!.repeat();
      }
    } else {
      _controller?.stop();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = widget.baseColor ?? colorScheme.surfaceContainerHighest;
    final highlightColor =
        widget.highlightColor ?? colorScheme.surfaceContainerLow;

    final box = _SkeletonBox(
      width: widget.width,
      height: widget.height,
      borderRadius: widget.borderRadius,
      color: baseColor,
    );

    if (!_shouldAnimate || _controller == null) {
      return box;
    }

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final progress = _controller!.value;
            return LinearGradient(
              begin: Alignment(-1.0 - progress * 2, 0),
              end: Alignment(1.0 - progress * 2, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: box,
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const new({
    required this.height,
    required this.borderRadius,
    required this.color,
    this.width,
  });

  final double? width;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
    );
  }
}
