import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/channel_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../billing/providers/purchases_providers.dart';
import '../../billing/widgets/paywall_trigger.dart';
import '../../home/home_provider.dart';
import 'player_buttons.dart';

// ── Favori toggle ───────────────────────────────────────────────────────────

class FavoriteButton extends ConsumerStatefulWidget {
  final String channelId;
  const FavoriteButton({super.key, required this.channelId});

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> {
  bool? _isFavorite;
  ChannelModel? _channel;

  @override
  void initState() {
    super.initState();
    _loadChannel();
  }

  Future<void> _loadChannel() async {
    try {
      final ch = await ref.read(channelRepoProvider).getById(widget.channelId);
      if (mounted) {
        setState(() {
          _channel = ch;
          _isFavorite = ch?.isFavorite ?? false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFavorite = false);
    }
  }

  Future<void> _toggle() async {
    if (_channel == null || _isFavorite == null) return;
    final newFav = !_isFavorite!;
    setState(() => _isFavorite = newFav);
    try {
      await ref.read(channelRepoProvider).toggleFavorite(_channel!.id, newFav);
      _channel = _channel!.copyWith(isFavorite: newFav);
      // Home state'i yerinde güncelle — invalidate tab/kategori/aramayı
      // 'home'a sıfırlıyordu.
      await ref.read(homeProvider.notifier).applyFavoriteChange(_channel!.id, newFav);
    } catch (_) {
      if (mounted) setState(() => _isFavorite = !newFav);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fav = _isFavorite ?? false;
    return PlayerIconButton(
      icon: fav ? Icons.star : Icons.star_border,
      tooltip: fav ? l.playerFavoriteRemove : l.playerFavoriteAdd,
      onTap: _toggle,
    );
  }
}

// ── İzleme listesi (bookmark) — ekleme Pro, çıkarma serbest (Android) ───────

class WatchlistButton extends ConsumerStatefulWidget {
  final ChannelModel channel;
  final PlayerFeedback onFeedback;
  const WatchlistButton({super.key, required this.channel, required this.onFeedback});

  @override
  ConsumerState<WatchlistButton> createState() => _WatchlistButtonState();
}

class _WatchlistButtonState extends ConsumerState<WatchlistButton> {
  bool? _inList;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final v = await ref
          .read(watchlistRepoProvider)
          .isInWatchlist(widget.channel.id, widget.channel.playlistId);
      if (mounted) setState(() => _inList = v);
    } catch (_) {
      if (mounted) setState(() => _inList = false);
    }
  }

  Future<void> _toggle() async {
    if (_busy || _inList == null) return;
    final l = AppLocalizations.of(context);
    final repo = ref.read(watchlistRepoProvider);
    final ch = widget.channel;
    _busy = true;
    try {
      if (_inList!) {
        await repo.remove(ch.id, ch.playlistId);
        if (mounted) setState(() => _inList = false);
        widget.onFeedback(Icons.bookmark_border, l.playerWatchlistRemoved);
        return;
      }
      if (!ref.read(isProProvider)) {
        final ok = await requirePro(context, ref, PaywallTrigger.watchlist);
        if (!ok || !mounted) return;
      }
      await repo.add(ch.id, ch.playlistId);
      if (mounted) setState(() => _inList = true);
      widget.onFeedback(Icons.bookmark, l.playerWatchlistAdded);
    } catch (e) {
      debugPrint('[Player] watchlist toggle failed: $e');
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final inList = _inList ?? false;
    return PlayerIconButton(
      icon: inList ? Icons.bookmark : Icons.bookmark_border,
      color: inList ? AppColors.accent : Colors.white,
      tooltip: l.playerWatchlistTooltip,
      onTap: _toggle,
    );
  }
}
