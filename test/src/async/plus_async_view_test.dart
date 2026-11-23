import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusAsyncView', () {
    testWidgets('shows default loader for PlusLoading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlusAsyncView<String>(
              state: PlusLoading(),
              builder: _successBuilder,
            ),
          ),
        ),
      );

      expect(find.byType(PlusLoader), findsOneWidget);
      expect(find.text('success:data'), findsNothing);
    });

    testWidgets('shows success builder for PlusSuccess', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlusAsyncView<String>(
              state: PlusSuccess('hello'),
              builder: _successBuilder,
            ),
          ),
        ),
      );

      expect(find.text('success:hello'), findsOneWidget);
    });

    testWidgets('shows empty when isEmpty is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusAsyncView<List<String>>(
              state: const PlusSuccess([]),
              isEmpty: (items) => items.isEmpty,
              builder: (context, items) => Text('count:${items.length}'),
            ),
          ),
        ),
      );

      expect(find.byType(PlusEmptyState), findsOneWidget);
      expect(find.textContaining('count:'), findsNothing);
    });

    testWidgets('shows default error for PlusFailure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlusAsyncView<String>(
              state: PlusFailure('boom'),
              builder: _successBuilder,
              onRetry: _noop,
            ),
          ),
        ),
      );

      expect(find.byType(PlusErrorState), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('success:data'), findsNothing);
    });

    testWidgets('uses custom builders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusAsyncView<String>(
              state: const PlusLoading(),
              loadingBuilder: (_) => const Text('custom-loading'),
              builder: _successBuilder,
            ),
          ),
        ),
      );
      expect(find.text('custom-loading'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusAsyncView<String>(
              state: const PlusFailure('x'),
              errorBuilder: (context, error, stackTrace) =>
                  Text('custom-error:$error'),
              builder: _successBuilder,
            ),
          ),
        ),
      );
      expect(find.text('custom-error:x'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusAsyncView<String>(
              state: const PlusSuccess(''),
              isEmpty: (value) => value.isEmpty,
              emptyBuilder: (_) => const Text('custom-empty'),
              builder: _successBuilder,
            ),
          ),
        ),
      );
      expect(find.text('custom-empty'), findsOneWidget);
    });

    testWidgets('loading takes precedence over any success/empty logic', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusAsyncView<String>(
              state: const PlusLoading(),
              isEmpty: (_) => true,
              emptyBuilder: (_) => const Text('empty'),
              builder: _successBuilder,
            ),
          ),
        ),
      );

      expect(find.byType(PlusLoader), findsOneWidget);
      expect(find.text('empty'), findsNothing);
    });

    testWidgets('failure never falls through to success builder', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlusAsyncView<String>(
              state: PlusFailure('nope'),
              builder: _successBuilder,
            ),
          ),
        ),
      );

      expect(find.byType(PlusErrorState), findsOneWidget);
      expect(find.textContaining('success:'), findsNothing);
    });

    testWidgets('onRetry is wired to default error action', (tester) async {
      var retries = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusAsyncView<String>(
              state: const PlusFailure('err'),
              onRetry: () => retries++,
              builder: _successBuilder,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    });

    testWidgets('useSkeleton shows default skeleton layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlusAsyncView<String>(
              state: PlusLoading(),
              builder: _successBuilder,
              useSkeleton: true,
            ),
          ),
        ),
      );

      expect(find.byType(PlusSkeleton), findsWidgets);
      expect(find.byType(PlusLoader), findsNothing);
    });

    testWidgets('skeletonBuilder overrides default skeleton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusAsyncView<String>(
              state: const PlusLoading(),
              builder: _successBuilder,
              useSkeleton: true,
              skeletonBuilder: (_) => const Text('custom-skeleton'),
            ),
          ),
        ),
      );

      expect(find.text('custom-skeleton'), findsOneWidget);
    });

    testWidgets('supports light and dark themes with defaults', (tester) async {
      Future<void> pumpWithBrightness(Brightness brightness) {
        return tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: brightness,
              ),
              useMaterial3: true,
            ),
            home: const Scaffold(
              body: PlusAsyncView<String>(
                state: PlusFailure('err'),
                builder: _successBuilder,
              ),
            ),
          ),
        );
      }

      await pumpWithBrightness(Brightness.light);
      expect(find.byType(PlusErrorState), findsOneWidget);

      await pumpWithBrightness(Brightness.dark);
      expect(find.byType(PlusErrorState), findsOneWidget);
    });
  });

  group('PlusAsyncState', () {
    test('constructs sealed variants', () {
      const loading = PlusLoading<int>();
      const success = PlusSuccess<int>(42);
      final failure = PlusFailure<int>(
        Exception('x'),
        stackTrace: StackTrace.current,
      );

      expect(loading, isA<PlusAsyncState<int>>());
      expect(success.data, 42);
      expect(failure.error, isA<Exception>());
      expect(failure.stackTrace, isNotNull);
    });
  });
}

Widget _successBuilder(BuildContext context, String data) {
  return Text('success:$data');
}

void _noop() {}
