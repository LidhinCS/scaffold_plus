import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusMaintenanceMode', () {
    testWidgets('renders default title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlusMaintenanceMode())),
      );

      expect(find.text("We'll be back soon"), findsOneWidget);
      expect(
        find.text(
          'Scheduled maintenance is in progress. Please try again later.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.construction_outlined), findsOneWidget);
    });

    testWidgets('shows action when label and callback are set', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusMaintenanceMode(
              actionLabel: 'Check status',
              onAction: () => taps++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Check status'));
      expect(taps, 1);
    });

    testWidgets('actionBuilder replaces default button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusMaintenanceMode(
              actionLabel: 'Ignored',
              onAction: () {},
              actionBuilder: (_) => const Text('Custom action'),
            ),
          ),
        ),
      );

      expect(find.text('Custom action'), findsOneWidget);
      expect(find.text('Ignored'), findsNothing);
    });

    testWidgets('supports dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: const Scaffold(body: PlusMaintenanceMode()),
        ),
      );

      expect(find.text("We'll be back soon"), findsOneWidget);
    });
  });
}
