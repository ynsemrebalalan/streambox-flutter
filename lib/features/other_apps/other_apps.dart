import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Diğer uygulamalarımız" listesi. Kaynak: https://daveddeva.com/apps.json
/// (Site/src/pages/apps.json.ts sitedeki uygulama listesinden üretir; siteye yeni
/// uygulama eklenince tüm uygulamalarda liste kendiliğinden güncellenir.)
///
/// Bu dosya Flutter uygulamaları arasında aynen kopyalanır; yalnızca [OtherAppsRepository]
/// oluşturulurken uygulamanın paket adı verilir.

const otherAppsUrl = 'https://daveddeva.com/apps.json';
const _supportedSchema = 1;

/// Bağlantılar yalnızca bu adreslere gidebilir; JSON değiştirilse bile başka yere yönlendirilemez.
const _allowedStoreHosts = {'play.google.com', 'apps.apple.com'};
const _allowedIconHosts = {'daveddeva.com'};

enum OtherAppsPlatform { android, ios }

class OtherApp {
  final String slug;
  final String name;
  final String tagline;
  final String? iconUrl;
  final String storeUrl;
  final bool kids;

  const OtherApp({
    required this.slug,
    required this.name,
    required this.tagline,
    required this.iconUrl,
    required this.storeUrl,
    required this.kids,
  });
}

bool _isAllowedUrl(Object? value, Set<String> hosts) {
  if (value is! String) return false;
  final uri = Uri.tryParse(value);
  return uri != null && uri.scheme == 'https' && hosts.contains(uri.host);
}

String? _localized(Object? map, String lang) {
  if (map is! Map) return null;
  final value = map[lang] ?? map['en'] ?? map['tr'];
  return value is String && value.trim().isNotEmpty ? value : null;
}

/// JSON'u doğrular ve bu uygulamada gösterilecek listeyi döner. Hatalı veride boş liste döner.
List<OtherApp> parseOtherApps(
  String raw, {
  required String selfPackage,
  required OtherAppsPlatform platform,
  required String lang,
}) {
  final Object? doc;
  try {
    doc = jsonDecode(raw);
  } on FormatException {
    return const [];
  }
  if (doc is! Map || doc['schema'] != _supportedSchema || doc['apps'] is! List) {
    return const [];
  }

  final result = <OtherApp>[];
  for (final item in doc['apps'] as List) {
    if (item is! Map) continue;
    if (item['packageName'] == selfPackage) continue;

    final store = platform == OtherAppsPlatform.android ? item['android'] : item['ios'];
    final name = _localized(item['name'], lang);
    final slug = item['slug'];
    if (slug is! String || name == null || !_isAllowedUrl(store, _allowedStoreHosts)) {
      continue;
    }

    result.add(OtherApp(
      slug: slug,
      name: name,
      tagline: _localized(item['tagline'], lang) ?? '',
      iconUrl: _isAllowedUrl(item['icon'], _allowedIconHosts) ? item['icon'] as String : null,
      storeUrl: store as String,
      kids: item['kids'] == true,
    ));
  }
  return result;
}

/// Listeyi indirir, son başarılı yanıtı cihazda saklar. İnternet yoksa saklanan liste kullanılır.
class OtherAppsRepository {
  OtherAppsRepository({required this.selfPackage, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 6),
              receiveTimeout: const Duration(seconds: 6),
              responseType: ResponseType.plain,
            ));

  final String selfPackage;
  final Dio _dio;

  static const _cacheKey = 'other_apps_json';
  static const _cacheTimeKey = 'other_apps_fetched_at';
  static const _maxAge = Duration(hours: 24);
  static const _maxBytes = 256 * 1024;

  Future<List<OtherApp>> load({
    required OtherAppsPlatform platform,
    required String lang,
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    var raw = prefs.getString(_cacheKey);
    final fetchedAt = DateTime.fromMillisecondsSinceEpoch(prefs.getInt(_cacheTimeKey) ?? 0);
    final stale = DateTime.now().difference(fetchedAt) > _maxAge;

    if (raw == null || stale || forceRefresh) {
      final fresh = await _fetch();
      // Yalnızca geçerli liste üreten yanıt saklanır; bozuk yanıt eski listeyi silmez.
      if (fresh != null &&
          parseOtherApps(fresh, selfPackage: selfPackage, platform: platform, lang: lang)
              .isNotEmpty) {
        raw = fresh;
        await prefs.setString(_cacheKey, fresh);
        await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      }
    }

    if (raw == null) return const [];
    return parseOtherApps(raw, selfPackage: selfPackage, platform: platform, lang: lang);
  }

  Future<String?> _fetch() async {
    try {
      final response = await _dio.get<String>(otherAppsUrl);
      final body = response.data;
      if (response.statusCode != 200 || body == null || body.length > _maxBytes) return null;
      return body;
    } on DioException {
      return null;
    }
  }
}
