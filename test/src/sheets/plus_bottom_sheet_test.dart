import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusBottomSheet', () {
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

    testWidgets('show presents title and content', (tester) async {
      final context = await pumpHost(tester);

      final future = PlusBottomSheet.show<void>(
        context: context,
        title: 'Options',
        builder: (_) => const Text('sheet-body'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Options'), findsOneWidget);
      expect(find.text('sheet-body'), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      await future;
    });

    testWidgets('builder can pop a result', (tester) async {
      final context = await pumpHost(tester);

      final future = PlusBottomSheet.show<String>(
        context: context,
        builder: (sheetContext) {
          return TextButton(
            onPressed: () => Navigator.pop(sheetContext, 'picked'),
            child: const Text('Pick'),
          );
        },
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      expect(await future, 'picked');
    });

    testWidgets('showScrollable sizes sheet and scrolls content', (
      tester,
    ) async {
      final context = await pumpHost(tester);

      final future = PlusBottomSheet.showScrollable<void>(
        context: context,
        title: 'Scrollable',
        heightFactor: 0.5,
        builder: (_) =>
            ListView(children: [for (var i = 0; i < 30; i++) Text('Item $i')]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scrollable'), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      await future;
    });

    testWidgets('showDragHandle false still shows content', (tester) async {
      final context = await pumpHost(tester);

      final future = PlusBottomSheet.show<void>(
        context: context,
        showDragHandle: false,
        builder: (_) => const Text('no-handle'),
      );
      await tester.pumpAndSettle();

      expect(find.text('no-handle'), findsOneWidget);

      Navigator.of(context).pop();
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

      final future = PlusBottomSheet.show<void>(
        context: captured,
        title: 'Dark sheet',
        builder: (_) => const Text('body'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dark sheet'), findsOneWidget);
      Navigator.of(captured).pop();
      await tester.pumpAndSettle();
      await future;
    });
  });
}
