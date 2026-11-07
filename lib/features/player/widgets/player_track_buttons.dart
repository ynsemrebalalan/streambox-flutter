import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'player_buttons.dart';

/// mpv'nin otomatik eklediği sahte parçalar ('auto' / 'no') hariç.
List<T> realTracks<T>(List<T> tracks, String Function(T) id) =>
    tracks.where((t) => id(t) != 'no' && id(t) != 'auto').toList();

String _audioLabel(AppLocalizations l, List<AudioTrack> tracks, AudioTrack t) {
  if (t.title?.isNotEmpty == true) return t.title!;
  if (t.language?.isNotEmpty == true) return t.language!;
  return l.playerAudioTrackFallback(tracks.indexOf(t) + 1);
}

// ── Audio track ─────────────────────────────────────────────────────────────

class AudioTrackButton extends StatelessWidget {
  final Player player;
  final PlayerFeedback onFeedback;
  final ValueChanged<AudioTrack> onSelected;
  const AudioTrackButton({
    super.key,
    required this.player,
    required this.onFeedback,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return StreamBuilder<Tracks>(
      stream: player.stream.tracks,
      initialData: player.state.tracks,
      builder: (ctx, snap) {
        final audio = realTracks(snap.data?.audio ?? const <AudioTrack>[], (t) => t.id);
        if (audio.length <= 1) return const SizedBox.shrink();
        return PlayerIconButton(
          icon: Icons.audiotrack,
          tooltip: l.playerAudioTrackTooltip,
          onTap: () => _showDialog(context, audio),
        );
      },
    );
  }

  Future<void> _showDialog(BuildContext context, List<AudioTrack> tracks) async {
    final l = AppLocalizations.of(context);
    final current = player.state.track.audio;
    final selected = await showDialog<AudioTrack>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.playerAudioTrackDialog),
        children: [
          for (final t in tracks)
            PlayerDialogOption(
              autofocus: current == t,
              selected: current == t,
              label: _audioLabel(l, tracks, t),
              onTap: () => Navigator.pop(ctx, t),
            ),
        ],
      ),
    );
    if (selected == null) return;
    await player.setAudioTrack(selected);
    onSelected(selected);
    onFeedback(Icons.audiotrack, l.playerFeedbackAudio(_audioLabel(l, tracks, selected)));
  }
}

// ── Subtitle picker (AI / embedded / off) ───────────────────────────────────

class SubtitleButton extends StatelessWidget {
  final bool aiEnabled;

  /// AI altyazı yalnızca VOD'da (Android paritesi) — canlıda seçenek gizli.
  final bool aiAvailable;
  final Player player;
  final VoidCallback onAiToggle;

  /// null = altyazı kapatıldı.
  final ValueChanged<SubtitleTrack?> onEmbeddedSelected;
  final PlayerFeedback onFeedback;

  const SubtitleButton({
    super.key,
    required this.aiEnabled,
    required this.aiAvailable,
    required this.player,
    required this.onAiToggle,
    required this.onEmbeddedSelected,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final embeddedActive = player.state.track.subtitle.id != 'no' &&
        player.state.track.subtitle.id != 'auto';
    return PlayerIconButton(
      icon: (aiEnabled || embeddedActive) ? Icons.subtitles : Icons.subtitles_off_outlined,
      tooltip: l.playerSubtitleDialogTitle,
      onTap: () => _open(context),
    );
  }

  Future<void> _open(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final embedded = realTracks(player.state.tracks.subtitle, (t) => t.id);
    final current = player.state.track.subtitle;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ll = AppLocalizations.of(ctx);
        return SimpleDialog(
          title: Text(ll.playerSubtitleDialogTitle),
          children: [
            if (aiAvailable)
              PlayerDialogOption(
                selected: aiEnabled,
                label: aiEnabled
                    ? '${ll.playerSubtitleAi} ${ll.playerSubtitleAiActive}'
                    : ll.playerSubtitleAi,
                onTap: () => Navigator.pop(ctx, 'ai'),
              ),
            for (var i = 0; i < embedded.length; i++)
              PlayerDialogOption(
                selected: !aiEnabled && current.id == embedded[i].id,
                label: ll.playerSubtitleEmbedded(i + 1) +
                    (embedded[i].language != null ? ' (${embedded[i].language})' : ''),
                onTap: () => Navigator.pop(ctx, 'emb_${embedded[i].id}'),
              ),
            PlayerDialogOption(
              selected: !aiEnabled && (current.id == 'no'),
              label: ll.playerSubtitleOff,
              onTap: () => Navigator.pop(ctx, 'off'),
            ),
          ],
        );
      },
    );
    if (result == null) return;
    if (result == 'ai') {
      onAiToggle();
      await player.setSubtitleTrack(SubtitleTrack.no());
    } else if (result == 'off') {
      if (aiEnabled) onAiToggle();
      onFeedback(Icons.subtitles_off, l.playerFeedbackSubtitleOff);
      await player.setSubtitleTrack(SubtitleTrack.no());
      onEmbeddedSelected(null);
    } else if (result.startsWith('emb_')) {
      if (aiEnabled) onAiToggle();
      final id = result.substring(4);
      final track = embedded.firstWhere((t) => t.id == id, orElse: SubtitleTrack.no);
      final lang = track.language;
      onFeedback(
        Icons.subtitles,
        (lang != null && lang.isNotEmpty)
            ? l.playerFeedbackSubtitle(lang)
            : l.playerFeedbackSubtitleLoading,
      );
      await player.setSubtitleTrack(track);
      onEmbeddedSelected(track);
    }
  }
}

// ── Aspect ratio ────────────────────────────────────────────────────────────

String fitLabel(AppLocalizations l, BoxFit f) => switch (f) {
      BoxFit.cover => l.playerFitCover,
      BoxFit.fill => l.playerFitStretch,
      _ => l.playerFitOriginal,
    };

class AspectRatioButton extends StatelessWidget {
  final BoxFit fit;
  final ValueChanged<BoxFit> onChange;
  const AspectRatioButton({super.key, required this.fit, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PlayerIconButton(
      icon: Icons.aspect_ratio,
      tooltip: l.playerScreenSizeTooltip,
      onTap: () async {
        final result = await showDialog<BoxFit>(
          context: context,
          builder: (ctx) {
            final ll = AppLocalizations.of(ctx);
            return SimpleDialog(
              title: Text(ll.playerScreenSizeDialog),
              children: [
                for (final f in const [BoxFit.contain, BoxFit.cover, BoxFit.fill])
                  PlayerDialogOption(
                    selected: fit == f,
                    autofocus: fit == f,
                    label: fitLabel(ll, f),
                    onTap: () => Navigator.pop(ctx, f),
                  ),
              ],
            );
          },
        );
        if (result != null) onChange(result);
      },
    );
  }
}

// ── Resolution ──────────────────────────────────────────────────────────────

class ResolutionButton extends StatelessWidget {
  final Player player;
  final PlayerFeedback onFeedback;
  const ResolutionButton({super.key, required this.player, required this.onFeedback});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PlayerIconButton(
      icon: Icons.high_quality,
      tooltip: l.playerResolutionTooltip,
      onTap: () async {
        final variants = player.state.tracks.video
            .where((t) => t.id != 'no' && (t.w ?? 0) > 0)
            .toList()
          ..sort((a, b) => (b.h ?? 0).compareTo(a.h ?? 0));
        final result = await showDialog<String>(
          context: context,
          builder: (ctx) {
            final ll = AppLocalizations.of(ctx);
            return SimpleDialog(
              title: Text(ll.playerResolutionDialog),
              children: [
                PlayerDialogOption(
                  label: ll.playerResolutionAuto,
                  onTap: () => Navigator.pop(ctx, 'auto'),
                ),
                for (final t in variants)
                  PlayerDialogOption(
                    label: '${t.h}p${t.fps != null ? " ${t.fps!.round()}fps" : ""}',
                    onTap: () => Navigator.pop(ctx, t.id),
                  ),
                if (variants.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(ll.playerSingleQuality,
                        style: const TextStyle(color: Colors.white54)),
                  ),
              ],
            );
          },
        );
        if (result == null) return;
        if (result == 'auto') {
          await player.setVideoTrack(VideoTrack.auto());
          onFeedback(Icons.high_quality, l.playerFeedbackResolution(l.playerResolutionAuto));
        } else {
          final track = variants.firstWhere((t) => t.id == result, orElse: VideoTrack.auto);
          await player.setVideoTrack(track);
          onFeedback(Icons.high_quality, l.playerFeedbackResolution('${track.h}p'));
        }
      },
    );
  }
}
