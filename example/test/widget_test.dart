import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_plus/scaffold_plus.dart';
import 'package:scaffold_plus_example/main.dart';

void main() {
  testWidgets('example app lists ScaffoldPlus demo first', (tester) async {
    await tester.pumpWidget(const ScaffoldPlusExampleApp());

    expect(find.text('ScaffoldPlus'), findsOneWidget);
    expect(find.text('PlusAsyncView'), findsOneWidget);
  });

  testWidgets('ScaffoldPlus demo switches states from app bar controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: ScaffoldPlusExampleApp(),
      ),
    );

    await tester.ensureVisible(find.text('ScaffoldPlus'));
    await tester.tap(find.text('ScaffoldPlus'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ScaffoldPlus<List<String>>), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);

    await tester.tap(find.widgetWithText(ActionChip, 'Empty'));
    await tester.pump();
    expect(find.byType(PlusEmptyState), findsOneWidget);

    await tester.tap(find.widgetWithText(ActionChip, 'Error'));
    await tester.pump();
    expect(find.byType(PlusErrorState), findsOneWidget);

    final plainChip = find.widgetWithText(ActionChip, 'Plain body');
    await tester.ensureVisible(plainChip);
    await tester.tap(plainChip);
    await tester.pump();
    expect(find.textContaining('Plain scaffold body'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(ActionChip, 'Loading'));
    await tester.tap(find.widgetWithText(ActionChip, 'Loading'));
    await tester.pump();
    expect(find.byType(PlusSkeleton), findsWidgets);
  });
}
