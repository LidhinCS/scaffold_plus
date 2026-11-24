import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusConnectivityBuilder', () {
    testWidgets('shows online builder when connected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlusConnectivityBuilder(
            isConnected: true,
            onlineBuilder: (_) => const Text('online'),
            offlineBuilder: (_) => const Text('offline'),
          ),
        ),
      );

      expect(find.text('online'), findsOneWidget);
      expect(find.text('offline'), findsNothing);
    });

    testWidgets('shows offline builder when disconnected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlusConnectivityBuilder(
            isConnected: false,
            onlineBuilder: (_) => const Text('online'),
            offlineBuilder: (_) => const PlusOfflineState(),
          ),
        ),
      );

      expect(find.byType(PlusOfflineState), findsOneWidget);
      expect(find.text('online'), findsNothing);
    });
  });
}
