import 'package:flutter/widgets.dart';

/// Wraps state content so it centers in large areas and scrolls when tight.
///
/// Internal helper shared by empty / error / offline state widgets.
class PlusStateLayout extends StatelessWidget {
  /// Creates a constraint-aware state layout.
  const new({required this.padding, required this.child, super.key});

  /// Outer padding around the state content.
  final EdgeInsetsGeometry padding;

  /// State column (icon, copy, actions).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedHeight) {
            return child;
          }

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: child),
            ),
          );
        },
      ),
    );
  }
}
