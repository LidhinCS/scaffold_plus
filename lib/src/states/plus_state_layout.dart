import 'package:flutter/widgets.dart';

/// Wraps state content so it centers in large areas and scrolls when tight.
///
/// Internal helper shared by empty / error / offline state widgets.
///
/// Padding is applied **inside** the scroll view so the bottom of the content
/// (e.g. a retry button) is not clipped against the viewport edge.
class PlusStateLayout extends StatelessWidget {
  /// Creates a constraint-aware state layout.
  const new({required this.padding, required this.child, super.key});

  /// Outer padding around the state content.
  final EdgeInsetsGeometry padding;

  /// State column (icon, copy, actions).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          return Padding(padding: padding, child: child);
        }

        final resolved = padding.resolve(Directionality.of(context));
        final minHeight = (constraints.maxHeight - resolved.vertical).clamp(
          0.0,
          double.infinity,
        );

        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            // Column + center (not [Center]) so overflowing content grows the
            // scrollable instead of being clipped by a tight positioned box.
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [child],
            ),
          ),
        );
      },
    );
  }
}
