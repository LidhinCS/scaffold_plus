import 'package:flutter/material.dart';

/// A navigation destination for [PlusAdaptiveScaffold].
class PlusNavigationDestination {
  /// Creates a destination.
  const new({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.tooltip,
  });

  /// Icon shown when the destination is not selected.
  final Widget icon;

  /// Icon shown when selected. Defaults to [icon].
  final Widget? selectedIcon;

  /// Short label for the destination.
  final String label;

  /// Optional tooltip.
  final String? tooltip;
}

/// Adaptive app shell that switches between bottom navigation and a rail.
///
/// Below [compactBreakpoint] width, destinations render as a
/// [NavigationBar]. At or above that width they render as a
/// [NavigationRail]. Body content stays fully app-owned so async /
/// connectivity concerns remain orthogonal (compose `ScaffoldPlus` inside
/// [body] when needed).
///
/// {@tool snippet}
/// ```dart
/// PlusAdaptiveScaffold(
///   destinations: const [
///     PlusNavigationDestination(
///       icon: Icon(Icons.home),
///       label: 'Home',
///     ),
///     PlusNavigationDestination(
///       icon: Icon(Icons.settings),
///       label: 'Settings',
///     ),
///   ],
///   selectedIndex: index,
///   onDestinationSelected: (i) => setState(() => index = i),
///   body: pages[index],
/// )
/// ```
/// {@end-tool}
class PlusAdaptiveScaffold extends StatelessWidget {
  /// Creates an adaptive navigation shell.
  const new({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    super.key,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.compactBreakpoint = 600,
    this.extendRailBreakpoint = 840,
    this.railLabelType,
    this.backgroundColor,
  }) : assert(destinations.length >= 2, 'At least two destinations required.'),
       assert(
         selectedIndex >= 0 && selectedIndex < destinations.length,
         'selectedIndex out of range.',
       );

  /// Navigation destinations (at least two).
  final List<PlusNavigationDestination> destinations;

  /// Currently selected destination index.
  final int selectedIndex;

  /// Called when the user selects a destination.
  final ValueChanged<int> onDestinationSelected;

  /// Primary content for the selected destination.
  final Widget body;

  /// Optional app bar (shown above body on all breakpoints).
  final PreferredSizeWidget? appBar;

  /// Optional FAB.
  final Widget? floatingActionButton;

  /// FAB location.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Width below which a bottom [NavigationBar] is used.
  final double compactBreakpoint;

  /// Width at or above which the rail uses [NavigationRailLabelType.all].
  final double extendRailBreakpoint;

  /// Override rail label type. When null, uses `none` between
  /// [compactBreakpoint] and [extendRailBreakpoint], and `all` above.
  final NavigationRailLabelType? railLabelType;

  /// Scaffold background color.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= compactBreakpoint;
        if (useRail) {
          return _buildRailScaffold(context, constraints.maxWidth);
        }
        return _buildBarScaffold(context);
      },
    );
  }

  Widget _buildBarScaffold(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
              label: destination.label,
              tooltip: destination.tooltip,
            ),
        ],
      ),
    );
  }

  Widget _buildRailScaffold(BuildContext context, double width) {
    final extended = width >= extendRailBreakpoint;
    // Flutter requires [NavigationRailLabelType.none] when [extended] is true.
    final labelType =
        railLabelType ??
        (extended ? NavigationRailLabelType.none : NavigationRailLabelType.all);

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: labelType,
            extended: extended,
            destinations: [
              for (final destination in destinations)
                NavigationRailDestination(
                  icon: destination.icon,
                  selectedIcon: destination.selectedIcon,
                  label: Text(destination.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
