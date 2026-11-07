import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/channel_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'player_buttons.dart';
import 'player_overlays.dart';
import 'player_top_actions.dart';
import 'player_track_buttons.dart';

/// Oynatıcı kontrol katmanı (üst bar + orta oynat/sar + alt seek bar ve araçlar).
class PlayerControlsOverlay extends StatelessWidget {
  final Player player;
  final String title;
  final String streamType; // 'live' | 'movie' | 'series'
  final String channelId;
  final ChannelModel? channel;
  final VoidCallback onClose;
  final VoidCallback onReconnect;
  final bool aiEnabled;
  final VoidCallback onAiToggle;
  final ValueChanged<SubtitleTrack?> onEmbeddedSubtitleSelected;
  final ValueChanged<AudioTrack> onAudioSelected;
  final BoxFit videoFit;
  final ValueChanged<BoxFit> onFitChange;
  final VoidCallback onPip;
  final VoidCallback onAirplay;
  final bool showPip;
  final bool showAirplay;
  final PlayerFeedback onFeedback;
  final void Function(int deltaMs) onSeekRelative;
  final VoidCallback onToggleMute;
  final bool orientationLocked;
  final VoidCallback onToggleOrientation;
  final VoidCallback? onChannelPanel;
  final VoidCallback? onPrevChannel;
  final VoidCallback? onNextChannel;
  /// Kontroller her zaman agacta kalir; [visible] false iken 200 ms'de
  /// solar, dokunma ve focus almaz (IgnorePointer + ExcludeFocus).
  final bool visible;

  const PlayerControlsOverlay({
    super.key,
    this.visible = true,
    required this.player,
    required this.title,
    required this.streamType,
    required this.channelId,
    required this.channel,
    required this.onClose,
    required this.onReconnect,
    required this.aiEnabled,
    required this.onAiToggle,
    required this.onEmbeddedSubtitleSelected,
    required this.onAudioSelected,
    required this.videoFit,
    required this.onFitChange,
    required this.onPip,
    required this.onAirplay,
    required this.showPip,
    required this.showAirplay,
    required this.onFeedback,
    required this.onSeekRelative,
    required this.onToggleMute,
    required this.orientationLocked,
    required this.onToggleOrientation,
    this.onChannelPanel,
    this.onPrevChannel,
    this.onNextChannel,
  });

  bool get _isLive => streamType == 'live';

  static bool get _isCupertino =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeFocus(
        excluding: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Container(
              // Ust/alt scrim: orta bant tamamen seffaf (video gorunur),
              // kenarlarda beyaz metin icin yeterli kontrast.
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xB3000000),
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0xD9000000),
                  ],
                  stops: [0, 0.22, 0.55, 1],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _topBar(context),
                    const Spacer(),
                    _centerRow(context),
                    const Spacer(),
                    _isLive ? _liveBottom(context) : _vodBottom(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _order(double o, Widget child) =>
      FocusTraversalOrder(order: NumericFocusOrder(o), child: child);

  Widget _topBar(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Row(
        children: [
          _order(1, PlayerIconButton(
              icon: _isCupertino ? CupertinoIcons.chevron_down : Icons.arrow_back,
              tooltip: _isCupertino ? l.close : l.back,
              onTap: onClose)),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: Colors.white)),
            ),
          ),
          if (onChannelPanel != null)
            _order(1.5, PlayerIconButton(
                icon: Icons.list, tooltip: l.playerChannelPanelTooltip, onTap: onChannelPanel!)),
          // AirPlay yalnızca SES yönlendirir (media_kit texture render, AVPlayerLayer yok).
          if (showAirplay)
            _order(1.7, PlayerIconButton(
                icon: Icons.airplay, tooltip: l.playerAirplayTooltip, onTap: onAirplay)),
          if (showPip)
            _order(1.8, PlayerIconButton(
                icon: Icons.picture_in_picture_alt, tooltip: l.playerPipTooltip, onTap: onPip)),
          _order(1.85, PlayerIconButton(
            icon: orientationLocked ? Icons.screen_lock_rotation : Icons.screen_rotation,
            color: orientationLocked ? playerAccent(context).accent : Colors.white,
            tooltip: l.playerOrientationLock,
            onTap: onToggleOrientation,
          )),
          if (channel != null)
            _order(1.87, WatchlistButton(channel: channel!, onFeedback: onFeedback)),
          _order(1.9, FavoriteButton(channelId: channelId)),
          _order(2, PlayerIconButton(
              icon: Icons.refresh, tooltip: l.playerReconnectTooltip, onTap: onReconnect)),
        ],
      ),
    );
  }

  Widget _centerRow(BuildContext context) {
    final l = AppLocalizations.of(context);
    final playPause = _order(3, StreamBuilder<bool>(
      stream: player.stream.playing,
      initialData: player.state.playing,
      builder: (ctx, snap) => PlayPauseButton(
        playing: snap.data ?? false,
        visible: visible,
        // Explicit play/pause — playOrPause toggle state race'inde ters atabiliyor.
        onTap: () {
          if (player.state.playing) {
            player.pause();
            onFeedback(Icons.pause, l.playerPaused);
          } else {
            player.play();
            onFeedback(Icons.play_arrow, l.playerPlaying);
          }
        },
      ),
    ));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isLive && onPrevChannel != null)
          PlayerIconButton(
              icon: Icons.skip_previous, tooltip: l.playerPrevChannel, onTap: onPrevChannel!, size: 32)
        else if (!_isLive)
          PlayerIconButton(
              icon: Icons.replay_10,
              tooltip: l.playerSeekBackward,
              onTap: () {
                HapticFeedback.lightImpact();
                onSeekRelative(-10000);
              },
              size: 32),
        const SizedBox(width: 40),
        playPause,
        const SizedBox(width: 40),
        if (_isLive && onNextChannel != null)
          PlayerIconButton(
              icon: Icons.skip_next, tooltip: l.playerNextChannel, onTap: onNextChannel!, size: 32)
        else if (!_isLive)
          PlayerIconButton(
              icon: Icons.forward_10,
              tooltip: l.playerSeekForward,
              onTap: () {
                HapticFeedback.lightImpact();
                onSeekRelative(10000);
              },
              size: 32),
      ],
    );
  }

  Widget _toolsRow(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _order(3.5, SubtitleButton(
          aiEnabled: aiEnabled,
          aiAvailable: !_isLive,
          player: player,
          onAiToggle: onAiToggle,
          onEmbeddedSelected: onEmbeddedSubtitleSelected,
          onFeedback: onFeedback,
        )),
        if (!_isLive) _order(4, SpeedButton(player: player, onFeedback: onFeedback)),
        _order(5, AudioTrackButton(
            player: player, onFeedback: onFeedback, onSelected: onAudioSelected)),
        _order(5.5, AspectRatioButton(fit: videoFit, onChange: onFitChange)),
        _order(5.8, ResolutionButton(player: player, onFeedback: onFeedback)),
        _order(6, StreamBuilder<double>(
          stream: player.stream.volume,
          initialData: player.state.volume,
          builder: (ctx, snap) {
            final vol = snap.data ?? 100.0;
            return PlayerIconButton(
              icon: vol > 0 ? Icons.volume_up : Icons.volume_off,
              tooltip: vol > 0 ? l.playerMuteTooltip : l.playerUnmuteTooltip,
              onTap: onToggleMute,
            );
          },
        )),
      ],
    );
  }

  Widget _liveBottom(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: AppColors.live, size: 8),
              const SizedBox(width: 6),
              Text(l.playerLiveLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _toolsRow(context),
        ],
      ),
    );
  }

  Widget _vodBottom(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.xl),
      child: Column(
        children: [
          PlayerSeekBar(player: player),
          const SizedBox(height: Spacing.sm),
          _toolsRow(context),
        ],
      ),
    );
  }
}

/// VOD seek bar. Surukleme sirasinda yerel degeri gosterir (pozisyon
/// stream'i thumb'i geri cekmez) ve seek'i yalniz birakinca yapar —
/// her frame'de seek istegi network stream'i bogmasin.
class PlayerSeekBar extends StatefulWidget {
  final Player player;
  const PlayerSeekBar({super.key, required this.player});

  @override
  State<PlayerSeekBar> createState() => _PlayerSeekBarState();
}

class _PlayerSeekBarState extends State<PlayerSeekBar> {
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = playerAccent(context).accent;
    final player = widget.player;
    final timeStyle = theme.textTheme.labelMedium?.copyWith(
      color: Colors.white70,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    // Kumanda ipucu yalniz D-pad/klavye modunda (dokunmatikte gurultu).
    final showRemoteHint =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

    // Tek StreamBuilder (position); duration senkron okunur — bazı IPTV
    // VOD'larda stream.duration hiç emit etmiyor.
    return StreamBuilder<Duration>(
      stream: player.stream.position,
      builder: (ctx, posSnap) {
        final pos = posSnap.data ?? player.state.position;
        final duration = player.state.duration;
        final durMs = duration.inMilliseconds;
        final hasDuration = durMs > 0;
        final maxMs = hasDuration ? durMs : 1;
        final dragging = _dragMs != null;
        final valMs = (_dragMs ?? pos.inMilliseconds.toDouble())
            .clamp(0.0, maxMs.toDouble());
        final shownPos =
            dragging ? Duration(milliseconds: valMs.round()) : pos;
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(ctx).copyWith(
                trackHeight: dragging ? 6 : 4,
                activeTrackColor: accent,
                inactiveTrackColor: Colors.white24,
                thumbColor: accent,
                overlayColor: accent.withValues(alpha: 0.2),
                thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: dragging ? 9 : 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                trackShape: const RoundedRectSliderTrackShape(),
              ),
              child: Slider(
                min: 0,
                max: maxMs.toDouble(),
                value: valMs,
                semanticFormatterCallback: (v) =>
                    formatPlayerDuration(Duration(milliseconds: v.round())),
                onChangeStart: hasDuration
                    ? (v) => setState(() => _dragMs = v)
                    : null,
                onChanged: hasDuration
                    ? (v) => setState(() => _dragMs = v)
                    : null,
                onChangeEnd: hasDuration
                    ? (v) {
                        final cap = (durMs - 3000).clamp(0, durMs);
                        player.seek(Duration(
                            milliseconds: v.toInt().clamp(0, cap)));
                        setState(() => _dragMs = null);
                      }
                    : null,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatPlayerDuration(shownPos), style: timeStyle),
                if (showRemoteHint)
                  ExcludeSemantics(
                    child: Text(l.playerSeekHint,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white38,
                            fontWeight: FontWeight.w400)),
                  ),
                Text(formatPlayerDuration(duration), style: timeStyle),
              ],
            ),
          ],
        );
      },
    );
  }
}
