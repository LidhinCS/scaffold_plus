import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  tearDown(PlusToastHost.debugReset);

  group('PlusToastHost', () {
    testWidgets('enables context-free snackbars via builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          builder: (context, child) => PlusToastHost(child: child!),
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );

      expect(PlusToastHost.isAvailable, isTrue);

      PlusSnackbar.success(message: 'Saved globally');
      await tester.pumpAndSettle();

      expect(find.text('Saved globally'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('messengerKey alone enables context-free snackbars', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: PlusToastHost.messengerKey,
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );

      PlusSnackbar.error(message: 'Failed globally');
      await tester.pumpAndSettle();

      expect(find.text('Failed globally'), findsOneWidget);
    });

    testWidgets('hide and clear work without context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => PlusToastHost(child: child!),
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );

      PlusSnackbar.info(message: 'Temporary');
      await tester.pumpAndSettle();
      expect(find.text('Temporary'), findsOneWidget);

      PlusSnackbar.hide();
      await tester.pumpAndSettle();
      expect(find.text('Temporary'), findsNothing);

      PlusSnackbar.show(message: 'One');
      await tester.pump();
      PlusSnackbar.clear();
      await tester.pumpAndSettle();
      expect(find.text('One'), findsNothing);
    });

    testWidgets('throws without host or context', (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());

      expect(
        () => PlusSnackbar.success(message: 'Nope'),
        throwsA(isA<FlutterError>()),
      );
    });

    testWidgets('context overload still works with host present', (
      tester,
    ) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => PlusToastHost(child: child!),
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

      PlusSnackbar.info(context: captured, message: 'With context');
      await tester.pumpAndSettle();

      expect(find.text('With context'), findsOneWidget);
    });
  });
}
