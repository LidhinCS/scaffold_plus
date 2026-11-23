import 'package:flutter/material.dart';

/// A compact circular loading indicator.
///
/// Thin wrapper around [CircularProgressIndicator] with sensible defaults for
/// size, stroke width, theme color, and semantics.
///
/// {@tool snippet}
/// ```dart
/// const PlusLoader(
///   size: 32,
///   strokeWidth: 3,
/// )
/// ```
/// {@end-tool}
class PlusLoader extends StatelessWidget {
  /// Creates a circular loader.
  const new({
    super.key,
    this.size = 32,
    this.strokeWidth = 3,
    this.color,
    this.backgroundColor,
    this.semanticsLabel = 'Loading',
  });

  /// Width and height of the indicator. Defaults to `32`.
  final double size;

  /// Stroke width of the indicator. Defaults to `3`.
  final double strokeWidth;

  /// Indicator color. Defaults to [ColorScheme.primary].
  final Color? color;

  /// Track color behind the indicator arc.
  final Color? backgroundColor;

  /// Accessibility label announced for the indicator.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? colorScheme.primary,
        backgroundColor: backgroundColor,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}
