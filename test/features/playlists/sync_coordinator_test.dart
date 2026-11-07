import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/playlists/sync_coordinator.dart';

void main() {
  group('SyncCoordinator (H5)', () {
    test('second begin while running is rejected', () {
      final c = SyncCoordinator();
      expect(c.begin('a'), isTrue);
      expect(c.begin('a'), isFalse);
      expect(c.begin('b'), isTrue);
    });

    test('edit during sync queues exactly one follow-up', () {
      final c = SyncCoordinator();
      c.begin('a');
      expect(c.requestResync('a'), isTrue); // queued
      expect(c.requestResync('a'), isTrue);
      final end = c.end('a');
      expect(end.resync, isTrue);
      expect(end.cancelled, isFalse);
      expect(c.isRunning('a'), isFalse);
      // tekrar bitirince ikinci bir resync yok
      c.begin('a');
      expect(c.end('a').resync, isFalse);
    });

    test('requestResync when idle is not queued', () {
      final c = SyncCoordinator();
      expect(c.requestResync('a'), isFalse);
      c.begin('a');
      expect(c.end('a').resync, isFalse);
    });

    test('delete during sync cancels writes and requests cleanup', () {
      final c = SyncCoordinator();
      c.begin('a');
      c.requestResync('a');
      expect(c.isCancelled('a'), isFalse);
      expect(c.cancel('a'), isTrue);
      expect(c.isCancelled('a'), isTrue);
      final end = c.end('a');
      expect(end.cancelled, isTrue);
      expect(end.resync, isFalse, reason: 'deleted playlist must not resync');
      expect(c.isCancelled('a'), isFalse);
    });

    test('cancel when idle reports no running sync', () {
      final c = SyncCoordinator();
      expect(c.cancel('a'), isFalse);
      expect(c.isCancelled('a'), isFalse);
    });
  });
}
