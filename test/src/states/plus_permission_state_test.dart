import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusPermissionState', () {
    testWidgets('renders default title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlusPermissionState())),
      );

      expect(find.text('Permission required'), findsOneWidget);
      expect(
        find.textContaining('This feature needs permission to continue'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('shows primary and secondary actions', (tester) async {
      var primary = 0;
      var secondary = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusPermissionState(
              actionLabel: 'Open settings',
              onAction: () => primary++,
              secondaryActionLabel: 'Not now',
              onSecondaryAction: () => secondary++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open settings'));
      await tester.tap(find.text('Not now'));
      expect(primary, 1);
      expect(secondary, 1);
    });

    testWidgets('actionBuilder replaces default buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusPermissionState(
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
          home: const Scaffold(body: PlusPermissionState()),
        ),
      );

      expect(find.text('Permission required'), findsOneWidget);
    });
  });
}
