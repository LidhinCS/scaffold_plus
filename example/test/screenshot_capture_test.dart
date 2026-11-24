import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus_example/main.dart';

/// Captures pub.dev screenshots from the Pulse Tasks example.
///
/// ```sh
/// cd example && flutter test test/screenshot_capture_test.dart
/// ```
///
/// Images are written to `../screenshots/`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const size = Size(390, 844);

  Future<void> pumpFrames(WidgetTester tester, {int frames = 8}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> capture(WidgetTester tester, String filename) async {
    final boundary = tester.renderObject(
      find.byKey(const ValueKey('screenshot.root')),
    );
    expect(boundary, isA<RenderRepaintBoundary>());
    final image = await (boundary as RenderRepaintBoundary).toImage(
      pixelRatio: 2,
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    expect(bytes, isNotNull);

    final dir = Directory('../screenshots');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    await File('${dir.path}/$filename')
        .writeAsBytes(bytes!.buffer.asUint8List());
  }

  testWidgets('capture pub.dev screenshots', (tester) async {
    final binding = tester.binding;
    await binding.setSurfaceSize(size);
    addTearDown(() => binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const RepaintBoundary(
        key: ValueKey('screenshot.root'),
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            padding: EdgeInsets.only(top: 47, bottom: 34),
            devicePixelRatio: 2,
            disableAnimations: true,
          ),
          child: PulseTasksApp(),
        ),
      ),
    );

    // Wait for fake repository latency (550ms + jitter).
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await pumpFrames(tester);

    expect(find.text('New task'), findsOneWidget);
    await capture(tester, '01_tasks_inbox.png');

    // Compose sheet
    await tester.tap(find.text('New task'));
    await pumpFrames(tester, frames: 12);
    expect(find.text('Create task'), findsOneWidget);
    await capture(tester, '02_compose_task.png');

    tester.state<NavigatorState>(find.byType(Navigator).first).pop();

    await pumpFrames(tester);

    // Settings
    await tester.tap(find.text('Settings').last);
    await pumpFrames(tester);
    expect(find.text('Developer gates'), findsOneWidget);
    await capture(tester, '03_settings_gates.png');

    // Force offline → Tasks
    await tester.tap(find.text('Force offline'));
    await pumpFrames(tester);
    await tester.tap(find.text('Tasks').last);
    await pumpFrames(tester, frames: 12);
    await capture(tester, '04_offline_banner.png');

    // Maintenance gate
    await tester.tap(find.text('Settings').last);
    await pumpFrames(tester);
    await tester.tap(find.text('Force offline'));
    await pumpFrames(tester);
    await tester.tap(find.text('Maintenance mode'));
    await pumpFrames(tester);
    await tester.tap(find.text('Tasks').last);
    await pumpFrames(tester, frames: 12);
    await capture(tester, '05_maintenance_gate.png');

    // Permission gate
    await tester.tap(find.text('Settings').last);
    await pumpFrames(tester);
    await tester.tap(find.text('Maintenance mode'));
    await pumpFrames(tester);
    await tester.tap(find.text('Deny notifications'));
    await pumpFrames(tester);
    await tester.tap(find.text('Tasks').last);
    await pumpFrames(tester, frames: 12);
    await capture(tester, '06_permission_gate.png');
  });
}
