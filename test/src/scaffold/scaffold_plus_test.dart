import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('ScaffoldPlus', () {
    testWidgets('normal mode renders body like Scaffold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<void>(
            appBar: AppBar(title: const Text('Home')),
            body: const Text('plain-body'),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('plain-body'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('exposes ScaffoldState to descendants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<void>(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: const Text('open'),
                );
              },
            ),
            drawer: const Drawer(child: Text('drawer')),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('drawer'), findsOneWidget);
    });

    testWidgets('loading state shows PlusLoader by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScaffoldPlus<String>(
            state: PlusLoading(),
            bodyBuilder: _bodyBuilder,
            body: Text('ignored-body'),
          ),
        ),
      ); // bodyBuilder tear-off is const-safe

      expect(find.byType(PlusLoader), findsOneWidget);
      expect(find.text('ignored-body'), findsNothing);
    });

    testWidgets('success state uses bodyBuilder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScaffoldPlus<String>(
            state: PlusSuccess('hello'),
            bodyBuilder: _bodyBuilder,
          ),
        ),
      );

      expect(find.text('body:hello'), findsOneWidget);
    });

    testWidgets('empty state uses isEmpty predicate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<List<String>>(
            state: const PlusSuccess([]),
            isEmpty: (items) => items.isEmpty,
            bodyBuilder: (context, items) => Text('count:${items.length}'),
          ),
        ),
      );

      expect(find.byType(PlusEmptyState), findsOneWidget);
      expect(find.textContaining('count:'), findsNothing);
    });

    testWidgets('failure state shows retry and invokes onRetry', (
      tester,
    ) async {
      var retries = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<String>(
            state: const PlusFailure('boom'),
            bodyBuilder: _bodyBuilder,
            onRetry: () => retries++,
          ),
        ),
      );

      expect(find.byType(PlusErrorState), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    });

    testWidgets('custom builders override defaults', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<String>(
            state: const PlusLoading(),
            bodyBuilder: _bodyBuilder,
            loadingBuilder: (_) => const Text('custom-loading'),
          ),
        ),
      );
      expect(find.text('custom-loading'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<String>(
            state: const PlusFailure('x'),
            bodyBuilder: _bodyBuilder,
            errorBuilder: (context, error, stackTrace) =>
                Text('custom-error:$error'),
          ),
        ),
      );
      expect(find.text('custom-error:x'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<String>(
            state: const PlusSuccess(''),
            isEmpty: (value) => value.isEmpty,
            bodyBuilder: _bodyBuilder,
            emptyBuilder: (_) => const Text('custom-empty'),
          ),
        ),
      );
      expect(find.text('custom-empty'), findsOneWidget);
    });

    testWidgets('useSkeleton shows default PlusSkeleton layout', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScaffoldPlus<String>(
            state: PlusLoading(),
            bodyBuilder: _bodyBuilder,
            useSkeleton: true,
          ),
        ),
      );

      expect(find.byType(PlusSkeleton), findsWidgets);
      expect(find.byType(PlusLoader), findsNothing);
    });

    testWidgets('skeletonBuilder overrides default skeleton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<String>(
            state: const PlusLoading(),
            bodyBuilder: _bodyBuilder,
            useSkeleton: true,
            skeletonBuilder: (_) => const Text('custom-skeleton'),
          ),
        ),
      );

      expect(find.text('custom-skeleton'), findsOneWidget);
      expect(find.byType(PlusSkeleton), findsNothing);
    });

    testWidgets('async state ignores body when both are supplied', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<String>(
            appBar: AppBar(title: const Text('Async')),
            body: const Text('should-not-show'),
            state: const PlusSuccess('data'),
            bodyBuilder: _bodyBuilder,
          ),
        ),
      );

      expect(find.text('should-not-show'), findsNothing);
      expect(find.text('body:data'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('connectivity banner overlays without breaking async body', (
      tester,
    ) async {
      final controller = StreamController<bool>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<String>(
            connectivityBanner: true,
            isConnected: true,
            connectivityStream: controller.stream,
            connectivityBannerConfig: const PlusConnectivityConfig(
              debounceDuration: Duration.zero,
              animationDuration: Duration.zero,
            ),
            state: const PlusSuccess('hello'),
            bodyBuilder: _bodyBuilder,
          ),
        ),
      );

      expect(find.text('body:hello'), findsOneWidget);
      expect(find.text('Connection restored'), findsNothing);

      controller.add(false);
      await tester.pump();
      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.text('body:hello'), findsOneWidget);
    });

    testWidgets('maintenanceMode replaces body and hides FAB', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<String>(
            maintenanceMode: true,
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            state: const PlusSuccess('hello'),
            bodyBuilder: _bodyBuilder,
          ),
        ),
      );

      expect(find.text("We'll be back soon"), findsOneWidget);
      expect(find.text('body:hello'), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('maintenanceBuilder overrides default maintenance UI', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<void>(
            maintenanceMode: true,
            maintenanceBuilder: (_) => const Text('Custom maintenance'),
            body: const Text('Normal body'),
          ),
        ),
      );

      expect(find.text('Custom maintenance'), findsOneWidget);
      expect(find.text('Normal body'), findsNothing);
    });

    testWidgets('permissionDenied replaces body and hides FAB', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<String>(
            permissionDenied: true,
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            state: const PlusSuccess('hello'),
            bodyBuilder: _bodyBuilder,
          ),
        ),
      );

      expect(find.text('Permission required'), findsOneWidget);
      expect(find.text('body:hello'), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('maintenanceMode takes priority over permissionDenied', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScaffoldPlus<void>(
            maintenanceMode: true,
            permissionDenied: true,
            body: Text('Normal body'),
          ),
        ),
      );

      expect(find.text("We'll be back soon"), findsOneWidget);
      expect(find.text('Permission required'), findsNothing);
    });

    testWidgets('permissionBuilder overrides default permission UI', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<void>(
            permissionDenied: true,
            permissionBuilder: (_) => const Text('Custom permission'),
            body: const Text('Normal body'),
          ),
        ),
      );

      expect(find.text('Custom permission'), findsOneWidget);
      expect(find.text('Normal body'), findsNothing);
    });

    testWidgets('sessionExpired replaces body and hides FAB', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<String>(
            sessionExpired: true,
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            state: const PlusSuccess('hello'),
            bodyBuilder: _bodyBuilder,
          ),
        ),
      );

      expect(find.text('Session expired'), findsOneWidget);
      expect(find.text('body:hello'), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('sessionExpired takes priority over permissionDenied', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScaffoldPlus<void>(
            sessionExpired: true,
            permissionDenied: true,
            body: Text('Normal body'),
          ),
        ),
      );

      expect(find.text('Session expired'), findsOneWidget);
      expect(find.text('Permission required'), findsNothing);
    });

    testWidgets('maintenanceMode takes priority over sessionExpired', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScaffoldPlus<void>(
            maintenanceMode: true,
            sessionExpired: true,
            body: Text('Normal body'),
          ),
        ),
      );

      expect(find.text("We'll be back soon"), findsOneWidget);
      expect(find.text('Session expired'), findsNothing);
    });

    testWidgets('onRefresh wraps success body in PlusRefreshIndicator', (
      tester,
    ) async {
      var refreshed = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldPlus<String>(
            state: const PlusSuccess('hello'),
            onRefresh: () async {
              refreshed++;
            },
            bodyBuilder: (context, data) =>
                ListView(children: [Text('body:$data')]),
          ),
        ),
      );

      expect(find.byType(PlusRefreshIndicator), findsOneWidget);
      expect(find.text('body:hello'), findsOneWidget);

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(refreshed, 1);
    });
  });
}

Widget _bodyBuilder(BuildContext context, String data) {
  return Text('body:$data');
}
