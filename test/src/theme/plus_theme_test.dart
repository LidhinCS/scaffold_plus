import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusTheme', () {
    test('defaults match documented values', () {
      expect(PlusTheme.defaults.snackbarDuration, const Duration(seconds: 4));
      expect(PlusTheme.defaults.searchDebounceDuration, Duration.zero);
    });

    test('copyWith overrides selected fields', () {
      const theme = PlusTheme.defaults;
      final copied = theme.copyWith(
        snackbarDuration: const Duration(seconds: 2),
      );

      expect(copied.snackbarDuration, const Duration(seconds: 2));
      expect(copied.searchDebounceDuration, theme.searchDebounceDuration);
    });

    testWidgets('of returns defaults when extension is missing', (
      tester,
    ) async {
      late PlusTheme resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = PlusTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, PlusTheme.defaults);
    });

    testWidgets('of returns registered extension', (tester) async {
      const custom = PlusTheme(
        snackbarDuration: Duration(seconds: 1),
        searchDebounceDuration: Duration(milliseconds: 200),
      );
      late PlusTheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true, extensions: const [custom]),
          home: Builder(
            builder: (context) {
              resolved = PlusTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.snackbarDuration, const Duration(seconds: 1));
      expect(
        resolved.searchDebounceDuration,
        const Duration(milliseconds: 200),
      );
    });

    testWidgets('PlusSnackbar uses theme duration when omitted', (
      tester,
    ) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: const [
              PlusTheme(snackbarDuration: Duration(milliseconds: 50)),
            ],
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

      PlusSnackbar.info(context: captured, message: 'Timed');
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.duration, const Duration(milliseconds: 50));
      expect(find.text('Timed'), findsOneWidget);
    });

    testWidgets('PlusSearchField uses theme debounce when omitted', (
      tester,
    ) async {
      final values = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: const [
              PlusTheme(searchDebounceDuration: Duration(milliseconds: 200)),
            ],
          ),
          home: Scaffold(body: PlusSearchField(onChanged: values.add)),
        ),
      );

      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();
      expect(values, isEmpty);

      await tester.pump(const Duration(milliseconds: 200));
      expect(values, ['x']);
    });

    testWidgets('PlusEmptyState uses theme statePadding when omitted', (
      tester,
    ) async {
      const customPadding = EdgeInsets.all(40);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: const [PlusTheme(statePadding: customPadding)],
          ),
          home: const Scaffold(body: PlusEmptyState(title: 'Empty')),
        ),
      );

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(PlusEmptyState),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, customPadding);
    });
  });
}
