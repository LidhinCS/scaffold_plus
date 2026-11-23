import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusConnectivityBanner', () {
    testWidgets('renders offline defaults', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PlusConnectivityBanner(isConnected: false)),
        ),
      );

      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.text('Check your network settings'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('renders online defaults', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PlusConnectivityBanner(isConnected: true)),
        ),
      );

      expect(find.text('Connection restored'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
    });

    testWidgets('supports custom messages and dismiss', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlusConnectivityBanner(
              isConnected: false,
              config: const PlusConnectivityConfig(
                offlineMessage: 'Offline now',
                dismissible: true,
              ),
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.text('Offline now'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });

    testWidgets('supports light and dark themes', (tester) async {
      Future<void> pump(Brightness brightness) {
        return tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: brightness,
              ),
              useMaterial3: true,
            ),
            home: const Scaffold(
              body: PlusConnectivityBanner(isConnected: false),
            ),
          ),
        );
      }

      await pump(Brightness.light);
      expect(find.text('No internet connection'), findsOneWidget);
      await pump(Brightness.dark);
      expect(find.text('No internet connection'), findsOneWidget);
    });
  });
}
