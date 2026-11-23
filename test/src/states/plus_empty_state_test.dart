import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_plus/scaffold_plus.dart';

void main() {
  group('PlusEmptyState', () {
    testWidgets('renders title by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PlusEmptyState(title: 'Nothing here yet')),
        ),
      );

      expect(find.text('Nothing here yet'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('renders description, custom icon, and action', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusEmptyState(
              title: 'No results',
              description: 'Try a different search.',
              icon: Icons.search_off,
              actionLabel: 'Clear filters',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No results'), findsOneWidget);
      expect(find.text('Try a different search.'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      expect(tapped, isTrue);
    });

    testWidgets('hides icon when icon is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PlusEmptyState(title: 'Empty', icon: null)),
        ),
      );

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('prefers illustration over icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlusEmptyState(
              title: 'Empty',
              illustration: FlutterLogo(size: 48),
            ),
          ),
        ),
      );

      expect(find.byType(FlutterLogo), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets('does not show action without onAction', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlusEmptyState(title: 'Empty', actionLabel: 'Refresh'),
          ),
        ),
      );

      expect(find.text('Refresh'), findsNothing);
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
              body: PlusEmptyState(title: 'Empty', description: 'No items'),
            ),
          ),
        );
      }

      await pumpWithBrightness(Brightness.light);
      expect(find.text('Empty'), findsOneWidget);

      await pumpWithBrightness(Brightness.dark);
      expect(find.text('Empty'), findsOneWidget);
      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('handles long text and text scaling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: PlusEmptyState(
                  title:
                      'This is a particularly long empty '
                      'state title for scaling',
                  description:
                      'And a long description that should wrap without '
                      'overflowing when the user increases text scale.',
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('particularly long empty'), findsOneWidget);
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
              child: PlusEmptyState(
                title: 'Compact empty',
                description: 'Works in tight layouts.',
                actionLabel: 'Retry',
                onAction: _noop,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Compact empty'), findsOneWidget);
    });

    testWidgets('exposes semantics label for content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlusEmptyState(
              title: 'Inbox empty',
              description: 'New mail will show up here.',
              actionLabel: 'Refresh',
              onAction: _noop,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Inbox empty. New mail will show up here.'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Refresh'), findsOneWidget);
    });
  });
}

void _noop() {}
