import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusDialog', () {
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

    testWidgets('alert shows title and message', (tester) async {
      final context = await pumpHost(tester);

      final future = PlusDialog.alert(
        context,
        title: 'Notice',
        message: 'Something happened',
      );
      await tester.pumpAndSettle();

      expect(find.text('Notice'), findsOneWidget);
      expect(find.text('Something happened'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await future;
    });

    testWidgets('show supports custom actions', (tester) async {
      final context = await pumpHost(tester);
      var accepted = false;

      final future = PlusDialog.show<void>(
        context,
        title: 'Custom',
        message: 'Body',
        actions: [
          TextButton(
            onPressed: () {
              accepted = true;
              Navigator.of(context).pop();
            },
            child: const Text('Accept'),
          ),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();
      await future;

      expect(accepted, isTrue);
    });

    testWidgets('show uses content widget when provided', (tester) async {
      final context = await pumpHost(tester);

      final future = PlusDialog.show<void>(
        context,
        title: 'Custom content',
        content: const Text('widget-body'),
      );
      await tester.pumpAndSettle();

      expect(find.text('widget-body'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await future;
    });

    testWidgets('supports dark theme', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
          ),
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

      final future = PlusDialog.alert(
        captured,
        title: 'Dark',
        message: 'Theme ok',
      );
      await tester.pumpAndSettle();

      expect(find.text('Dark'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await future;
    });
  });
}
