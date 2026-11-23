import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusLoader', () {
    testWidgets('renders circular progress with defaults', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: PlusLoader())),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.strokeWidth, 3);
      expect(indicator.semanticsLabel, 'Loading');

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 32);
      expect(sizedBox.height, 32);
    });

    testWidgets('applies custom size, stroke, and color', (tester) async {
      const customColor = Color(0xFF00695C);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PlusLoader(
                size: 48,
                strokeWidth: 5,
                color: customColor,
                semanticsLabel: 'Fetching data',
              ),
            ),
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.strokeWidth, 5);
      expect(indicator.color, customColor);
      expect(indicator.semanticsLabel, 'Fetching data');

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 48);
      expect(sizedBox.height, 48);
    });

    testWidgets('uses theme primary by default', (tester) async {
      const primary = Color(0xFF1565C0);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
                .copyWith(primary: primary),
            useMaterial3: true,
          ),
          home: const Scaffold(body: Center(child: PlusLoader())),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.color, primary);
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
            home: const Scaffold(body: Center(child: PlusLoader())),
          ),
        );
      }

      await pumpWithBrightness(Brightness.light);
      expect(find.byType(PlusLoader), findsOneWidget);

      await pumpWithBrightness(Brightness.dark);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
