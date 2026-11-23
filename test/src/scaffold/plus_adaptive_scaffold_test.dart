import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusAdaptiveScaffold', () {
    const destinations = [
      PlusNavigationDestination(icon: Icon(Icons.home), label: 'Home'),
      PlusNavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
    ];

    testWidgets('uses NavigationBar below compact breakpoint', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: PlusAdaptiveScaffold(
            destinations: destinations,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            body: const Text('Body'),
          ),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('uses NavigationRail at or above compact breakpoint', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(900, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: PlusAdaptiveScaffold(
            destinations: destinations,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            body: const Text('Body'),
          ),
        ),
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('notifies on destination selected', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return PlusAdaptiveScaffold(
                destinations: destinations,
                selectedIndex: selected,
                onDestinationSelected: (index) {
                  setState(() => selected = index);
                },
                body: Text('Page $selected'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('shows appBar when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlusAdaptiveScaffold(
            destinations: destinations,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            appBar: AppBar(title: const Text('Shell')),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Shell'), findsOneWidget);
    });
  });
}
