import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget home) {
    return MaterialApp(
      builder: (context, child) => PlusFloatingWindowHost(child: child!),
      home: home,
    );
  }

  testWidgets('renders builder inline when not floating', (tester) async {
    final controller = PlusFloatingWindowController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: PlusFloatingWindow(
            controller: controller,
            title: 'Focus',
            builder: (context, {required floating}) {
              return Text(floating ? 'floating-body' : 'inline-body');
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('inline-body'), findsOneWidget);
    expect(find.text('floating-body'), findsNothing);
    expect(controller.active, isTrue);
    expect(controller.isFloating, isFalse);
  });

  testWidgets('enterFloating shows overlay chrome and floating builder', (
    tester,
  ) async {
    final controller = PlusFloatingWindowController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: PlusFloatingWindow(
            controller: controller,
            title: 'Focus',
            builder: (context, {required floating}) {
              return Text(floating ? 'floating-body' : 'inline-body');
            },
          ),
        ),
      ),
    );
    await tester.pump();

    controller.enterFloating();
    await tester.pump();

    expect(find.text('floating-body'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.textContaining('is floating'), findsOneWidget);
    expect(controller.isFloating, isTrue);
  });

  testWidgets('navigating away while active floats over the next route', (
    tester,
  ) async {
    final controller = PlusFloatingWindowController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) {
            return Scaffold(
              body: Column(
                children: [
                  PlusFloatingWindow(
                    controller: controller,
                    title: 'Focus',
                    builder: (context, {required floating}) {
                      return Text(floating ? 'floating-body' : 'inline-body');
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              const Scaffold(body: Text('second-route')),
                        ),
                      );
                    },
                    child: const Text('next'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();

    expect(find.text('second-route'), findsOneWidget);
    expect(find.text('floating-body'), findsOneWidget);
    expect(controller.isFloating, isTrue);
  });

  testWidgets('inactive window does not float on navigation', (tester) async {
    final controller = PlusFloatingWindowController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) {
            return Scaffold(
              body: Column(
                children: [
                  PlusFloatingWindow(
                    controller: controller,

                    builder: (context, {required floating}) {
                      return Text(floating ? 'floating-body' : 'inline-body');
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      controller.dismiss();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              const Scaffold(body: Text('second-route')),
                        ),
                      );
                    },
                    child: const Text('next'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    controller.dismiss();
    await tester.pump();

    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();

    expect(find.text('second-route'), findsOneWidget);
    expect(find.text('floating-body'), findsNothing);
    expect(controller.isFloating, isFalse);
  });

  testWidgets('dismiss removes the floating overlay', (tester) async {
    final controller = PlusFloatingWindowController();
    addTearDown(controller.dispose);
    var dismissed = 0;

    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: PlusFloatingWindow(
            controller: controller,
            title: 'Focus',
            onDismiss: () => dismissed++,
            builder: (context, {required floating}) {
              return Text(floating ? 'floating-body' : 'inline-body');
            },
          ),
        ),
      ),
    );
    await tester.pump();
    controller.enterFloating();
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pump();

    expect(find.text('floating-body'), findsNothing);
    expect(controller.active, isFalse);
    expect(controller.isFloating, isFalse);
    expect(dismissed, 1);
  });

  testWidgets('resize clamps to min size', (tester) async {
    final controller = PlusFloatingWindowController(
      initialSize: const Size(280, 200),
      minSize: const Size(200, 160),
      maxSize: const Size(400, 400),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: PlusFloatingWindow(
            controller: controller,
            title: 'Focus',
            builder: (context, {required floating}) {
              return const ColoredBox(color: Colors.teal);
            },
          ),
        ),
      ),
    );
    await tester.pump();
    controller.enterFloating();
    await tester.pump();

    controller.updateSize(const Size(40, 40));
    await tester.pump();

    expect(controller.size.width, 200);
    expect(controller.size.height, 160);
  });

  testWidgets('drag updates offset', (tester) async {
    final controller = PlusFloatingWindowController(
      initialOffset: const Offset(20, 80),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: PlusFloatingWindow(
            controller: controller,
            title: 'Focus',
            builder: (context, {required floating}) {
              return const ColoredBox(color: Colors.teal);
            },
          ),
        ),
      ),
    );
    await tester.pump();
    controller.enterFloating();
    await tester.pump();

    final title = find.text('Focus');
    expect(title, findsOneWidget);
    await tester.drag(title, const Offset(40, 30));
    await tester.pump();

    expect(controller.offset.dx, closeTo(60, 1));
    expect(controller.offset.dy, closeTo(110, 1));
  });
}
