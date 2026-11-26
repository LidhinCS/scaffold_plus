import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusFeedback', () {
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

    test('messageFor strips Exception prefix', () {
      expect(PlusFeedback.messageFor(Exception('boom')), 'boom');
      expect(PlusFeedback.messageFor('plain'), 'plain');
    });

    testWidgets('success shows snackbar', (tester) async {
      final context = await pumpHost(tester);

      PlusFeedback.success(context: context, message: 'Saved');
      await tester.pumpAndSettle();

      expect(find.text('Saved'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('failure shows error snackbar by default', (tester) async {
      final context = await pumpHost(tester);

      await PlusFeedback.failure(
        context: context,
        error: Exception('network down'),
      );
      await tester.pumpAndSettle();

      expect(find.text('network down'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('failure blocking shows dialog', (tester) async {
      final context = await pumpHost(tester);

      final future = PlusFeedback.failure(
        context: context,
        error: Exception('fatal'),
        blocking: true,
        title: 'Could not save',
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not save'), findsOneWidget);
      expect(find.text('fatal'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await future;
    });

    testWidgets('result success path', (tester) async {
      final context = await pumpHost(tester);

      await PlusFeedback.result(context: context, successMessage: 'Done');
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('result error path uses mapError', (tester) async {
      final context = await pumpHost(tester);

      await PlusFeedback.result(
        context: context,
        error: StateError('x'),
        mapError: (e) => 'Mapped: $e',
        successMessage: 'Should not show',
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Mapped:'), findsOneWidget);
      expect(find.text('Should not show'), findsNothing);
    });

    testWidgets('run reports success', (tester) async {
      final context = await pumpHost(tester);

      final value = await PlusFeedback.run(
        context: context,
        action: () async => 42,
        successMessage: 'Loaded',
      );
      await tester.pumpAndSettle();

      expect(value, 42);
      expect(find.text('Loaded'), findsOneWidget);
    });

    testWidgets('run reports failure and returns null', (tester) async {
      final context = await pumpHost(tester);
      Object? seen;

      final value = await PlusFeedback.run<int>(
        context: context,
        action: () async => throw Exception('nope'),
        onError: (error, stack) => seen = error,
      );
      await tester.pumpAndSettle();

      expect(value, isNull);
      expect(seen, isA<Exception>());
      expect(find.text('nope'), findsOneWidget);
    });

    testWidgets('run rethrowError propagates', (tester) async {
      final context = await pumpHost(tester);

      await expectLater(
        () => PlusFeedback.run<void>(
          context: context,
          action: () async => throw Exception('boom'),
          rethrowError: true,
        ),
        throwsA(isA<Exception>()),
      );
      await tester.pumpAndSettle();
      expect(find.text('boom'), findsOneWidget);
    });
  });
}
