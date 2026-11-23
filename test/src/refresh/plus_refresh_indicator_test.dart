import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusRefreshIndicator', () {
    testWidgets('invokes onRefresh when pulled', (tester) async {
      var refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: PlusRefreshIndicator(
              onRefresh: () async {
                refreshed = true;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [SizedBox(height: 800, child: Text('content'))],
              ),
            ),
          ),
        ),
      );

      await tester.fling(find.text('content'), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(refreshed, isTrue);
    });

    testWidgets('onError catches refresh failures', (tester) async {
      Object? caught;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: PlusRefreshIndicator(
              onRefresh: () async {
                throw StateError('network');
              },
              onError: (error, stackTrace) {
                caught = error;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [SizedBox(height: 800, child: Text('content'))],
              ),
            ),
          ),
        ),
      );

      await tester.fling(find.text('content'), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(caught, isA<StateError>());
    });

    testWidgets('uses theme primary color by default', (tester) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: PlusRefreshIndicator(
              onRefresh: () async {},
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [SizedBox(height: 800, child: Text('content'))],
              ),
            ),
          ),
        ),
      );

      final indicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );
      expect(indicator.color, theme.colorScheme.primary);
    });
  });
}
