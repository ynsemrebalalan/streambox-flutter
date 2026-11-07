import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import '../../../core/utils/http_client.dart';
import 'stalker_protocol.dart';

/// Handshake sonrasi oturum (API ucu + token).
class StalkerSession {
  final StalkerEndpoint endpoint;
  final String token;
  const StalkerSession(this.endpoint, this.token);
}

/// Portala baglanilamadi. [network] true → hicbir uca ulasilamadi (ag /
/// zaman asimi); false → portal cevap verdi ama token vermedi.
class StalkerConnectException implements Exception {
  final bool network;
  final Object? cause;
  const StalkerConnectException({required this.network, this.cause});
  @override
  String toString() => 'StalkerConnectException(network: $network, $cause)';
}

/// Portal HTTP hatasi (200 disi).
class StalkerHttpException implements Exception {
  final int statusCode;
  const StalkerHttpException(this.statusCode);
  @override
  String toString() => 'StalkerHttpException($statusCode)';
}

/// Stalker Middleware / MAG portal HTTP istemcisi (Android StalkerApiClient
/// paritesi + portal yolu varyantlari, get_profile, get_genres,
/// get_ordered_list yedegi).
class StalkerClient {
  final String mac;
  final String lang;
  final List<StalkerEndpoint> endpoints;

  StalkerClient({
    required String portalUrl,
    required this.mac,
    this.lang = 'en',
  }) : endpoints = StalkerUrls.endpoints(portalUrl);

  static const _timeout = Duration(seconds: 20);
  static const _bigBody = 256 * 1024;

  Map<String, String> headers(StalkerEndpoint e, [String token = '']) =>
      StalkerHeaders.build(endpoint: e, mac: mac, token: token, lang: lang);

  Future<Object?> _get(
    StalkerEndpoint e,
    String query, {
    String token = '',
    int retries = 1,
    Duration timeout = _timeout,
  }) async {
    final resp = await AppHttp.get(
      Uri.parse('${e.api}?$query'),
      headers: headers(e, token),
      retries: retries,
      timeout: timeout,
    );
    if (resp.statusCode != 200) throw StalkerHttpException(resp.statusCode);
    final bytes = resp.bodyBytes;
    // Tek parca get_all_channels (10K+ kanal, MB'larca JSON) UI'yi
    // takmasin diye buyuk govdeler ayri isolate'ta cozulur.
    if (bytes.length > _bigBody) {
      return Isolate.run(() => StalkerJson.decode(bytes));
    }
    return StalkerJson.decode(bytes);
  }

  static bool _isNetwork(Object e) =>
      e is SocketException ||
      e is TimeoutException ||
      e is HttpException ||
      e is HandshakeException ||
      e is TlsException ||
      // AppHttp tum denemeler bitince genel Exception firlatir.
      '$e'.contains('AppHttp.get failed');

  /// Token al; portal token vermezse null. Ag hatasi firlatir.
  Future<String?> handshake(StalkerEndpoint e) async => StalkerJson.token(
    await _get(e, 'type=stb&action=handshake&token=&JsHttpRequest=1-xml'),
  );

  /// Pek cok portal token'i ancak get_profile sonrasi etkinlestirir.
  /// Best-effort: hata oturumu bozmaz.
  Future<void> getProfile(StalkerSession s) async {
    try {
      await _get(
        s.endpoint,
        'type=stb&action=get_profile&hd=1&num_banks=2&stb_type=MAG250'
        '&image_version=218&video_out=hdmi&auth_second_step=1'
        '&not_valid_token=0&api_signature=262&JsHttpRequest=1-xml',
        token: s.token,
        retries: 0,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Stalker] get_profile failed: $e');
    }
  }

  /// Uclari sirayla dener ([preferred] once); ilk token veren kazanir.
  Future<StalkerSession> connect({StalkerEndpoint? preferred}) async {
    final order = [
      if (preferred != null) preferred,
      ...endpoints.where((e) => e != preferred),
    ];
    var allNetwork = order.isNotEmpty;
    Object? last;
    for (final e in order) {
      try {
        final token = await handshake(e);
        if (token != null) {
          final s = StalkerSession(e, token);
          await getProfile(s);
          return s;
        }
        allNetwork = false;
      } catch (err) {
        last = err;
        if (!_isNetwork(err)) allNetwork = false;
      }
    }
    throw StalkerConnectException(network: allNetwork, cause: last);
  }

  /// Kategori adlari (best-effort).
  Future<Map<String, String>> genres(StalkerSession s) async {
    try {
      return StalkerJson.genres(
        await _get(
          s.endpoint,
          'type=itv&action=get_genres&JsHttpRequest=1-xml',
          token: s.token,
        ),
      );
    } catch (_) {
      return const {};
    }
  }

  /// Canli kanallari sayfa sayfa ceker; satirlar [onBatch] ile (ilk batch
  /// kucuk) akar. `get_all_channels` bos donerse `get_ordered_list`.
  /// Donus: yazilan kanal sayisi.
  Future<int> loadLiveChannels(
    StalkerSession s, {
    required String playlistId,
    required Future<void> Function(List<Map<String, Object?>> rows) onBatch,
    int firstBatchSize = 100,
    int batchSize = 500,
  }) async {
    final genreMap = await genres(s);
    var sort = 0;
    var batch = <Map<String, Object?>>[];
    var limit = firstBatchSize;
    var written = 0;

    Future<void> flush() async {
      if (batch.isEmpty) return;
      final out = batch;
      batch = <Map<String, Object?>>[];
      limit = batchSize;
      await onBatch(out);
      written += out.length;
    }

    Future<void> add(List<Map<String, dynamic>> items) async {
      for (final item in items) {
        final row = StalkerMapper.channel(
          item,
          playlistId: playlistId,
          genres: genreMap,
          sortOrder: sort,
        );
        if (row == null) continue;
        sort++;
        batch.add(row);
        if (batch.length >= limit) await flush();
      }
    }

    final tk = Uri.encodeQueryComponent(s.token);
    await _pages(
      s,
      (p) =>
          'type=itv&action=get_all_channels&token=$tk&p=$p'
          '&JsHttpRequest=1-xml',
      add,
    );
    await flush();
    if (written == 0) {
      await _pages(
        s,
        (p) =>
            'type=itv&action=get_ordered_list&genre=*&fav=0'
            '&sortby=number&token=$tk&p=$p&JsHttpRequest=1-xml',
        add,
      );
      await flush();
    }
    return written;
  }

  /// Sayfa dongusu: bos sayfa, yeni kanal getirmeyen sayfa (portal
  /// sayfalamayi yok sayiyor), toplam / sayfa siniri veya hata → dur.
  Future<void> _pages(
    StalkerSession s,
    String Function(int page) query,
    Future<void> Function(List<Map<String, dynamic>> items) onItems,
  ) async {
    final seen = <String>{};
    var fetched = 0;
    for (var page = 1; ; page++) {
      final StalkerPage p;
      try {
        p = StalkerJson.page(
          await _get(
            s.endpoint,
            query(page),
            token: s.token,
            timeout: const Duration(seconds: 60),
          ),
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[Stalker] page $page failed: $e');
        return;
      }
      final fresh = [
        for (final it in p.items)
          if (seen.add('${it['id'] ?? it['cmd'] ?? it.hashCode}')) it,
      ];
      if (fresh.isEmpty) return;
      await onItems(fresh);
      fetched += p.items.length;
      if (!StalkerPaging.hasMore(
        page: page,
        totalItems: p.totalItems,
        perPage: p.maxPageItems,
        fetched: fetched,
        lastPageSize: p.items.length,
      )) {
        return;
      }
    }
  }

  /// Ham komutu oynatilabilir URL'ye cevirir; basarisizsa (401 / bos cmd /
  /// ag) null — cagiran token'i yenileyip tekrar dener.
  Future<String?> createLink(StalkerSession s, String cmd) async {
    try {
      return StalkerJson.linkCmd(
        await _get(
          s.endpoint,
          'type=itv&action=create_link&cmd=${Uri.encodeQueryComponent(cmd)}'
          '&token=${Uri.encodeQueryComponent(s.token)}'
          '&forced_storage=undefined&disable_ad=0&JsHttpRequest=1-xml',
          token: s.token,
          retries: 0,
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Stalker] create_link failed: $e');
      return null;
    }
  }
}
