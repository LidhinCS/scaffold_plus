import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusSkeleton', () {
    testWidgets('renders with default dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 200, child: PlusSkeleton(animate: false)),
          ),
        ),
      );

      final box = tester.renderObject<RenderBox>(find.byType(PlusSkeleton));
      expect(box.size.height, 16);
      expect(box.size.width, 200);
    });

    testWidgets('applies custom size and colors', (tester) async {
      const base = Color(0xFFCCCCCC);
      const highlight = Color(0xFFEEEEEE);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlusSkeleton(
              width: 120,
              height: 24,
              animate: false,
              baseColor: base,
              highlightColor: highlight,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ),
      );

      final box = tester.renderObject<RenderBox>(find.byType(PlusSkeleton));
      expect(box.size, const Size(120, 24));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, base);
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('animates when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlusSkeleton(width: 100))),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('stays static when animate is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PlusSkeleton(width: 100, animate: false)),
        ),
      );

      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('respects reduced motion preference', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: PlusSkeleton(width: 100)),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsNothing);
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
            home: const Scaffold(body: PlusSkeleton(width: 80, animate: false)),
          ),
        );
      }

      await pumpWithBrightness(Brightness.light);
      expect(find.byType(PlusSkeleton), findsOneWidget);

      await pumpWithBrightness(Brightness.dark);
      expect(find.byType(PlusSkeleton), findsOneWidget);
    });

    testWidgets('composes in tight layouts', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 480));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  PlusSkeleton(height: 12, animate: false),
                  SizedBox(height: 8),
                  PlusSkeleton(width: 160, height: 12, animate: false),
                  SizedBox(height: 8),
                  PlusSkeleton(height: 48, animate: false),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(PlusSkeleton), findsNWidgets(3));
    });
  });
}
