import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  tearDown(PlusErrorBoundary.uninstall);

  testWidgets('install replaces ErrorWidget with PlusErrorState', (
    tester,
  ) async {
    final oldOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = oldOnError);
    FlutterError.onError = (details) {};

    PlusErrorBoundary.install();

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: _ThrowingWidget())),
    );
    await tester.pump();

    expect(find.byType(PlusErrorState), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.textContaining('boom'), findsOneWidget);
    expect(find.byType(ErrorWidget), findsNothing);
  });

  testWidgets('custom builder is used when provided', (tester) async {
    final oldOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = oldOnError);
    FlutterError.onError = (details) {};

    PlusErrorBoundary.install(
      builder: (context, details) {
        return const Text('custom-boundary');
      },
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: _ThrowingWidget())),
    );
    await tester.pump();

    expect(find.text('custom-boundary'), findsOneWidget);
    expect(find.byType(PlusErrorState), findsNothing);
  });

  testWidgets('uninstall restores prior ErrorWidget.builder', (tester) async {
    final oldOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = oldOnError);
    FlutterError.onError = (details) {};

    final before = ErrorWidget.builder;
    PlusErrorBoundary.install();
    expect(PlusErrorBoundary.isInstalled, isTrue);
    expect(ErrorWidget.builder, isNot(before));

    PlusErrorBoundary.uninstall();
    expect(PlusErrorBoundary.isInstalled, isFalse);
    expect(ErrorWidget.builder, before);
  });

  testWidgets('PlusErrorBoundaryView hides details when requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlusErrorBoundaryView(
            details: FlutterErrorDetails(exception: Exception('secret')),
            showDebugDetails: false,
            releaseMessage: 'Friendly copy',
          ),
        ),
      ),
    );

    expect(find.text('Friendly copy'), findsOneWidget);
    expect(find.textContaining('secret'), findsNothing);
  });
}

class _ThrowingWidget extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    throw Exception('boom');
  }
}
