import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/epg_presets.dart';
import '../../data/services/epg_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/data/auth_state.dart';
import '../auth/providers/auth_providers.dart';
import '../billing/providers/purchases_providers.dart';
import '../billing/widgets/paywall_trigger.dart';
import '../cloud_sync/widgets/cloud_sync_tile.dart';
import '../epg/widgets/epg_auto_refresh_tile.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class SettingsState {
  final String epgUrl;
  final String openAiApiKey;
  final String openAiLanguage;
  final String groqProxyUrl;
  final String groqProxySecret;
  final bool   isSaving;
  final String subtitleFontSize;
  final String subtitleTextColor;
  final String subtitleBgColor;

  const SettingsState({
    this.epgUrl           = '',
    this.openAiApiKey     = '',
    this.openAiLanguage   = '',
    this.groqProxyUrl     = '',
    this.groqProxySecret  = '',
    this.isSaving         = false,
    this.subtitleFontSize  = '16',
    this.subtitleTextColor = 'white',
    this.subtitleBgColor   = 'semi',
  });

  SettingsState copyWith({
    String? epgUrl,
    String? openAiApiKey,
    String? openAiLanguage,
    String? groqProxyUrl,
    String? groqProxySecret,
    bool?   isSaving,
    String? subtitleFontSize,
    String? subtitleTextColor,
    String? subtitleBgColor,
  }) => SettingsState(
    epgUrl:            epgUrl            ?? this.epgUrl,
    openAiApiKey:      openAiApiKey      ?? this.openAiApiKey,
    openAiLanguage:    openAiLanguage    ?? this.openAiLanguage,
    groqProxyUrl:      groqProxyUrl      ?? this.groqProxyUrl,
    groqProxySecret:   groqProxySecret   ?? this.groqProxySecret,
    isSaving:          isSaving          ?? this.isSaving,
    subtitleFontSize:  subtitleFontSize  ?? this.subtitleFontSize,
    subtitleTextColor: subtitleTextColor ?? this.subtitleTextColor,
    subtitleBgColor:   subtitleBgColor   ?? this.subtitleBgColor,
  );
}

// ── Provider ──────────────────────────────────────────────────────────────────

final settingsScreenProvider =
    AsyncNotifierProvider<SettingsScreenNotifier, SettingsState>(
  SettingsScreenNotifier.new,
);

class SettingsScreenNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final repo = ref.read(settingsRepoProvider);
    final all  = await repo.getAll();
    return SettingsState(
      epgUrl:           all[SettingsKeys.epgUrl]           ?? '',
      openAiApiKey:     all[SettingsKeys.openAiApiKey]     ?? '',
      openAiLanguage:   all[SettingsKeys.openAiLanguage]   ?? '',
      groqProxyUrl:     all[SettingsKeys.groqProxyUrl]     ?? '',
      groqProxySecret:  all[SettingsKeys.groqProxySecret]  ?? '',
      subtitleFontSize:  all[SettingsKeys.subtitleFontSize]  ?? '16',
      subtitleTextColor: all[SettingsKeys.subtitleTextColor] ?? 'white',
      subtitleBgColor:   all[SettingsKeys.subtitleBgColor]   ?? 'semi',
    );
  }

  void setEpgUrl(String v)          => _update((s) => s.copyWith(epgUrl: v));
  void setOpenAiApiKey(String v)    => _update((s) => s.copyWith(openAiApiKey: v));
  void setOpenAiLanguage(String v)  => _update((s) => s.copyWith(openAiLanguage: v));
  void setGroqProxyUrl(String v)    => _update((s) => s.copyWith(groqProxyUrl: v));
  void setGroqProxySecret(String v) => _update((s) => s.copyWith(groqProxySecret: v));
  void setSubtitleFontSize(String v) {
    _update((s) => s.copyWith(subtitleFontSize: v));
    ref.read(settingsRepoProvider).set(SettingsKeys.subtitleFontSize, v);
  }
  void setSubtitleTextColor(String v) {
    _update((s) => s.copyWith(subtitleTextColor: v));
    ref.read(settingsRepoProvider).set(SettingsKeys.subtitleTextColor, v);
  }
  void setSubtitleBgColor(String v) {
    _update((s) => s.copyWith(subtitleBgColor: v));
    ref.read(settingsRepoProvider).set(SettingsKeys.subtitleBgColor, v);
  }

  Future<void> save() async {
    final s = state.value;
    if (s == null) return;
    _update((st) => st.copyWith(isSaving: true));
    final repo = ref.read(settingsRepoProvider);
    await repo.set(SettingsKeys.epgUrl,          s.epgUrl);
    await repo.set(SettingsKeys.openAiApiKey,    s.openAiApiKey);
    await repo.set(SettingsKeys.openAiLanguage,  s.openAiLanguage);
    await repo.set(SettingsKeys.groqProxyUrl,    s.groqProxyUrl);
    await repo.set(SettingsKeys.groqProxySecret, s.groqProxySecret);
    _update((st) => st.copyWith(isSaving: false));
  }

  void _update(SettingsState Function(SettingsState) fn) {
    final current = state.value;
    if (current != null) state = AsyncData(fn(current));
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _epgCtrl          = TextEditingController();
  final _openAiKeyCtrl    = TextEditingController();
  final _openAiLangCtrl   = TextEditingController();
  final _groqProxyUrlCtrl = TextEditingController();
  final _groqSecretCtrl   = TextEditingController();
  bool _initialized = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() {
          _appVersion = '${info.version} (${info.buildNumber})';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(settingsScreenProvider);
    final l = AppLocalizations.of(context);

    return async.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error:   (e, _) => Scaffold(
          body: Center(child: Text(l.errorWithDetails('$e')))),
      data: (state) {
        if (!_initialized) {
          _epgCtrl.text          = state.epgUrl;
          _openAiKeyCtrl.text    = state.openAiApiKey;
          _openAiLangCtrl.text   = state.openAiLanguage;
          _groqProxyUrlCtrl.text = state.groqProxyUrl;
          _groqSecretCtrl.text   = state.groqProxySecret;
          _initialized = true;
        }
        return _buildScaffold(context, state);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, SettingsState state) {
    final cs = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title:   Text(l.settingsTitle),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
        actions: [
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.all(14),
              child:   SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon:    const Icon(Icons.save_outlined),
              tooltip: l.save,
              onPressed: () async {
                await ref.read(settingsScreenProvider.notifier).save();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.settingsSaved)),
                  );
                }
              },
            ),
        ],
      ),
      body: ResponsiveCenter(
        maxWidth: Responsive.formMaxWidth(context),
        child: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          // ── Appearance ───────────────────────────────────────────────────
          _SectionHeader(title: l.settingsAppearanceSection),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title:   Text(l.settingsThemeDark),
                  value:   ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).setMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title:   Text(l.settingsThemeLight),
                  value:   ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).setMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title:   Text(l.settingsThemeSystem),
                  value:   ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).setMode(v!),
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.xl),

          // ── Dil / Language ───────────────────────────────────────────────
          // Önceki sürümde Görünüm Card'ı içinde Theme radio'larından sonra
          // Divider altında yer alıyordu → kullanıcı geri bildirimi: "yok
          // gibi görünüyor". Kendi başlıklı Card olarak ayrı bölüm yapıldı.
          _SectionHeader(title: l.language),
          Card(
            child: ListTile(
              leading:  const Icon(Icons.language),
              title:    Text(l.language),
              subtitle: Text(_localeLabel(l, ref.watch(localeProvider))),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap:    () => _showLanguagePicker(context, ref, l),
            ),
          ),

          const SizedBox(height: Spacing.xl),

          // ── EPG ──────────────────────────────────────────────────────────
          _SectionHeader(title: l.settingsEpgSection),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                children: [
                  TextField(
                    controller: _epgCtrl,
                    decoration: InputDecoration(
                      labelText: l.settingsEpgUrlLabel,
                      hintText:  'https://epg.example.com/epg.xml.gz',
                      border:    const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.rss_feed),
                    ),
                    onChanged: (v) =>
                        ref.read(settingsScreenProvider.notifier).setEpgUrl(v),
                  ),
                  const SizedBox(height: Spacing.md),
                  // Hazır kaynaklar — Türkiye XMLTV listesi tek tıkla doldurulur
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      '${l.settingsEpgPresetsTitle}:',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: TextSize.caption,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Wrap(
                    spacing:    Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: [
                      for (final p in kTurkishEpgPresets)
                        _EpgPresetChip(
                          label:    p.label,
                          selected: state.epgUrl == p.url,
                          onTap: () {
                            _epgCtrl.text = p.url;
                            ref
                                .read(settingsScreenProvider.notifier)
                                .setEpgUrl(p.url);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon:  const Icon(Icons.sync),
                      label: Text(l.settingsEpgRefreshNow),
                      onPressed: () async {
                        // Save first
                        await ref
                            .read(settingsScreenProvider.notifier)
                            .save();
                        final activeId = ref.read(activePlaylistProvider);
                        if (activeId.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l.settingsSelectPlaylistFirst)),
                            );
                          }
                          return;
                        }
                        try {
                          await ref
                              .read(epgServiceProvider)
                              .syncEpg(activeId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l.settingsEpgUpdated)),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.settingsEpgError('$e'))),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // EPG Pro extras: Guide + Auto-refresh
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.live_tv),
                  title:   Text(l.epgGuideTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap:   () => context.push(AppRoutes.epgGuide),
                ),
                const EpgAutoRefreshTile(),
              ],
            ),
          ),

          const SizedBox(height: Spacing.xl),

          // AI altyazı (Whisper) ayarları artık görünür değil — Groq proxy
          // URL/Secret build-time gömülü (lib/core/utils/build_config.dart).
          // SettingsState alanları geriye dönük uyum için duruyor; geliştirici
          // SecureStorage'a manuel yazarak override edebilir.

          // ── Subtitle Styling ────────────────────────────────────────────
          _SectionHeader(title: l.settingsSubtitleSection),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: Text(l.settingsSubtitleFontSize),
                  trailing: DropdownButton<String>(
                    value: state.subtitleFontSize,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: '14', child: Text(l.subtitleSizeSmall)),
                      DropdownMenuItem(value: '16', child: Text(l.subtitleSizeNormal)),
                      DropdownMenuItem(value: '20', child: Text(l.subtitleSizeLarge)),
                      DropdownMenuItem(value: '24', child: Text(l.subtitleSizeExtraLarge)),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(settingsScreenProvider.notifier)
                            .setSubtitleFontSize(v);
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: Text(l.settingsSubtitleTextColor),
                  trailing: DropdownButton<String>(
                    value: state.subtitleTextColor,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 'white', child: Text(l.subtitleColorWhite)),
                      DropdownMenuItem(value: 'yellow', child: Text(l.subtitleColorYellow)),
                      DropdownMenuItem(value: 'green', child: Text(l.subtitleColorGreen)),
                      DropdownMenuItem(value: 'cyan', child: Text(l.subtitleColorCyan)),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(settingsScreenProvider.notifier)
                            .setSubtitleTextColor(v);
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.format_color_fill),
                  title: Text(l.settingsSubtitleBgColor),
                  trailing: DropdownButton<String>(
                    value: state.subtitleBgColor,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 'semi', child: Text(l.subtitleBgSemi)),
                      DropdownMenuItem(value: 'opaque', child: Text(l.subtitleBgOpaque)),
                      DropdownMenuItem(value: 'none', child: Text(l.subtitleBgNone)),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(settingsScreenProvider.notifier)
                            .setSubtitleBgColor(v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.xl),

          // ── Hesap ────────────────────────────────────────────────────────
          // Phase B'de eklendi (Adım 22). Anon ise "Giriş yap" CTA, login ise
          // email + plan göster. Pro kullanıcı dışında "Pro'ya Geç" satırı.
          _SectionHeader(title: l.authAccountSection),
          _AccountCard(),

          const SizedBox(height: Spacing.xl),

          // ── About ────────────────────────────────────────────────────────
          _SectionHeader(title: l.settingsAboutSection),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title:   Text(l.homeAppTitle),
                  subtitle: Text(l.settingsAppVersion(_appVersion.isEmpty ? '…' : _appVersion),
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title:   Text(l.settingsPlaylistManagement),
                  onTap:   () => context.push(AppRoutes.playlists),
                ),
                ListTile(
                  leading: const Icon(Icons.filter_list),
                  title:   Text(l.categoryFilterTitle),
                  subtitle: Text(l.settingsCategoryFilterSubtitle),
                  onTap:   () => context.push(AppRoutes.categoryFilter),
                ),
                // Phase 1 — Pro features
                ListTile(
                  leading: const Icon(Icons.bookmark_outline),
                  title:   Text(l.watchlistTitle),
                  onTap:   () => context.push(AppRoutes.watchlist),
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens_outlined),
                  title:   Text(l.themePickerTitle),
                  onTap:   () => context.push(AppRoutes.themePicker),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title:   Text(l.parentalLockTitle),
                  onTap:   () => context.push(AppRoutes.parentalLock),
                ),
                // Phase 2 — Cloud Sync (Pro)
                const CloudSyncTile(),
                // Phase 6 — Multi-profile (Pro)
                ListTile(
                  leading: const Icon(Icons.switch_account),
                  title:   Text(l.profileSwitcherTitle),
                  onTap:   () => context.push(AppRoutes.profiles),
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.xl),

          // ── PiP (Phase 4) ────────────────────────────────────────────────
          _SectionHeader(title: l.settingsPipSection),
          const Card(child: _PipAutoTile()),

          const SizedBox(height: Spacing.xl),

          // ── Reklamsız notice (Phase 5) ───────────────────────────────────
          _SectionHeader(title: l.settingsAdsSection),
          Card(
            child: ListTile(
              leading: Icon(
                ref.watch(isProProvider) ? Icons.block : Icons.campaign,
                color: ref.watch(isProProvider) ? Colors.green : null,
              ),
              title: Text(ref.watch(isProProvider)
                  ? l.settingsAdsRemoved
                  : l.settingsAdsFreeNotice),
            ),
          ),

          const SizedBox(height: Spacing.xxl),
        ],
      ),
      ),
    );
  }

  @override
  void dispose() {
    _epgCtrl.dispose();
    _openAiKeyCtrl.dispose();
    _openAiLangCtrl.dispose();
    _groqProxyUrlCtrl.dispose();
    _groqSecretCtrl.dispose();
    super.dispose();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
            left: Spacing.sm, bottom: Spacing.sm),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
              fontSize:    TextSize.caption,
              fontWeight:  FontWeight.w700,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
}

// ── Account card (Adım 22 Phase B) ──────────────────────────────────────────

class _AccountCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authStateProvider).valueOrNull;
    final isPro = ref.watch(isProProvider);
    final cs = Theme.of(context).colorScheme;

    final isAuth = auth is AuthAuthenticated;
    final email = isAuth ? auth.email : null;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(email ?? l.authNotSignedIn),
            subtitle: Text(isPro ? l.authProActive : l.authFreeTier,
                style: TextStyle(color: cs.onSurfaceVariant)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (isAuth) {
                context.push(AppRoutes.account);
              } else {
                context.push(AppRoutes.login);
              }
            },
          ),
          if (!isPro)
            ListTile(
              leading: Icon(Icons.workspace_premium, color: cs.primary),
              title: Text(l.authUpgradeToPro,
                  style: TextStyle(
                      color: cs.primary, fontWeight: FontWeight.w600)),
              trailing: Icon(Icons.chevron_right, color: cs.primary),
              onTap: () => context.push(
                AppRoutes.paywall,
                extra: <String, dynamic>{'trigger': 'settingsCta'},
              ),
            ),
        ],
      ),
    );
  }
}

// ── Phase 4: PiP auto-mode tile (Pro gating) ────────────────────────────────

class _PipAutoTile extends ConsumerStatefulWidget {
  const _PipAutoTile();

  @override
  ConsumerState<_PipAutoTile> createState() => _PipAutoTileState();
}

class _PipAutoTileState extends ConsumerState<_PipAutoTile> {
  bool _enabled = false;
  bool _loaded = false;
  static const _key = 'pip_auto_enabled';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await SettingsRepository().get(_key);
    if (mounted) {
      setState(() {
        _enabled = v == 'true';
        _loaded = true;
      });
    }
  }

  Future<void> _toggle(bool v) async {
    if (v) {
      final allowed = await requirePro(context, ref, PaywallTrigger.pip);
      if (!allowed) return;
    }
    await SettingsRepository().set(_key, v ? 'true' : 'false');
    if (mounted) setState(() => _enabled = v);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (!_loaded) {
      return const ListTile(title: SizedBox(height: 24));
    }
    return SwitchListTile(
      secondary: const Icon(Icons.picture_in_picture_alt),
      title: Text(l.settingsPipAuto),
      subtitle: Text(l.settingsPipAutoSubtitle),
      value: _enabled,
      onChanged: _toggle,
    );
  }
}

// ── EPG preset chip ──────────────────────────────────────────────────────────

class _EpgPresetChip extends StatelessWidget {
  final String label;
  final bool   selected;
  final VoidCallback onTap;

  const _EpgPresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_circle, size: 16, color: cs.primary),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize:   TextSize.caption,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? cs.onPrimaryContainer
                      : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Language picker helpers ──────────────────────────────────────────────────

String _localeLabel(AppLocalizations l, Locale? locale) {
  switch (locale?.languageCode) {
    case 'tr': return l.languageTurkish;
    case 'en': return l.languageEnglish;
    case 'de': return l.languageGerman;
    case 'ar': return l.languageArabic;
    default:   return l.languageSystem;
  }
}

Future<void> _showLanguagePicker(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l,
) async {
  final current = ref.read(localeProvider);
  // null = system; non-null = explicit override
  final entries = <(Locale?, String)>[
    (null,                 l.languageSystem),
    (const Locale('tr'),   l.languageTurkish),
    (const Locale('en'),   l.languageEnglish),
    (const Locale('de'),   l.languageGerman),
    (const Locale('ar'),   l.languageArabic),
  ];

  await showDialog<void>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(l.language),
      children: [
        for (final (loc, label) in entries)
          RadioListTile<String?>(
            title:      Text(label),
            value:      loc?.languageCode,
            groupValue: current?.languageCode,
            onChanged: (_) {
              ref.read(localeProvider.notifier).setLocale(loc);
              Navigator.of(ctx).pop();
            },
          ),
      ],
    ),
  );
}
