import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/utils/http_client.dart';
import '../../l10n/generated/app_localizations.dart';
import '../models/playlist_model.dart';
import '../repositories/channel_repository.dart';
import '../repositories/playlist_repository.dart';
import 'isolate_batch_pump.dart';
import 'm3u_stream_loader.dart';
import 'stalker/stalker_client.dart';
import 'stalker/stalker_loader.dart';
import 'sync_cancel.dart';
import 'sync_shrink_gate.dart';
import 'xtream_service.dart';

/// Sync sonucu.
class PlaylistSyncResult {
  final int count;
  final bool notModified;
  /// Xtream tür bazlı kısmi hata (kanal yüklendi ama bir tür yüklenemedi).
  final String? partialError;
  const PlaylistSyncResult(
      {this.count = 0, this.notModified = false, this.partialError});
}

/// Kullanıcıya gösterilecek yerelleştirilmiş hata.
class PlaylistSyncException implements Exception {
  final String userMessage;
  final Object? cause;
  const PlaylistSyncException(this.userMessage, [this.cause]);
  @override
  String toString() => userMessage;
}

/// M3U / Xtream playlist senkronu (Android M3uLoader + XtreamLoader akışı):
/// isolate'ta akışlı indirme → batch UPSERT → başarıda eski nesil silinir.
/// Yarıda kalan / şüpheli indirme mevcut listeyi bozmaz.
class PlaylistSync {
  final ChannelRepository channels;
  final PlaylistRepository playlists;

  /// true dönerse (ör. sync sırasında playlist silindi) yazım durur:
  /// onBatch [SyncCancelledException] fırlatır, satır yazılmaz.
  final bool Function()? isCancelled;
  PlaylistSync(this.channels, this.playlists, {this.isCancelled});

  Future<void> _write(String playlistId, int gen,
      List<Map<String, Object?>> rows) async {
    if (isCancelled?.call() ?? false) throw const SyncCancelledException();
    await channels.upsertSyncBatch(playlistId, gen, rows);
  }

  Future<PlaylistSyncResult> run(
    PlaylistModel p,
    AppLocalizations l, {
    void Function(String message)? onProgress,
    void Function()? onFirstBatch,
    bool conditional = true,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _safe(() => playlists.markRefreshAttempt(p.id, now));
    try {
      final r = switch (p.type) {
        'xtream'  => await _xtream(p, l, onProgress, onFirstBatch),
        'stalker' => await _stalker(p, l, onProgress, onFirstBatch),
        _         => await _m3u(p, l, onProgress, onFirstBatch, conditional),
      };
      await _safe(() => playlists.markRefreshed(
          p.id, DateTime.now().millisecondsSinceEpoch));
      return r;
    } on PlaylistSyncException {
      rethrow;
    } on SyncCancelledException {
      rethrow;
    } catch (e) {
      throw PlaylistSyncException(errorMessage(e, l), e);
    }
  }

  Future<PlaylistSyncResult> _m3u(
    PlaylistModel p,
    AppLocalizations l,
    void Function(String)? onProgress,
    void Function()? onFirstBatch,
    bool conditional,
  ) async {
    final gen = ChannelRepository.newSyncGeneration();
    final previous = await channels.countByPlaylist(p.id);
    var written = 0;
    var firstFired = false;
    final outcome = await M3uStreamLoader.load(
      playlist: p,
      // Lokalde kanal yoksa (bulut sync / silinmiş) koşullu GET yapma: 304
      // gelirse liste boş kalırdı.
      conditional: conditional && previous > 0,
      onPhase: (phase, attempt) => onProgress?.call(switch (phase) {
        M3uLoadPhase.downloading => l.progressDownloadingList,
        M3uLoadPhase.retrying    => l.progressRetrying(attempt),
        M3uLoadPhase.parsing     => l.progressParsingList,
      }),
      onRetry: () => written = 0,
      onBatch: (rows) async {
        await _write(p.id, gen, rows);
        written += rows.length;
        onProgress?.call(l.progressChannelsSaved(written));
        if (!firstFired) {
          firstFired = true;
          onFirstBatch?.call();
        }
      },
    );
    if (outcome.notModified) {
      return PlaylistSyncResult(count: previous, notModified: true);
    }
    if (outcome.count == 0) {
      throw PlaylistSyncException(l.loadErrM3uNotFound);
    }
    // Küçülme kapıları — bayat nesil SİLİNMEZ:
    //  - aşırı küçülme (önceki ≥ 50, yeni < %10): Content-Length OLSA BİLE
    //    (süresi dolmuş hesaplar küçük ama geçerli M3U döner; sessiz
    //    otomatik yenileme tüm listeyi silerdi),
    //  - Content-Length yokken yarıdan kısa (Android v4.1.14 kısmi indirme).
    switch (m3uShrinkVerdict(
        previous: previous,
        current: outcome.count,
        sawContentLength: outcome.sawContentLength)) {
      case M3uShrinkVerdict.drasticShrink:
        if (kDebugMode) {
          debugPrint('[PlaylistSync] ${p.id}: drastic shrink '
              '${outcome.count}/$previous — old list kept');
        }
        throw PlaylistSyncException(
            l.loadErrDrasticShrink(outcome.count, previous));
      case M3uShrinkVerdict.incomplete:
        throw PlaylistSyncException(
            l.loadErrIncomplete(outcome.count, previous));
      case M3uShrinkVerdict.accept:
        break;
    }
    await channels.deleteStaleGeneration(p.id, gen);
    if (outcome.etag.isNotEmpty || outcome.lastModified.isNotEmpty) {
      await _safe(() => playlists.updateEtag(p.id,
          etag: outcome.etag, lastModified: outcome.lastModified));
    }
    // M3U başlığındaki EPG (url-tvg) — playlist'te EPG yoksa otomatik kaydet.
    final epg = outcome.epgUrl;
    if (epg != null && epg.isNotEmpty && p.epgUrl.trim().isEmpty) {
      await _safe(() => playlists.updateEpgUrl(p.id, epg));
    }
    return PlaylistSyncResult(count: outcome.count);
  }

  Future<PlaylistSyncResult> _xtream(
    PlaylistModel p,
    AppLocalizations l,
    void Function(String)? onProgress,
    void Function()? onFirstBatch,
  ) async {
    final gen = ChannelRepository.newSyncGeneration();
    // Tür bazlı küçülme kapısı için sync öncesi sayılar.
    var before = const <String, int>{};
    try {
      before = await channels.countSyncUnitsByType(p.id);
    } catch (e) {
      if (kDebugMode) debugPrint('[PlaylistSync] type counts failed: $e');
    }
    var written = 0;
    var firstFired = false;
    onProgress?.call(l.progressServerConnecting);
    final outcome = await XtreamService.loadAll(
      p,
      onType: (t) => onProgress?.call(switch (t) {
        'live'  => l.progressLoadingLive,
        'movie' => l.progressLoadingMovies,
        _       => l.progressLoadingSeries,
      }),
      onBatch: (rows) async {
        await _write(p.id, gen, rows);
        written += rows.length;
        onProgress?.call(l.progressChannelsSaved(written));
        if (!firstFired) {
          firstFired = true;
          onFirstBatch?.call();
        }
      },
    );
    if (outcome.count == 0) {
      final err = outcome.firstError;
      throw PlaylistSyncException(
          err == null ? l.loadErrServerEmpty : errorMessage(err, l), err);
    }
    // Hata veren TÜM türler + şüpheli küçülen türler korunur (favori /
    // geçmiş satırlarda tutulur; boş yanıt "başarı" sayılıp silinmesin).
    final decision = xtreamKeepDecision(
      before: before,
      loaded: outcome.countsByType,
      failedTypes: outcome.errorsByType.keys.toSet(),
    );
    await channels.deleteStaleGeneration(p.id, gen,
        keepTypes: decision.keepTypes);
    // Sınırlı arka plan bölüm prefetch'i — UI'yı bekletmez.
    unawaited(XtreamService.prefetchSeries(p, channels).catchError((_) => 0));
    String typeNames(Iterable<String> types) => types
        .map((t) => switch (t) {
              'live'  => l.playlistsContentLive,
              'movie' => l.playlistsContentMovie,
              _       => l.playlistsContentSeries,
            })
        .join(', ');
    final warnings = <String>[
      if (outcome.errorsByType.isNotEmpty)
        l.xtreamPartialLoad(typeNames(outcome.errorsByType.keys)),
      if (decision.shrunkTypes.isNotEmpty)
        l.syncShrinkKept(typeNames(decision.shrunkTypes)),
    ];
    return PlaylistSyncResult(
        count: outcome.count,
        partialError: warnings.isEmpty ? null : warnings.join('\n'));
  }

  /// Stalker portal (Android StalkerLoader): önce M3U export, olmazsa tam
  /// protokol. Protokole geçişte yeni nesil açılır → başarıda hem eski liste
  /// hem yarım kalmış export satırları silinir; hata / boş listede mevcut
  /// kanallar korunur.
  Future<PlaylistSyncResult> _stalker(
    PlaylistModel p,
    AppLocalizations l,
    void Function(String)? onProgress,
    void Function()? onFirstBatch,
  ) async {
    var gen = ChannelRepository.newSyncGeneration();
    final previous = await channels.countByPlaylist(p.id);
    var written = 0;
    var firstFired = false;
    final outcome = await StalkerLoader.load(
      p,
      previousCount: previous,
      lang: l.localeName.split('_').first,
      onPhase: (phase) => onProgress?.call(switch (phase) {
        StalkerPhase.tryingExport  => l.progressTryingPortalList,
        StalkerPhase.parsingExport => l.progressParsingList,
        StalkerPhase.connecting    => l.progressPortalConnecting,
        StalkerPhase.fetching      => l.progressLoadingLive,
      }),
      onProtocolStart: () {
        final next = ChannelRepository.newSyncGeneration();
        gen = next > gen ? next : gen + 1;
        written = 0;
      },
      onBatch: (rows) async {
        await _write(p.id, gen, rows);
        written += rows.length;
        onProgress?.call(l.progressChannelsSaved(written));
        if (!firstFired) {
          firstFired = true;
          onFirstBatch?.call();
        }
      },
    );
    if (outcome.count == 0) throw PlaylistSyncException(l.loadErrPortalList);
    await channels.deleteStaleGeneration(p.id, gen);
    final epg = outcome.epgUrl;
    if (epg != null && epg.isNotEmpty && p.epgUrl.trim().isEmpty) {
      await _safe(() => playlists.updateEpgUrl(p.id, epg));
    }
    return PlaylistSyncResult(count: outcome.count);
  }

  static Future<void> _safe(Future<void> Function() f) async {
    try {
      await f();
    } catch (e) {
      if (kDebugMode) debugPrint('[PlaylistSync] metadata write failed: $e');
    }
  }

  /// Hata → kullanıcı mesajı (ham metin asla gösterilmez — Android
  /// UserFacingErrors ilkesi).
  static String errorMessage(Object e, AppLocalizations l) {
    if (e is PlaylistSyncException) return e.userMessage;
    if (e is StalkerMacException) return l.playlistsValidationStalkerMac;
    if (e is StalkerConnectException) {
      if (!e.network) return l.loadErrPortalConnect;
      final cause = e.cause;
      return cause == null ? l.playlistsErrorConnection : errorMessage(cause, l);
    }
    if (e is XtreamAccountProblem) {
      return switch (e.kind) {
        XtreamAccountProblemKind.badLogin => l.xtreamBadLogin,
        XtreamAccountProblemKind.disabled => l.xtreamDisabled,
        XtreamAccountProblemKind.expired => e.expiredOn == null
            ? l.xtreamExpired
            : l.xtreamExpiredOn(e.expiredOn!),
      };
    }
    if (e is HttpStatusException) {
      return e.isAuthError ? l.xtreamBadLogin : e.userMessage;
    }
    final (kind, status) = switch (e) {
      M3uLoadException(:final kind, :final statusCode) => (kind, statusCode),
      IsolateTaskException(:final kind, :final statusCode) => (kind, statusCode),
      _ => (classifyIoError(e), null),
    };
    switch (kind) {
      case 'http':
        final code = status ?? 0;
        if (code == 401 || code == 403) return l.xtreamBadLogin;
        return HttpStatusException(code, '').userMessage;
      case 'tls':
        return l.playlistsErrorTlsHandshake;
      case 'timeout':
        return l.playlistsErrorTimeout;
      case 'network':
        return l.playlistsErrorConnection;
      case 'format':
        return l.loadErrServerEmpty;
    }
    final msg = '$e'.toLowerCase();
    if (msg.contains('handshake') || msg.contains('certificate')) {
      return l.playlistsErrorTlsHandshake;
    }
    if (msg.contains('timeout')) return l.playlistsErrorTimeout;
    if (msg.contains('socket') ||
        msg.contains('failed host lookup') ||
        msg.contains('connection')) {
      return l.playlistsErrorConnection;
    }
    return l.playlistsErrorUpdateGeneric('$e');
  }
}
