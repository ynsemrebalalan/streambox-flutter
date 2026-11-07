import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/core/providers/app_providers.dart';
import 'package:iptv_ai_player/data/models/channel_model.dart';
import 'package:iptv_ai_player/data/models/playlist_model.dart';
import 'package:iptv_ai_player/data/repositories/channel_repository.dart';
import 'package:iptv_ai_player/data/repositories/playlist_repository.dart';
import 'package:iptv_ai_player/data/repositories/settings_repository.dart';
import 'package:iptv_ai_player/features/home/home_provider.dart';

ChannelModel _ch(String id, {String type = 'live', String cat = 'Ulusal'}) =>
    ChannelModel(
      id: id,
      playlistId: 'pl',
      name: 'Kanal $id',
      streamUrl: 'http://h/$id',
      streamType: type,
      category: cat,
    );

class _FakePlaylistRepo extends PlaylistRepository {
  @override
  Future<List<PlaylistModel>> getAll() async => const [
        PlaylistModel(id: 'pl', name: 'P', type: 'm3u', url: 'http://h/p.m3u'),
      ];
}

class _FakeSettingsRepo extends SettingsRepository {
  @override
  Future<String?> get(String key) async => null;
}

class _FakeChannelRepo extends ChannelRepository {
  final searchCalls = <String>[];
  final categoryCompleters = <String, Completer<List<ChannelModel>>>{};
  bool favorite = false;

  @override
  Future<List<ChannelModel>> getRecentlyWatched(String playlistId,
          {int limit = 20}) async =>
      const [];
  @override
  Future<List<ChannelModel>> getContinueWatching(String playlistId,
          {int limit = 20}) async =>
      const [];
  @override
  Future<List<ChannelModel>> getLatestByType(String playlistId, String streamType,
          {int limit = 20}) async =>
      const [];
  @override
  Future<List<ChannelModel>> getWatchedMovies(String playlistId,
          {int limit = 20}) async =>
      const [];
  @override
  Future<List<ChannelModel>> getWatchedSeriesEpisodes(String playlistId,
          {int limit = 20}) async =>
      const [];
  @override
  Future<List<String>> getCategories(String playlistId, String streamType) async =>
      const ['A', 'B'];
  @override
  Future<List<String>> getOrphanSeriesCategories(String playlistId) async =>
      const [];
  @override
  Future<List<ChannelModel>> getOrphanSeriesAsMovies(String playlistId,
          {String? category}) async =>
      const [];
  @override
  Future<List<ChannelModel>> getByType(String playlistId, String streamType) async =>
      [_ch('t-$streamType', type: streamType)];
  @override
  Future<List<ChannelModel>> getFavorites(String playlistId) async =>
      favorite ? [_ch('fav').copyWith(isFavorite: true)] : const [];
  @override
  Future<List<ChannelModel>> getByCategory(
      String playlistId, String streamType, String category,
      {int limit = ChannelRepository.listLimit}) {
    final c = categoryCompleters[category];
    if (c != null) return c.future;
    return Future.value([_ch('c-$category', cat: category)]);
  }

  @override
  Future<List<ChannelModel>> search(String playlistId, String query,
      {String? streamType}) async {
    searchCalls.add(query);
    return [_ch('s-$query')];
  }
}

Future<ProviderContainer> _container(_FakeChannelRepo repo) async {
  final c = ProviderContainer(overrides: [
    playlistRepoProvider.overrideWithValue(_FakePlaylistRepo()),
    settingsRepoProvider.overrideWithValue(_FakeSettingsRepo()),
    channelRepoProvider.overrideWithValue(repo),
  ]);
  await c.read(homeProvider.future);
  // build() icindeki detailed microtask bitsin.
  await Future<void>.delayed(const Duration(milliseconds: 10));
  return c;
}

void main() {
  group('HomeNotifier.search', () {
    test('2 karakterden kisa sorgu aramaz, sonuclari temizler', () async {
      final repo = _FakeChannelRepo();
      final c = await _container(repo);
      addTearDown(c.dispose);
      final n = c.read(homeProvider.notifier);

      await n.search(' a ');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(repo.searchCalls, isEmpty);
      expect(c.read(homeProvider).value!.searchResults, isEmpty);
      expect(c.read(homeProvider).value!.isSearching, isFalse);
    });

    test('300ms debounce: hizli yazimda tek sorgu, trimli', () async {
      final repo = _FakeChannelRepo();
      final c = await _container(repo);
      addTearDown(c.dispose);
      final n = c.read(homeProvider.notifier);

      unawaited(n.search('ya'));
      unawaited(n.search('yar'));
      unawaited(n.search(' yarg '));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(repo.searchCalls, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(repo.searchCalls, ['yarg']);
      final s = c.read(homeProvider).value!;
      expect(s.searchQuery, 'yarg');
      expect(s.searchResults.map((e) => e.id), ['s-yarg']);
      expect(s.isSearching, isFalse);
    });

    test('bos sorgu sonuclari temizler', () async {
      final repo = _FakeChannelRepo();
      final c = await _container(repo);
      addTearDown(c.dispose);
      final n = c.read(homeProvider.notifier);
      await n.search('trt');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(c.read(homeProvider).value!.searchResults, isNotEmpty);
      await n.search('');
      expect(c.read(homeProvider).value!.searchResults, isEmpty);
      expect(c.read(homeProvider).value!.searchQuery, '');
    });
  });

  group('HomeNotifier stale async', () {
    test('selectCategory: eski sonuc yeni secimi ezmez', () async {
      final repo = _FakeChannelRepo();
      final c = await _container(repo);
      addTearDown(c.dispose);
      final n = c.read(homeProvider.notifier);
      await n.selectTab('live');

      final a = Completer<List<ChannelModel>>();
      final b = Completer<List<ChannelModel>>();
      repo.categoryCompleters['A'] = a;
      repo.categoryCompleters['B'] = b;

      final fa = n.selectCategory('A');
      final fb = n.selectCategory('B');
      b.complete([_ch('b1', cat: 'B')]);
      await fb;
      a.complete([_ch('a1', cat: 'A')]);
      await fa;

      final s = c.read(homeProvider).value!;
      expect(s.selectedCategory, 'B');
      expect(s.channels.map((e) => e.id), ['b1']);
      expect(s.isLoading, isFalse);
    });

    test('selectTab sonrasi gelen eski kategori sonucu tab degistirmez',
        () async {
      final repo = _FakeChannelRepo();
      final c = await _container(repo);
      addTearDown(c.dispose);
      final n = c.read(homeProvider.notifier);
      await n.selectTab('live');

      final a = Completer<List<ChannelModel>>();
      repo.categoryCompleters['A'] = a;
      final fa = n.selectCategory('A');
      await n.selectTab('home');
      a.complete([_ch('a1', cat: 'A')]);
      await fa;

      final s = c.read(homeProvider).value!;
      expect(s.activeTab, 'home');
      expect(s.selectedCategory, '');
    });
  });

  group('HomeNotifier secim koruyan guncellemeler', () {
    test('reloadPreservingSelection tab/kategori/aramayi korur', () async {
      final repo = _FakeChannelRepo();
      final c = await _container(repo);
      addTearDown(c.dispose);
      final n = c.read(homeProvider.notifier);
      await n.selectTab('live');
      await n.selectCategory('B');

      await n.reloadPreservingSelection();
      final s = c.read(homeProvider).value!;
      expect(s.activeTab, 'live');
      expect(s.selectedCategory, 'B');
      expect(s.channels.map((e) => e.id), ['c-B']);
    });

    test('applyFavoriteChange state icinde gunceller, tab degismez', () async {
      final repo = _FakeChannelRepo();
      final c = await _container(repo);
      addTearDown(c.dispose);
      final n = c.read(homeProvider.notifier);
      await n.selectTab('live');
      await n.selectCategory('A');

      await n.applyFavoriteChange('c-A', true);
      final s = c.read(homeProvider).value!;
      expect(s.activeTab, 'live');
      expect(s.selectedCategory, 'A');
      expect(s.channels.single.isFavorite, isTrue);
    });
  });
}
