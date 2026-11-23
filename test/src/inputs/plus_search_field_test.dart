import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusSearchField', () {
    Future<void> pumpField(
      WidgetTester tester, {
      PlusSearchField? field,
      ThemeData? theme,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme ?? ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: field ?? const PlusSearchField(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders hint text', (tester) async {
      await pumpField(
        tester,
        field: const PlusSearchField(hintText: 'Search people'),
      );

      expect(find.text('Search people'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('onChanged fires immediately by default', (tester) async {
      final values = <String>[];
      await pumpField(tester, field: PlusSearchField(onChanged: values.add));

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();

      expect(values, isNotEmpty);
      expect(values.last, 'abc');
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('debounces onChanged when duration is set', (tester) async {
      final values = <String>[];
      await pumpField(
        tester,
        field: PlusSearchField(
          debounceDuration: const Duration(milliseconds: 300),
          onChanged: values.add,
        ),
      );

      await tester.enterText(find.byType(TextField), 'hi');
      await tester.pump();
      expect(values, isEmpty);

      await tester.pump(const Duration(milliseconds: 299));
      expect(values, isEmpty);

      await tester.pump(const Duration(milliseconds: 1));
      expect(values, ['hi']);
    });

    testWidgets('clear button clears text and notifies', (tester) async {
      final values = <String>[];
      var cleared = false;
      final controller = TextEditingController(text: 'draft');

      await pumpField(
        tester,
        field: PlusSearchField(
          controller: controller,
          onChanged: values.add,
          onClear: () => cleared = true,
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(values, ['']);
      expect(cleared, isTrue);
      expect(find.byIcon(Icons.close), findsNothing);

      controller.dispose();
    });

    testWidgets('onSubmitted is invoked', (tester) async {
      String? submitted;
      await pumpField(
        tester,
        field: PlusSearchField(onSubmitted: (value) => submitted = value),
      );

      await tester.enterText(find.byType(TextField), 'query');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submitted, 'query');
    });

    testWidgets('supports dark theme', (tester) async {
      await pumpField(
        tester,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
        ),
        field: const PlusSearchField(hintText: 'Dark search'),
      );

      expect(find.text('Dark search'), findsOneWidget);
    });

    testWidgets('hides prefix icon when prefixIcon is null', (tester) async {
      await pumpField(tester, field: const PlusSearchField(prefixIcon: null));

      expect(find.byIcon(Icons.search), findsNothing);
    });

    testWidgets('disabled field does not accept input', (tester) async {
      await pumpField(
        tester,
        field: const PlusSearchField(enabled: false, hintText: 'Disabled'),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });
  });
}
