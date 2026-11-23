import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusAsyncButton', () {
    testWidgets('shows loading and disables while future is pending', (
      tester,
    ) async {
      final completer = Completer<void>();
      var presses = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusAsyncButton(
              onPressed: () async {
                presses++;
                await completer.future;
              },
              child: const Text('Save'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(presses, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );

      // Second tap must not start another request while locked.
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(presses, 1);

      completer.complete();
      await tester.pumpAndSettle();
      expect(find.text('Save'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('shows success child then returns to idle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusAsyncButton(
              onPressed: () async {},
              successChild: const Text('Saved'),
              successDuration: const Duration(milliseconds: 100),
              child: const Text('Save'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(); // finish microtasks
      expect(find.text('Saved'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('onError swallows failures', (tester) async {
      Object? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusAsyncButton(
              onPressed: () async => throw StateError('boom'),
              onError: (error, stack) => captured = error,
              child: const Text('Save'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(captured, isA<StateError>());
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('supports tonal variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusAsyncButton(
              variant: PlusAsyncButtonVariant.tonal,
              onPressed: () async {},
              child: const Text('Go'),
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
    });
  });
}
