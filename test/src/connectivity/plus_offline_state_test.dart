import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_plus/scaffold_plus.dart';

void main() {
  group('PlusOfflineState', () {
    testWidgets('renders defaults', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: PlusOfflineState())),
        ),
      );

      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('invokes retry action', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusOfflineState(
              actionLabel: 'Try again',
              onRetry: () => retries++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    });

    testWidgets('supports custom action builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusOfflineState(
              actionBuilder: (_) => const Text('custom-action'),
            ),
          ),
        ),
      );

      expect(find.text('custom-action'), findsOneWidget);
    });

    testWidgets('does not overflow in a tight height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 132,
              child: PlusOfflineState(actionLabel: 'Retry', onRetry: () {}),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('No internet connection'), findsOneWidget);
    });
  });
}
