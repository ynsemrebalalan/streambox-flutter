import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/core/utils/ref_counter.dart';

void main() {
  group('RefCounter', () {
    test('acquire is true only on 0 -> 1', () {
      final c = RefCounter();
      expect(c.acquire(), isTrue);
      expect(c.acquire(), isFalse);
      expect(c.count, 2);
    });

    test('release is true only on 1 -> 0', () {
      final c = RefCounter();
      c.acquire();
      c.acquire();
      expect(c.release(), isFalse);
      expect(c.release(), isTrue);
      expect(c.count, 0);
    });

    test('release below zero is a no-op', () {
      final c = RefCounter();
      expect(c.release(), isFalse);
      expect(c.count, 0);
      expect(c.acquire(), isTrue);
    });

    test('overlapping player instances: new acquires before old releases', () {
      final c = RefCounter();
      final events = <String>[];
      void acq() {
        if (c.acquire()) events.add('on');
      }

      void rel() {
        if (c.release()) events.add('off');
      }

      acq(); // eski player
      acq(); // pushReplacement ile yeni player initState
      rel(); // eski player dispose (fade sonrasi)
      expect(events, ['on']);
      expect(c.isActive, isTrue);
      rel(); // yeni player kapandi
      expect(events, ['on', 'off']);
      expect(c.isActive, isFalse);
    });
  });

  group('PlayerSystemUi', () {
    test('enters immersive once and restores only after last release', () {
      final calls = <String>[];
      final ui = PlayerSystemUiController(
        onEnter: () => calls.add('enter'),
        onRestore: () => calls.add('restore'),
      );
      ui.acquire();
      ui.acquire();
      ui.release();
      expect(calls, ['enter']);
      ui.release();
      expect(calls, ['enter', 'restore']);
    });
  });
}
