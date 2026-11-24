import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusSessionExpired', () {
    testWidgets('renders default title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlusSessionExpired())),
      );

      expect(find.text('Session expired'), findsOneWidget);
      expect(find.textContaining('Your session has ended'), findsOneWidget);
      expect(find.byIcon(Icons.lock_clock_outlined), findsOneWidget);
    });

    testWidgets('shows primary and secondary actions', (tester) async {
      var primary = 0;
      var secondary = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusSessionExpired(
              actionLabel: 'Sign in',
              onAction: () => primary++,
              secondaryActionLabel: 'Dismiss',
              onSecondaryAction: () => secondary++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sign in'));
      await tester.tap(find.text('Dismiss'));
      expect(primary, 1);
      expect(secondary, 1);
    });

    testWidgets('supports dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: const Scaffold(body: PlusSessionExpired()),
        ),
      );

      expect(find.text('Session expired'), findsOneWidget);
    });
  });
}
