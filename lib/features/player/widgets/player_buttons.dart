import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

typedef PlayerFeedback = void Function(IconData icon, String text);

/// Oynatici her zaman siyah zemin uzerinde: koyu temalarda tema primary'si
/// (Pro temalar dahil), aydinlik temada marka sarisi kullanilir — aydinlik
/// temanin lacivert primary'si siyah ustunde gorunmezdi.
({Color accent, Color onAccent}) playerAccent(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return cs.brightness == Brightness.dark
      ? (accent: cs.primary, onAccent: cs.onPrimary)
      : (accent: AppColors.accent, onAccent: AppColors.darkBg);
}

bool _isActivateKey(LogicalKeyboardKey key) =>
    key == LogicalKeyboardKey.select ||
    key == LogicalKeyboardKey.enter ||
    key == LogicalKeyboardKey.numpadEnter ||
    key == LogicalKeyboardKey.space ||
    key == LogicalKeyboardKey.gameButtonA;

// ── TV-friendly icon button with visible focus ring ─────────────────────────

class PlayerIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;
  final Color color;

  const PlayerIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 28,
    this.color = Colors.white,
  });

  @override
  State<PlayerIconButton> createState() => _PlayerIconButtonState();
}

class _PlayerIconButtonState extends State<PlayerIconButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final accent = playerAccent(context).accent;
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (_isActivateKey(event.logicalKey)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        button: true,
        label: widget.tooltip,
        excludeSemantics: true,
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.tooltip,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _focused
                    ? accent.withValues(alpha: 0.3)
                    : Colors.transparent,
                border: Border.all(
                  color: _focused ? accent : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: Icon(widget.icon, color: widget.color, size: widget.size),
            ),
          ),
        ),
      ),
    );
  }
}

// ── TV-friendly dialog option ───────────────────────────────────────────────

class PlayerDialogOption extends StatefulWidget {
  final bool autofocus;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const PlayerDialogOption({
    super.key,
    this.autofocus = false,
    this.selected = false,
    required this.label,
    required this.onTap,
  });

  @override
  State<PlayerDialogOption> createState() => _PlayerDialogOptionState();
}

class _PlayerDialogOptionState extends State<PlayerDialogOption> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (_isActivateKey(event.logicalKey)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      // Dialog tema yuzeyinde (siyah degil) -> tema primary'si.
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: _focused
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Icon(
                  widget.selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            _focused ? FontWeight.w600 : FontWeight.w400)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Play/Pause button (autofocus + optimistic state) ────────────────────────

class PlayPauseButton extends StatefulWidget {
  final bool playing;
  final VoidCallback onTap;
  /// Kontroller tekrar gorundugunde (false -> true) focus bu butona doner —
  /// overlay artik her gorunuste yeniden mount edilmiyor (fade icin).
  final bool visible;
  const PlayPauseButton({
    super.key,
    required this.playing,
    required this.onTap,
    this.visible = true,
  });

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  bool _focused = false;
  // Basıldığında stream event beklemeden ikon değişir; gerçek değer gelince teyit.
  bool? _optimisticPlaying;
  DateTime? _lastTapAt;

  final FocusNode _focusNode = FocusNode(debugLabel: 'playPause');

  bool get _displayPlaying => _optimisticPlaying ?? widget.playing;

  @override
  void didUpdateWidget(PlayPauseButton old) {
    super.didUpdateWidget(old);
    if (_optimisticPlaying != null && widget.playing == _optimisticPlaying) {
      _optimisticPlaying = null;
    }
    if (!old.visible && widget.visible) {
      // ExcludeFocus bu frame'de kalkiyor; focus'u bir sonraki frame'de iste.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.visible) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapAt != null &&
        now.difference(_lastTapAt!) < const Duration(milliseconds: 300)) {
      return;
    }
    _lastTapAt = now;
    HapticFeedback.lightImpact();
    setState(() => _optimisticPlaying = !_displayPlaying);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = playerAccent(context).accent;
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (_isActivateKey(event.logicalKey)) {
          _handleTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        button: true,
        label: _displayPlaying ? l.playerPauseAction : l.playerPlayAction,
        excludeSemantics: true,
        onTap: _handleTap,
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _focused
                  ? accent.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: _focused ? accent : Colors.transparent,
                width: 3,
              ),
            ),
            padding: EdgeInsets.all(_focused ? 24 : 20),
            child: Icon(
              _displayPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 44,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Speed button ────────────────────────────────────────────────────────────

class SpeedButton extends StatefulWidget {
  final Player player;
  final PlayerFeedback onFeedback;
  const SpeedButton({super.key, required this.player, required this.onFeedback});

  @override
  State<SpeedButton> createState() => _SpeedButtonState();
}

class _SpeedButtonState extends State<SpeedButton> {
  double _speed = 1.0;
  bool _focused = false;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  Future<void> _showSpeedDialog() async {
    final l = AppLocalizations.of(context);
    final selected = await showDialog<double>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.playerSpeedDialog),
        children: _speeds.map((s) {
          final isSel = s == _speed;
          return PlayerDialogOption(
            autofocus: isSel,
            selected: isSel,
            label: '${s}x',
            onTap: () => Navigator.pop(ctx, s),
          );
        }).toList(),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _speed = selected);
      widget.player.setRate(selected);
      widget.onFeedback(Icons.speed, l.playerFeedbackSpeed('${selected}x'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = playerAccent(context).accent;
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (_isActivateKey(event.logicalKey)) {
          _showSpeedDialog();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _showSpeedDialog,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _focused
                ? accent.withValues(alpha: 0.3)
                : Colors.transparent,
            border: Border.all(
              color: _focused ? accent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.speed, color: Colors.white, size: 20),
              const SizedBox(width: 4),
              Text('${_speed}x',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        ),
      ),
    );
  }
}
