import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../home/home_provider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String channelId;
  final String channelUrl;
  final String title;

  const PlayerScreen({
    super.key,
    required this.channelId,
    required this.channelUrl,
    required this.title,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final Player       _player;
  late final VideoController _controller;
  bool    _controlsVisible = true;
  Timer?  _hideTimer;

  @override
  void initState() {
    super.initState();
    _player     = Player();
    _controller = VideoController(_player);
    _play();
    _startHideTimer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Mark channel as watched
    Future.microtask(() => ref
        .read(homeProvider.notifier)
        .markWatched(widget.channelId));
  }

  void _play() {
    _player.open(Media(widget.channelUrl));
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _player.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _showControls,
        child: Stack(
          children: [
            // Video
            Center(
              child: Video(controller: _controller),
            ),

            // Controls overlay
            AnimatedOpacity(
              opacity:  _controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: _ControlsOverlay(
                player:      _player,
                title:       widget.title,
                onClose:     () => Navigator.pop(context),
                onTap:       _showControls,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Controls overlay ──────────────────────────────────────────────────────────

class _ControlsOverlay extends StatefulWidget {
  final Player      player;
  final String      title;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const _ControlsOverlay({
    required this.player,
    required this.title,
    required this.onClose,
    required this.onTap,
  });

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [
            Color(0xCC000000),
            Colors.transparent,
            Colors.transparent,
            Color(0xCC000000),
          ],
          stops: [0, 0.25, 0.75, 1],
        ),
      ),
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Row(
              children: [
                IconButton(
                  icon:  const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: widget.onClose,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   TextSize.titleSm,
                        fontWeight: FontWeight.w600),
                    maxLines:  1,
                    overflow:  TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Center play/pause
          StreamBuilder<bool>(
            stream: widget.player.stream.playing,
            builder: (ctx, snap) {
              final playing = snap.data ?? false;
              return GestureDetector(
                onTap: widget.player.playOrPause,
                child: Container(
                  decoration: BoxDecoration(
                    color:        Colors.white.withValues(alpha: 0.15),
                    shape:        BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Icon(
                    playing ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size:  40,
                  ),
                ),
              );
            },
          ),

          const Spacer(),

          // Bottom seek bar + time
          StreamBuilder<Duration>(
            stream: widget.player.stream.duration,
            builder: (ctx, durSnap) {
              final duration = durSnap.data ?? Duration.zero;
              final isLive   = duration == Duration.zero;

              return Padding(
                padding: const EdgeInsets.fromLTRB(
                    Spacing.lg, 0, Spacing.lg, Spacing.xl),
                child: Column(
                  children: [
                    if (!isLive)
                      StreamBuilder<Duration>(
                        stream: widget.player.stream.position,
                        builder: (ctx, posSnap) {
                          final pos = posSnap.data ?? Duration.zero;
                          return Column(
                            children: [
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor:   AppColors.accent,
                                  thumbColor:         AppColors.accent,
                                  inactiveTrackColor: Colors.white24,
                                  overlayShape:
                                      SliderComponentShape.noOverlay,
                                  trackHeight: 3,
                                ),
                                child: Slider(
                                  value: (pos.inMilliseconds /
                                          (duration.inMilliseconds
                                              .clamp(1, double.maxFinite)))
                                      .clamp(0, 1),
                                  onChanged: (v) {
                                    final ms = (v * duration.inMilliseconds).toInt();
                                    // Cap 3s before end to prevent restart
                                    final cap = (duration.inMilliseconds - 3000)
                                        .clamp(0, duration.inMilliseconds);
                                    widget.player.seek(
                                        Duration(milliseconds: ms.clamp(0, cap)));
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_fmt(pos),
                                      style: const TextStyle(
                                          color:    Colors.white70,
                                          fontSize: TextSize.caption)),
                                  Text(_fmt(duration),
                                      style: const TextStyle(
                                          color:    Colors.white70,
                                          fontSize: TextSize.caption)),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    if (isLive)
                      const Row(
                        children: [
                          Icon(Icons.circle, color: AppColors.live, size: 8),
                          SizedBox(width: 6),
                          Text('CANLI',
                              style: TextStyle(
                                  color:      Colors.white,
                                  fontSize:   TextSize.caption,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1)),
                        ],
                      ),
                    const SizedBox(height: Spacing.sm),
                    // Playback speed + mute + audio tracks
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _SpeedButton(player: widget.player),
                        const SizedBox(width: Spacing.sm),
                        _AudioTrackButton(player: widget.player),
                        const SizedBox(width: Spacing.sm),
                        StreamBuilder<double>(
                          stream: widget.player.stream.volume,
                          builder: (ctx, snap) {
                            final vol = snap.data ?? 100.0;
                            return IconButton(
                              icon: Icon(
                                vol > 0 ? Icons.volume_up : Icons.volume_off,
                                color: Colors.white,
                              ),
                              onPressed: () => widget.player.setVolume(
                                  vol > 0 ? 0 : 100),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final h  = d.inHours;
    final m  = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s  = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

// ── Audio track button ────────────────────────────────────────────────────────

class _AudioTrackButton extends StatelessWidget {
  final Player player;
  const _AudioTrackButton({required this.player});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Tracks>(
      stream: player.stream.tracks,
      builder: (ctx, tracksSnap) {
        final tracks = tracksSnap.data;
        final audioTracks = tracks?.audio ?? [];
        if (audioTracks.length <= 1) return const SizedBox.shrink();

        return StreamBuilder<Track>(
          stream: player.stream.track,
          builder: (ctx, trackSnap) {
            final current = trackSnap.data;
            return PopupMenuButton<AudioTrack>(
              tooltip: 'Ses parçası',
              icon: const Icon(Icons.audiotrack, color: Colors.white),
              itemBuilder: (_) => audioTracks.map((t) {
                final label = t.title?.isNotEmpty == true
                    ? t.title!
                    : t.language?.isNotEmpty == true
                        ? t.language!
                        : 'Parça ${audioTracks.indexOf(t) + 1}';
                return PopupMenuItem(
                  value: t,
                  child: Row(children: [
                    if (current?.audio == t)
                      const Icon(Icons.check, size: 16),
                    const SizedBox(width: 8),
                    Text(label),
                  ]),
                );
              }).toList(),
              onSelected: (t) => player.setAudioTrack(t),
            );
          },
        );
      },
    );
  }
}

// ── Speed button ──────────────────────────────────────────────────────────────

class _SpeedButton extends StatefulWidget {
  final Player player;
  const _SpeedButton({required this.player});

  @override
  State<_SpeedButton> createState() => _SpeedButtonState();
}

class _SpeedButtonState extends State<_SpeedButton> {
  double _speed = 1.0;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip:      'Oynatma hızı',
      initialValue: _speed,
      onSelected:   (v) {
        setState(() => _speed = v);
        widget.player.setRate(v);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:        Colors.white12,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${_speed}x',
          style: const TextStyle(color: Colors.white, fontSize: TextSize.label),
        ),
      ),
      itemBuilder: (_) => _speeds
          .map((s) => PopupMenuItem(
                value: s,
                child: Text('${s}x'),
              ))
          .toList(),
    );
  }
}
