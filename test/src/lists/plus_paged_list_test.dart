import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusPagedList', () {
    testWidgets('renders items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusPagedList<String>(
              items: const ['A', 'B'],
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('calls onLoadMore near end', (tester) async {
      var loadMoreCount = 0;
      final items = List.generate(20, (i) => 'Item $i');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusPagedList<String>(
              items: items,
              hasMore: true,
              loadMoreThreshold: 400,
              onLoadMore: () => loadMoreCount++,
              itemBuilder: (context, item, index) =>
                  SizedBox(height: 80, child: Text(item)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      expect(loadMoreCount, greaterThanOrEqualTo(1));
    });

    testWidgets('shows loading footer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusPagedList<String>(
              items: const ['A'],
              hasMore: true,
              isLoadingMore: true,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.byType(PlusLoader), findsOneWidget);
    });

    testWidgets('shows error footer with retry', (tester) async {
      var retries = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusPagedList<String>(
              items: const ['A'],
              hasMore: true,
              loadMoreError: StateError('fail'),
              onRetryLoadMore: () => retries++,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('Could not load more'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retries, 1);
    });

    testWidgets('shows emptyBuilder when items empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusPagedList<String>(
              items: const [],
              emptyBuilder: (_) => const Text('Nothing'),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('Nothing'), findsOneWidget);
    });

    testWidgets('does not call onLoadMore while loading', (tester) async {
      var loadMoreCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusPagedList<String>(
              items: List.generate(20, (i) => 'Item $i'),
              hasMore: true,
              isLoadingMore: true,
              onLoadMore: () => loadMoreCount++,
              itemBuilder: (context, item, index) =>
                  SizedBox(height: 80, child: Text(item)),
            ),
          ),
        ),
      );
      // Loader animation never settles — use pump, not pumpAndSettle.
      await tester.pump();
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pump();

      expect(loadMoreCount, 0);
    });
  });
}
