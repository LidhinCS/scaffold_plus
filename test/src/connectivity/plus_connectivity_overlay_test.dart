import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusConnectivityOverlay', () {
    testWidgets('initial connected does not show restored banner', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlusConnectivityOverlay(
            isConnected: true,
            config: PlusConnectivityConfig(debounceDuration: Duration.zero),
            child: Scaffold(body: Text('body')),
          ),
        ),
      );

      expect(find.text('Connection restored'), findsNothing);
      expect(find.text('body'), findsOneWidget);
    });

    testWidgets('initial disconnected shows offline banner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlusConnectivityOverlay(
            isConnected: false,
            config: PlusConnectivityConfig(debounceDuration: Duration.zero),
            child: Scaffold(body: Text('body')),
          ),
        ),
      );

      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('shows offline after disconnect and restored on reconnect', (
      tester,
    ) async {
      final controller = StreamController<bool>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: PlusConnectivityOverlay(
            isConnected: true,
            connectivityStream: controller.stream,
            config: const PlusConnectivityConfig(
              debounceDuration: Duration.zero,
              animationDuration: Duration.zero,
            ),
            child: const Scaffold(body: Text('body')),
          ),
        ),
      );

      controller.add(false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text('No internet connection'), findsOneWidget);

      controller.add(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text('Connection restored'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text('Connection restored'), findsNothing);
    });

    testWidgets('autoHideOnline false keeps restored banner', (tester) async {
      final controller = StreamController<bool>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: PlusConnectivityOverlay(
            isConnected: false,
            connectivityStream: controller.stream,
            config: const PlusConnectivityConfig(
              debounceDuration: Duration.zero,
              autoHideOnline: false,
              animationDuration: Duration.zero,
            ),
            child: const Scaffold(body: Text('body')),
          ),
        ),
      );

      controller.add(true);
      await tester.pump();
      expect(find.text('Connection restored'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Connection restored'), findsOneWidget);
    });

    testWidgets('custom banner builder is used', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlusConnectivityOverlay(
            isConnected: false,
            config: const PlusConnectivityConfig(
              debounceDuration: Duration.zero,
              animationDuration: Duration.zero,
            ),
            bannerBuilder: (context, {required isConnected}) {
              return Text(isConnected ? 'custom-online' : 'custom-offline');
            },
            child: const Scaffold(body: Text('body')),
          ),
        ),
      );

      expect(find.text('custom-offline'), findsOneWidget);
    });

    testWidgets('supports bottom positioning', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlusConnectivityOverlay(
            isConnected: false,
            config: PlusConnectivityConfig(
              debounceDuration: Duration.zero,
              animationDuration: Duration.zero,
              position: PlusConnectivityBannerPosition.bottom,
            ),
            child: Scaffold(body: Text('body')),
          ),
        ),
      );

      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('dismissible hides the banner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlusConnectivityOverlay(
            isConnected: false,
            config: PlusConnectivityConfig(
              debounceDuration: Duration.zero,
              animationDuration: Duration.zero,
              dismissible: true,
            ),
            child: Scaffold(body: Text('body')),
          ),
        ),
      );

      expect(find.text('No internet connection'), findsOneWidget);
      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('No internet connection'), findsNothing);
    });

    testWidgets('debounces rapid connectivity changes', (tester) async {
      final controller = StreamController<bool>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: PlusConnectivityOverlay(
            isConnected: true,
            connectivityStream: controller.stream,
            config: const PlusConnectivityConfig(
              animationDuration: Duration.zero,
            ),
            child: const Scaffold(body: Text('body')),
          ),
        ),
      );

      controller
        ..add(false)
        ..add(true)
        ..add(false);
      await tester.pump();
      expect(find.text('No internet connection'), findsNothing);

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('handles stream errors without crashing', (tester) async {
      final controller = StreamController<bool>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: PlusConnectivityOverlay(
            isConnected: true,
            connectivityStream: controller.stream,
            config: const PlusConnectivityConfig(
              debounceDuration: Duration.zero,
              animationDuration: Duration.zero,
            ),
            child: const Scaffold(body: Text('body')),
          ),
        ),
      );

      controller.addError(Exception('network probe failed'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('body'), findsOneWidget);

      controller.add(false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('overlay layout does not resize child body', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlusConnectivityOverlay(
            isConnected: false,
            config: PlusConnectivityConfig(
              debounceDuration: Duration.zero,
              animationDuration: Duration.zero,
              layout: PlusConnectivityBannerLayout.overlay,
            ),
            child: Scaffold(body: SizedBox.expand(child: Text('body'))),
          ),
        ),
      );

      final bodySize = tester.getSize(find.text('body'));
      expect(bodySize.width, greaterThan(0));
      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('inline layout sits above child and keeps child visible', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('title')),
            body: const PlusConnectivityOverlay(
              isConnected: false,
              config: PlusConnectivityConfig(
                debounceDuration: Duration.zero,
                animationDuration: Duration.zero,
              ),
              child: Text('body'),
            ),
          ),
        ),
      );

      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      expect(find.text('title'), findsOneWidget);

      final bannerY = tester.getTopLeft(find.text('No internet connection')).dy;
      final bodyY = tester.getTopLeft(find.text('body')).dy;
      final titleY = tester.getTopLeft(find.text('title')).dy;
      expect(bannerY, greaterThan(titleY));
      expect(bodyY, greaterThan(bannerY));
    });
  });
}
