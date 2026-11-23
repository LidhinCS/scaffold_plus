import 'package:flutter_test/flutter_test.dart';
import 'package:ui_plus/ui_plus.dart';

void main() {
  group('PlusInternetChecker', () {
    test('checkNow emits status changes', () async {
      var online = false;
      final checker = PlusInternetChecker(
        config: const PlusInternetCheckerConfig(checkOnStart: false),
        probe: ({required endpoints, required timeout}) async => online,
      );

      final events = <bool>[];
      final sub = checker.onStatusChange.listen(events.add);

      online = true;
      expect(await checker.checkNow(), isTrue);
      online = false;
      expect(await checker.checkNow(), isFalse);
      // Unchanged value should not re-emit.
      expect(await checker.checkNow(), isFalse);

      await sub.cancel();
      checker.dispose();

      expect(events, [true, false]);
    });

    test('start schedules periodic checks', () async {
      var calls = 0;
      final checker = PlusInternetChecker(
        config: const PlusInternetCheckerConfig(
          interval: Duration(milliseconds: 30),
        ),
        probe: ({required endpoints, required timeout}) async {
          calls++;
          return true;
        },
      )..start();

      await Future<void>.delayed(const Duration(milliseconds: 100));
      checker
        ..stop()
        ..dispose();

      expect(calls, greaterThanOrEqualTo(2));
    });

    test('custom config equality', () {
      const a = PlusInternetCheckerConfig(interval: Duration(seconds: 2));
      const b = PlusInternetCheckerConfig(interval: Duration(seconds: 2));
      const c = PlusInternetCheckerConfig(interval: Duration(seconds: 3));

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
