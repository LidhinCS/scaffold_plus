import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';
import 'package:ui_plus_example/main.dart';

void main() {
  testWidgets('Pulse Tasks shell shows Tasks destination', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: PulseTasksApp(useBuiltInInternetCheck: false),
      ),
    );
    await tester.pump();
    // Fake repository latency + jitter.
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(PlusAdaptiveScaffold), findsOneWidget);
    expect(find.text('New task'), findsOneWidget);
    expect(find.textContaining('Ship ui_plus'), findsOneWidget);
  });

  testWidgets('Settings tab exposes developer gates', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: PulseTasksApp(useBuiltInInternetCheck: false),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('Developer gates'), findsOneWidget);
    expect(find.text('Maintenance mode'), findsOneWidget);
    expect(find.text('Force offline'), findsOneWidget);
  });

  testWidgets('Components tab lists gallery entries', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: PulseTasksApp(useBuiltInInternetCheck: false),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Components').last);
    await tester.pumpAndSettle();

    expect(find.text('Components'), findsWidgets);
    expect(find.text('PlusEmptyState'), findsOneWidget);
    expect(
      find.textContaining('Consistent empty UI'),
      findsOneWidget,
    );

    await tester.tap(find.text('PlusEmptyState'));
    await tester.pumpAndSettle();

    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.text('Create task'), findsOneWidget);
  });
}
