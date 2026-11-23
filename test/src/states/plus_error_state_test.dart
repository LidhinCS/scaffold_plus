import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_plus/scaffold_plus.dart';

void main() {
  group('PlusErrorState', () {
    testWidgets('renders title by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PlusErrorState(title: 'Something went wrong')),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('renders message, custom icon, and retry', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusErrorState(
              title: 'Load failed',
              message: 'Unable to load your data.',
              icon: Icons.cloud_off,
              actionLabel: 'Try again',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Load failed'), findsOneWidget);
      expect(find.text('Unable to load your data.'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('hides icon when icon is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PlusErrorState(title: 'Error', icon: null)),
        ),
      );

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('prefers illustration over icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlusErrorState(
              title: 'Error',
              illustration: FlutterLogo(size: 48),
            ),
          ),
        ),
      );

      expect(find.byType(FlutterLogo), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('does not show action without onRetry', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlusErrorState(title: 'Error', actionLabel: 'Try again'),
          ),
        ),
      );

      expect(find.text('Try again'), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('supports light and dark themes', (tester) async {
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
              body: PlusErrorState(
                title: 'Error',
                message: 'Please try again.',
              ),
            ),
          ),
        );
      }

      await pumpWithBrightness(Brightness.light);
      expect(find.text('Error'), findsOneWidget);

      await pumpWithBrightness(Brightness.dark);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Please try again.'), findsOneWidget);
    });

    testWidgets('handles long text and text scaling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: PlusErrorState(
                  title:
                      'This is a particularly long error '
                      'state title for scaling',
                  message:
                      'And a long message that should wrap without '
                      'overflowing when the user increases text scale.',
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('particularly long error'), findsOneWidget);
    });

    testWidgets('fits small screen constraints', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 480));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              height: 400,
              child: PlusErrorState(
                title: 'Compact error',
                message: 'Works in tight layouts.',
                actionLabel: 'Retry',
                onRetry: _noop,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Compact error'), findsOneWidget);
    });

    testWidgets('exposes semantics label for content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlusErrorState(
              title: 'Request failed',
              message: 'Check your connection and try again.',
              actionLabel: 'Try again',
              onRetry: _noop,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(
          'Request failed. Check your connection and try again.',
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Try again'), findsOneWidget);
    });

    testWidgets('uses error color for default icon', (tester) async {
      const errorColor = Color(0xFFB00020);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)
                .copyWith(error: errorColor),
            useMaterial3: true,
          ),
          home: const Scaffold(body: PlusErrorState(title: 'Error')),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, errorColor);
    });
  });
}

void _noop() {}
