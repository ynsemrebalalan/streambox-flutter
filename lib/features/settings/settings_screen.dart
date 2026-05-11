import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
//
// Yeniden tasarim notlari (Kotlin paritesi):
//   - ProfileHeaderCard en uste tasindi (avatar + email + Pro CTA)
//     ⇒ ayri "Hesap" section'i kaldirildi (duplicate idi)
//   - 7 sectio renkli ikon dairesi olan SectionHeader ile gruplandi
//   - Sectionlar collapsible (CollapsibleSection): Pro, Icerik, Gorunum, EPG,
//     Altyazi, Oynatici, Hakkinda. Kullanici istemedigi alani sakliyor.
//   - Pro features (Watchlist/Theme/Parental/CloudSync/Profiller) Hakkinda'dan
//     ayrildi → kendi "Pro Ozellikler" section'i (gold tema)
//   - Playlist Yonetimi + Kategori Filtresi "Icerik" section'i
//   - PiP + Reklamsiz bilgi "Oynatici" section'inda birlestirildi
//   - Hakkinda: sadece versiyon + Yasal Bildirim linki + Veri Silme linki
// ─────────────────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _epgCtrl = TextEditingController();
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
          _epgCtrl.text = state.epgUrl;
          _initialized = true;
        }
        return _buildScaffold(context, state);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, SettingsState state) {
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
            // ── Profile Header (Hesap section'i bunla replace edildi) ─────
            const _ProfileHeaderCard(),
            const SizedBox(height: Spacing.xl),

            // ── Pro Features (gold) ────────────────────────────────────
            _SectionHeader(
              title: l.settingsProSection,
              icon:  Icons.workspace_premium,
              color: const Color(0xFFFFB300),
            ),
            _CollapsibleSection(
              storageKey: 'sec_pro',
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.bookmark_outline),
                      title:   Text(l.watchlistTitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap:   () => context.push(AppRoutes.watchlist),
                    ),
                    ListTile(
                      leading: const Icon(Icons.color_lens_outlined),
                      title:   Text(l.themePickerTitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap:   () => context.push(AppRoutes.themePicker),
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title:   Text(l.parentalLockTitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap:   () => context.push(AppRoutes.parentalLock),
                    ),
                    const CloudSyncTile(),
                    ListTile(
                      leading: const Icon(Icons.switch_account),
                      title:   Text(l.profileSwitcherTitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap:   () => context.push(AppRoutes.profiles),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.xl),

            // ── İçerik (blue) ──────────────────────────────────────────
            _SectionHeader(
              title: l.settingsContentSection,
              icon:  Icons.playlist_play,
              color: const Color(0xFF2196F3),
            ),
            _CollapsibleSection(
              storageKey: 'sec_content',
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.playlist_add),
                      title:   Text(l.settingsPlaylistManagement),
                      trailing: const Icon(Icons.chevron_right),
                      onTap:   () => context.push(AppRoutes.playlists),
                    ),
                    ListTile(
                      leading: const Icon(Icons.filter_list),
                      title:   Text(l.categoryFilterTitle),
                      subtitle: Text(l.settingsCategoryFilterSubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap:   () => context.push(AppRoutes.categoryFilter),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.xl),

            // ── Görünüm (purple): Tema + Dil ───────────────────────────
            _SectionHeader(
              title: l.settingsAppearanceSection,
              icon:  Icons.palette_outlined,
              color: const Color(0xFF9C27B0),
            ),
            _CollapsibleSection(
              storageKey: 'sec_appearance',
              child: const _AppearanceCard(),
            ),
            const SizedBox(height: Spacing.xl),

            // ── EPG (green) ────────────────────────────────────────────
            _SectionHeader(
              title: l.settingsEpgSection,
              icon:  Icons.schedule,
              color: const Color(0xFF4CAF50),
            ),
            _CollapsibleSection(
              storageKey: 'sec_epg',
              child: _EpgCard(epgCtrl: _epgCtrl, state: state),
            ),
            const SizedBox(height: Spacing.xl),

            // ── Altyazı (orange) ───────────────────────────────────────
            _SectionHeader(
              title: l.settingsSubtitleSection,
              icon:  Icons.subtitles_outlined,
              color: const Color(0xFFFF9800),
            ),
            _CollapsibleSection(
              storageKey: 'sec_subtitle',
              child: _SubtitleCard(state: state),
            ),
            const SizedBox(height: Spacing.xl),

            // ── Oynatıcı (red): PiP + Reklamsız bilgi ──────────────────
            _SectionHeader(
              title: l.settingsPlayerSection,
              icon:  Icons.play_circle_outline,
              color: const Color(0xFFE53935),
            ),
            _CollapsibleSection(
              storageKey: 'sec_player',
              child: const _PlayerCard(),
            ),
            const SizedBox(height: Spacing.xl),

            // ── Hakkında (gray) ────────────────────────────────────────
            _SectionHeader(
              title: l.settingsAboutSection,
              icon:  Icons.info_outline,
              color: const Color(0xFF607D8B),
            ),
            _CollapsibleSection(
              storageKey: 'sec_about',
              child: _AboutCard(appVersion: _appVersion),
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
    super.dispose();
  }
}

// ── Profile Header (Kotlin'deki ProfileHeaderCard'a paralel) ────────────────

class _ProfileHeaderCard extends ConsumerWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authStateProvider).valueOrNull;
    final isPro = ref.watch(isProProvider);
    final cs = Theme.of(context).colorScheme;

    final isAuth = auth is AuthAuthenticated;
    final email = isAuth ? auth.email : null;
    final initial = (email != null && email.isNotEmpty)
        ? email.substring(0, 1).toUpperCase()
        : '?';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isAuth) {
            context.push(AppRoutes.account);
          } else {
            context.push(AppRoutes.login);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end:   Alignment.bottomRight,
                    colors: isPro
                        ? const [Color(0xFFFFB300), Color(0xFFFF8F00)]
                        : [cs.primary, cs.primaryContainer],
                  ),
                ),
                alignment: Alignment.center,
                child: isAuth
                    ? Text(initial,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white))
                    : const Icon(Icons.person_outline,
                        size: 28, color: Colors.white),
              ),
              const SizedBox(width: Spacing.md),
              // Email + status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email ?? l.settingsTapToSignIn,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (isPro) ...[
                          const Icon(Icons.workspace_premium,
                              size: 14, color: Color(0xFFFFB300)),
                          const SizedBox(width: 4),
                          Text(l.authProActive,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFB300))),
                        ] else
                          Text(
                            isAuth ? l.authFreeTier : l.authNotSignedIn,
                            style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Pro CTA chip (Free user)
              if (!isPro)
                Padding(
                  padding: const EdgeInsets.only(left: Spacing.sm),
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                    onPressed: () => context.push(
                      AppRoutes.paywall,
                      extra: <String, dynamic>{'trigger': 'settingsCta'},
                    ),
                    child: Text(l.authUpgradeToPro,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                )
              else
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section header (renkli ikon dairesi + baslik) ───────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: Spacing.sm),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            title.toUpperCase(),
            style: TextStyle(
                fontSize:      TextSize.caption,
                fontWeight:    FontWeight.w700,
                letterSpacing: 1.2,
                color:         cs.onSurface),
          ),
        ],
      ),
    );
  }
}

// ── Collapsible section (animasyonlu expand/collapse) ───────────────────────
//
// `storageKey` ile her section'in acik/kapali state'i SettingsRepository'de
// saklanir. Boylece kullanici acik biraktigi alan tekrar geldiginde acik kalir.
// Default: TUM section'lar acik (ilk acilisla overwhelm olmasin diye degil,
// daha kullanici-dostu ki herseyi gorsun; ileride default kapali yapabiliriz).
// ─────────────────────────────────────────────────────────────────────────────

class _CollapsibleSection extends StatefulWidget {
  final String storageKey;
  final Widget child;
  const _CollapsibleSection({
    required this.storageKey,
    required this.child,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _expanded = true;
  bool _loaded = false;
  static const _prefix = 'settings_expand_';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await SettingsRepository().get('$_prefix${widget.storageKey}');
    if (!mounted) return;
    setState(() {
      _expanded = v != 'false';  // default ACIK
      _loaded = true;
    });
  }

  Future<void> _toggle() async {
    setState(() => _expanded = !_expanded);
    await SettingsRepository()
        .set('$_prefix${widget.storageKey}', _expanded ? 'true' : 'false');
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return widget.child;
    return Column(
      children: [
        // Tap header'i kart'in ustune koymak yerine kartin disinda
        // gizli bir gesture detector koyacaktik; ama daha sezgisel cozum:
        // header sag'inda kucuk chevron, kartin uzerinde InkWell.
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: _expanded
                ? const BoxConstraints()
                : const BoxConstraints(maxHeight: 0),
            child: widget.child,
          ),
        ),
        // Toggle butonu kartin altinda (compact)
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: _toggle,
            icon: AnimatedRotation(
              turns: _expanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 220),
              child: const Icon(Icons.keyboard_arrow_down, size: 18),
            ),
            label: Text(
              _expanded
                  ? AppLocalizations.of(context).commonHide
                  : AppLocalizations.of(context).commonShow,
              style: const TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Appearance: Tema + Dil ──────────────────────────────────────────────────

class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Card(
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
          const Divider(height: 1),
          ListTile(
            leading:  const Icon(Icons.language),
            title:    Text(l.language),
            subtitle: Text(_localeLabel(l, ref.watch(localeProvider))),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap:    () => _showLanguagePicker(context, ref, l),
          ),
        ],
      ),
    );
  }
}

// ── EPG ─────────────────────────────────────────────────────────────────────

class _EpgCard extends ConsumerWidget {
  final TextEditingController epgCtrl;
  final SettingsState state;
  const _EpgCard({required this.epgCtrl, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              children: [
                TextField(
                  controller: epgCtrl,
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
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: [
                    for (final p in kTurkishEpgPresets)
                      _EpgPresetChip(
                        label:    p.label,
                        selected: state.epgUrl == p.url,
                        onTap: () {
                          epgCtrl.text = p.url;
                          ref.read(settingsScreenProvider.notifier).setEpgUrl(p.url);
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
                      await ref.read(settingsScreenProvider.notifier).save();
                      final activeId = ref.read(activePlaylistProvider);
                      if (activeId.isEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.settingsSelectPlaylistFirst)),
                          );
                        }
                        return;
                      }
                      try {
                        await ref.read(epgServiceProvider).syncEpg(activeId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.settingsEpgUpdated)),
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
        // EPG Pro: Guide + Auto-refresh
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
      ],
    );
  }
}

// ── Subtitle ────────────────────────────────────────────────────────────────

class _SubtitleCard extends ConsumerWidget {
  final SettingsState state;
  const _SubtitleCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    return Card(
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
                  ref.read(settingsScreenProvider.notifier).setSubtitleFontSize(v);
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
                DropdownMenuItem(value: 'white',  child: Text(l.subtitleColorWhite)),
                DropdownMenuItem(value: 'yellow', child: Text(l.subtitleColorYellow)),
                DropdownMenuItem(value: 'green',  child: Text(l.subtitleColorGreen)),
                DropdownMenuItem(value: 'cyan',   child: Text(l.subtitleColorCyan)),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(settingsScreenProvider.notifier).setSubtitleTextColor(v);
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
                DropdownMenuItem(value: 'semi',   child: Text(l.subtitleBgSemi)),
                DropdownMenuItem(value: 'opaque', child: Text(l.subtitleBgOpaque)),
                DropdownMenuItem(value: 'none',   child: Text(l.subtitleBgNone)),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(settingsScreenProvider.notifier).setSubtitleBgColor(v);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Player: PiP + Reklamsız bilgi ───────────────────────────────────────────

class _PlayerCard extends ConsumerWidget {
  const _PlayerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final isPro = ref.watch(isProProvider);
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Column(
        children: [
          const _PipAutoTile(),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              isPro ? Icons.block : Icons.campaign,
              color: isPro ? Colors.green : cs.onSurfaceVariant,
            ),
            title: Text(
                isPro ? l.settingsAdsRemoved : l.settingsAdsFreeNotice,
                style: TextStyle(
                    fontSize: isPro ? 14 : 12,
                    color: isPro ? null : cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

// ── About: versiyon + legal + veri silme ────────────────────────────────────

class _AboutCard extends StatelessWidget {
  final String appVersion;
  const _AboutCard({required this.appVersion});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title:    Text(l.homeAppTitle),
            subtitle: Text(l.settingsAppVersion(
                appVersion.isEmpty ? '…' : appVersion)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title:   Text(l.settingsLegalNotice),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap:   () => _launchUrl(
                'https://iptvaiplayer.com.tr/Ekran/index.php'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title:    Text(l.settingsDataDeletion),
            subtitle: Text(l.settingsDataDeletionSubtitle),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap:   () => _launchUrl(
                'https://iptvaiplayer.com.tr/Ekran/verisilme.php'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ── PiP auto-mode tile (Pro gating) — eski yapidan korundu ──────────────────

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
