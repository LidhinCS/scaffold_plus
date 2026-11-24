import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus_example/main.dart';

/// Captures pub.dev screenshots from the Pulse Tasks example.
///
/// Opt-in — `toImage` is flaky under `flutter test` on some hosts:
///
/// ```sh
/// cd example && flutter test test/screenshot_capture_test.dart --name capture
/// ```
///
/// Prefer `tool/capture_screenshots.sh` / `lib/screenshot_gallery.dart` for
/// reliable device captures. Images are written to `../screenshots/`.
void main() {
  const size = Size(390, 844);

  Future<void> pumpFrames(WidgetTester tester, {int frames = 8}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> capture(WidgetTester tester, String filename) async {
    await tester.pump();
    final boundary = tester.renderObject(
      find.byKey(const ValueKey('screenshot.root')),
    ) as RenderRepaintBoundary;

    // `toImage` must run outside the test frame lock or it can hang.
    final bytes = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return data;
    });
    expect(bytes, isNotNull);
    expect(bytes!.lengthInBytes, greaterThan(1000));

    final dir = Directory('../screenshots');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final out = File('${dir.path}/$filename');
    final tmp = File('${dir.path}/.$filename.tmp');
    await tmp.writeAsBytes(bytes.buffer.asUint8List());
    await tmp.rename(out.path);
  }

  testWidgets('capture pub.dev screenshots', (tester) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const RepaintBoundary(
        key: ValueKey('screenshot.root'),
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            padding: EdgeInsets.only(top: 47, bottom: 34),
            disableAnimations: true,
          ),
          child: PulseTasksApp(useBuiltInInternetCheck: false),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await pumpFrames(tester);

    expect(find.text('New task'), findsOneWidget);
    await capture(tester, '01_tasks_inbox.png');

    await tester.tap(find.text('New task'));
    await pumpFrames(tester, frames: 12);
    expect(find.text('Create task'), findsOneWidget);
    await capture(tester, '02_compose_task.png');

    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await pumpFrames(tester);

    await tester.tap(find.text('Settings').last);
    await pumpFrames(tester);
    expect(find.text('Developer gates'), findsOneWidget);
    await capture(tester, '03_settings_gates.png');

    await tester.tap(find.text('Force offline'));
    await pumpFrames(tester);
    await tester.tap(find.text('Tasks').last);
    await pumpFrames(tester, frames: 12);
    await capture(tester, '04_offline_banner.png');

    await tester.tap(find.text('Settings').last);
    await pumpFrames(tester);
    await tester.tap(find.text('Force offline'));
    await pumpFrames(tester);
    await tester.tap(find.text('Maintenance mode'));
    await pumpFrames(tester);
    await tester.tap(find.text('Tasks').last);
    await pumpFrames(tester, frames: 12);
    await capture(tester, '05_maintenance_gate.png');

    await tester.tap(find.text('Settings').last);
    await pumpFrames(tester);
    await tester.tap(find.text('Maintenance mode'));
    await pumpFrames(tester);
    await tester.tap(find.text('Deny notifications'));
    await pumpFrames(tester);
    await tester.tap(find.text('Tasks').last);
    await pumpFrames(tester, frames: 12);
    await capture(tester, '06_permission_gate.png');
  }, skip: true);
}
