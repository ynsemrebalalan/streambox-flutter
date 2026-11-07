import 'package:flutter/material.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/utils/secure_storage.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../player/logic/ai_entitlement.dart';
import '../../player/logic/playback_policy.dart';
import '../../player/logic/supported_ai_languages.dart';

/// Ayarlar > AI Altyazı (Android SettingsScreen AI bölümü paritesi):
/// sağlayıcı (yerleşik Groq / kendi OpenAI anahtarı), anahtar alanı
/// (SecureStorage) + maliyet uyarısı, hedef dil, banner.
class AiSubtitleSettingsSection extends StatefulWidget {
  const AiSubtitleSettingsSection({super.key});

  @override
  State<AiSubtitleSettingsSection> createState() => _AiSubtitleSettingsSectionState();
}

class _AiSubtitleSettingsSectionState extends State<AiSubtitleSettingsSection> {
  final _repo = SettingsRepository();
  final _keyCtrl = TextEditingController();
  bool _loaded = false;
  String _provider = 'groq';
  String _targetLang = '';
  bool _banner = true;
  bool _hasKey = false;
  bool _showKey = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = await _repo.get(SettingsKeys.aiProvider) ?? 'groq';
    final lang = await _repo.get(SettingsKeys.aiTargetLang) ?? '';
    final banner = await _repo.get(SettingsKeys.aiBannerEnabled) != 'false';
    final key = await SecureStorage.getOpenAiKey();
    if (!mounted) return;
    setState(() {
      _provider = provider;
      _targetLang = lang;
      _banner = banner;
      _hasKey = key.isNotEmpty;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _setProvider(String p) async {
    setState(() => _provider = p);
    await _repo.set(SettingsKeys.aiProvider, p);
    Analytics.setAiProvider(p);
  }

  Future<void> _saveKey() async {
    final k = _keyCtrl.text.trim();
    if (k.isEmpty) return;
    await SecureStorage.setUserOpenAiKey(k);
    _keyCtrl.clear();
    if (mounted) {
      setState(() => _hasKey = true);
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _clearKey() async {
    await SecureStorage.clearOpenAiKey();
    if (mounted) setState(() => _hasKey = false);
  }

  Future<void> _pickLanguage() async {
    final l = AppLocalizations.of(context);
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.settingsAiTargetLangDialogTitle),
        children: [
          SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: ListView(
              children: [
                RadioListTile<String>(
                  value: '',
                  groupValue: _targetLang,
                  title: Text(l.settingsAiTargetLangAuto),
                  onChanged: (v) => Navigator.pop(ctx, v),
                ),
                for (final e in SupportedAiLanguages.sortedByDisplay())
                  RadioListTile<String>(
                    value: e.key,
                    groupValue: _targetLang,
                    title: Text(e.value),
                    subtitle: Text(e.key.toUpperCase()),
                    onChanged: (v) => Navigator.pop(ctx, v),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null) return;
    setState(() => _targetLang = picked);
    await _repo.set(SettingsKeys.aiTargetLang, picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    if (!_loaded) return const ListTile(title: SizedBox(height: 24));
    final hint = TextStyle(fontSize: 12, color: cs.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: Icon(Icons.auto_awesome, size: 22, color: cs.primary),
          title: Text(l.settingsAiWhisperTitle),
          subtitle: Text(l.settingsAiWhisperSubtitle, style: hint),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'groq',
                label: Text('${l.settingsAiProviderGroq} · ${l.settingsAiProviderGroqBadge}'),
              ),
              ButtonSegment(
                value: 'openai',
                label: Text('${l.settingsAiProviderOpenai} · ${l.settingsAiProviderOpenaiBadge}'),
              ),
            ],
            selected: {_provider},
            onSelectionChanged: (s) => _setProvider(s.first),
          ),
        ),
        if (_provider == 'groq')
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(l.settingsAiGroqInfo(kAiTrialDays), style: hint),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasKey)
                  Row(
                    children: [
                      Expanded(
                        child: Text(l.settingsAiOpenaiKeySaved,
                            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
                      ),
                      IconButton(
                        tooltip: l.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _clearKey,
                      ),
                    ],
                  ),
                TextField(
                  controller: _keyCtrl,
                  obscureText: !_showKey,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l.settingsAiOpenaiKeyLabel,
                    hintText: l.settingsAiOpenaiKeyPlaceholder,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showKey = !_showKey),
                        ),
                        IconButton(icon: const Icon(Icons.check), onPressed: _saveKey),
                      ],
                    ),
                  ),
                  onSubmitted: (_) => _saveKey(),
                ),
                const SizedBox(height: 6),
                Text(l.settingsAiOpenaiCost, style: hint),
              ],
            ),
          ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.translate, size: 22, color: cs.primary),
          title: Text(l.settingsAiTargetLangTitle),
          subtitle: Text(l.settingsAiTargetLangSubtitle, style: hint),
          trailing: Text(
            _targetLang.isEmpty
                ? l.settingsAiTargetLangAuto
                : SupportedAiLanguages.displayName(_targetLang),
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          onTap: _pickLanguage,
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: Icon(Icons.info_outline, size: 22, color: cs.primary),
          title: Text(l.settingsAiBannerTitle),
          subtitle: Text(l.settingsAiBannerSubtitle, style: hint),
          value: _banner,
          onChanged: (v) async {
            setState(() => _banner = v);
            await _repo.set(SettingsKeys.aiBannerEnabled, v ? 'true' : 'false');
          },
        ),
      ],
    );
  }
}

/// "Altyazı varsayılan açık" (Android settings_subtitle_default_on).
class SubtitleDefaultOnTile extends StatefulWidget {
  const SubtitleDefaultOnTile({super.key});

  @override
  State<SubtitleDefaultOnTile> createState() => _SubtitleDefaultOnTileState();
}

class _SubtitleDefaultOnTileState extends State<SubtitleDefaultOnTile> {
  final _repo = SettingsRepository();
  bool? _on;

  @override
  void initState() {
    super.initState();
    _repo.get(SettingsKeys.subtitleDefaultOn).then((v) {
      if (mounted) setState(() => _on = v == 'true');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return SwitchListTile(
      secondary: Icon(Icons.closed_caption, size: 22, color: cs.primary),
      title: Text(l.settingsSubtitleDefaultOn),
      subtitle: Text(l.settingsSubtitleDefaultOnSubtitle,
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      value: _on ?? false,
      onChanged: _on == null
          ? null
          : (v) async {
              setState(() => _on = v);
              await _repo.set(SettingsKeys.subtitleDefaultOn, v ? 'true' : 'false');
            },
    );
  }
}

/// Önbellek süresi (Android slider 2–8 sn) → mpv cache-secs.
class BufferDurationTile extends StatefulWidget {
  const BufferDurationTile({super.key});

  @override
  State<BufferDurationTile> createState() => _BufferDurationTileState();
}

class _BufferDurationTileState extends State<BufferDurationTile> {
  final _repo = SettingsRepository();
  int _ms = kBufferMsDefault;

  @override
  void initState() {
    super.initState();
    _repo.get(SettingsKeys.playerBufferMs).then((v) {
      final ms = int.tryParse(v ?? '');
      if (ms != null && mounted) setState(() => _ms = ms.clamp(kBufferMsMin, kBufferMsMax));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.speed, size: 22, color: cs.primary),
          title: Text(l.settingsBufferDuration),
          subtitle: Text(l.settingsBufferSeconds(_ms ~/ 1000),
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ),
        Slider(
          min: kBufferMsMin.toDouble(),
          max: kBufferMsMax.toDouble(),
          divisions: (kBufferMsMax - kBufferMsMin) ~/ 1000,
          value: _ms.toDouble(),
          onChanged: (v) => setState(() => _ms = v.round()),
          onChangeEnd: (v) => _repo.set(SettingsKeys.playerBufferMs, '${v.round()}'),
        ),
      ],
    );
  }
}
