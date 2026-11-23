import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusSnackbar', () {
    Future<BuildContext> pumpHost(
      WidgetTester tester, {
      ThemeData? theme,
    }) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme ?? ThemeData(useMaterial3: true),
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

    testWidgets('show displays message', (tester) async {
      final context = await pumpHost(tester);

      PlusSnackbar.show(context, message: 'Hello snackbar');
      await tester.pumpAndSettle();

      expect(find.text('Hello snackbar'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.info_rounded), findsOneWidget);
    });

    testWidgets('can hide tone icon', (tester) async {
      final context = await pumpHost(tester);

      PlusSnackbar.success(context, message: 'No icon', showIcon: false);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });

    testWidgets('success uses primary container colors', (tester) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      );
      final context = await pumpHost(tester, theme: theme);

      PlusSnackbar.success(context, message: 'Saved');
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, theme.colorScheme.primaryContainer);
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('error uses error container colors', (tester) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      );
      final context = await pumpHost(tester, theme: theme);

      PlusSnackbar.error(context, message: 'Failed');
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, theme.colorScheme.errorContainer);
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('info uses inverse surface colors', (tester) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      );
      final context = await pumpHost(tester, theme: theme);

      PlusSnackbar.info(context, message: 'Heads up');
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, theme.colorScheme.inverseSurface);
    });

    testWidgets('action invokes callback', (tester) async {
      final context = await pumpHost(tester);
      var tapped = false;

      PlusSnackbar.show(
        context,
        message: 'Deleted',
        actionLabel: 'Undo',
        onAction: () => tapped = true,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('does not show action without onAction', (tester) async {
      final context = await pumpHost(tester);

      PlusSnackbar.show(context, message: 'No action', actionLabel: 'Undo');
      await tester.pumpAndSettle();

      expect(find.text('Undo'), findsNothing);
    });

    testWidgets('clearCurrent replaces previous snackbar', (tester) async {
      final context = await pumpHost(tester);

      PlusSnackbar.show(context, message: 'First');
      await tester.pump();
      PlusSnackbar.show(context, message: 'Second');
      await tester.pumpAndSettle();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('hide dismisses current snackbar', (tester) async {
      final context = await pumpHost(tester);

      PlusSnackbar.show(context, message: 'Temporary');
      await tester.pumpAndSettle();
      expect(find.text('Temporary'), findsOneWidget);

      PlusSnackbar.hide(context);
      await tester.pumpAndSettle();
      expect(find.text('Temporary'), findsNothing);
    });

    testWidgets('supports dark theme', (tester) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      );
      final context = await pumpHost(tester, theme: theme);

      PlusSnackbar.success(context, message: 'Dark ok');
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, theme.colorScheme.primaryContainer);
      expect(find.text('Dark ok'), findsOneWidget);
    });

    testWidgets('defaults to floating behavior', (tester) async {
      final context = await pumpHost(tester);

      PlusSnackbar.show(context, message: 'Floating');
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
    });
  });
}
