import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusConfirmationDialog', () {
    Future<BuildContext> pumpHost(WidgetTester tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                captured = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      return captured;
    }

    testWidgets('returns true when confirmed', (tester) async {
      final context = await pumpHost(tester);

      final future = PlusConfirmationDialog.show(
        context,
        title: 'Delete?',
        message: 'Cannot be undone',
        confirmLabel: 'Delete',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(await future, isTrue);
    });

    testWidgets('returns false when cancelled', (tester) async {
      final context = await pumpHost(tester);

      final future = PlusConfirmationDialog.show(
        context,
        title: 'Delete?',
        confirmLabel: 'Delete',
        cancelLabel: 'Keep',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keep'));
      await tester.pumpAndSettle();

      expect(await future, isFalse);
    });

    testWidgets('returns false when barrier dismissed', (tester) async {
      final context = await pumpHost(tester);

      final future = PlusConfirmationDialog.show(context, title: 'Sure?');
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(await future, isFalse);
    });

    testWidgets('destructive confirm uses error color', (tester) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      );
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                captured = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final future = PlusConfirmationDialog.show(
        captured,
        title: 'Delete?',
        confirmLabel: 'Delete',
        isDestructive: true,
      );
      await tester.pumpAndSettle();

      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Delete'),
      );
      expect(
        button.style?.foregroundColor?.resolve({}),
        theme.colorScheme.error,
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(await future, isTrue);
    });

    testWidgets('non-destructive confirm uses FilledButton', (tester) async {
      final context = await pumpHost(tester);

      final future = PlusConfirmationDialog.show(
        context,
        title: 'Continue?',
        confirmLabel: 'Continue',
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(await future, isTrue);
    });
  });
}
