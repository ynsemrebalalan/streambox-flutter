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

  void setEpgUrl(String v) => _update((s) => s.copyWith(epgUrl: v));
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
    await repo.set(SettingsKeys.epgUrl, s.epgUrl);
    _update((st) => st.copyWith(isSaving: false));
  }

  void _update(SettingsState Function(SettingsState) fn) {
    final current = state.value;
    if (current != null) state = AsyncData(fn(current));
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
//
// Tasarim felsefesi: iOS Settings + Spotify mobil sadelik.
//   - Tek ListView, section'lar bos baslik (caps, gri) + tek Card grup.
//   - Card icinde ListTile + 1px Divider — clutter yok, hiyerarsi temiz.
//   - Hicbir bolum collapsible degil; kullanici scroll eder, tum ozellikler
//     ayni anda kesfedilebilir.
//   - Pro section'da basligin yaninda "PRO" gold chip ipucu verir.
//   - Profile header en uste — gradient avatar + email + status. Auth ise
//     chevron, anon ise "Giris Yap" CTA chip.
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
        setState(() => _appVersion = '${info.version} (${info.buildNumber})');
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
      error: (e, _) => Scaffold(
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
              child: SizedBox(
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
          padding: const EdgeInsets.fromLTRB(
              Spacing.lg, Spacing.md, Spacing.lg, Spacing.xxl),
          children: [
            const _ProfileHeaderCard(),

            _SectionLabel(text: l.settingsProSection, isPro: true),
            _GroupedCard(children: const [_ProSection()]),

            _SectionLabel(text: l.settingsContentSection),
            _GroupedCard(children: const [_ContentSection()]),

            _SectionLabel(text: l.settingsAppearanceSection),
            _GroupedCard(children: const [_AppearanceSection()]),

            _SectionLabel(text: l.settingsEpgSection),
            _GroupedCard(
                children: [_EpgSection(epgCtrl: _epgCtrl, state: state)]),

            _SectionLabel(text: l.settingsSubtitleSection),
            _GroupedCard(children: [_SubtitleSection(state: state)]),

            _SectionLabel(text: l.settingsPlayerSection),
            _GroupedCard(children: const [_PlayerSection()]),

            _SectionLabel(text: l.settingsAboutSection),
            _GroupedCard(children: [_AboutSection(appVersion: _appVersion)]),
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

// ── Profile Header ──────────────────────────────────────────────────────────

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
        : null;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(isAuth ? AppRoutes.account : AppRoutes.login),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg, vertical: Spacing.md + 2),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end:   Alignment.bottomRight,
                    colors: isPro
                        ? const [Color(0xFFFFD54F), Color(0xFFFF8F00)]
                        : [cs.primary, cs.tertiary],
                  ),
                ),
                alignment: Alignment.center,
                child: initial != null
                    ? Text(initial,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white))
                    : const Icon(Icons.person_outline,
                        size: 26, color: Colors.white),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email ?? l.authNotSignedIn,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPro
                          ? l.authProActive
                          : (isAuth ? l.authFreeTier : l.settingsTapToSignIn),
                      style: TextStyle(
                          fontSize: 13,
                          color: isPro
                              ? const Color(0xFFFF8F00)
                              : cs.onSurfaceVariant,
                          fontWeight: isPro ? FontWeight.w600 : null),
                    ),
                  ],
                ),
              ),
              if (!isPro && isAuth)
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => context.push(
                    AppRoutes.paywall,
                    extra: <String, dynamic>{'trigger': 'settingsCta'},
                  ),
                  child: Text(l.authUpgradeToPro,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                )
              else if (!isAuth)
                FilledButton(
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  onPressed: () => context.push(AppRoutes.login),
                  child: Text(l.authSignInButton,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
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

// ── Section header (sade, sade, sade) ───────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isPro;
  const _SectionLabel({required this.text, this.isPro = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Spacing.md, Spacing.xl + 4, Spacing.md, Spacing.xs + 2),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: cs.onSurfaceVariant),
          ),
          if (isPro) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Color(0xFFFF8F00)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Grouped card wrapper (single Card per section) ──────────────────────────

class _GroupedCard extends StatelessWidget {
  final List<Widget> children;
  const _GroupedCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(children: children),
      ),
    );
  }
}

// Internal divider between tiles — Card grup hissini bozmadan satir ayraci.
class _TileDivider extends StatelessWidget {
  const _TileDivider();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 56),
        child: Divider(
            height: 1,
            thickness: 0.5,
            color: Theme.of(context).colorScheme.outlineVariant),
      );
}

// ── Pro section ─────────────────────────────────────────────────────────────

class _ProSection extends ConsumerWidget {
  const _ProSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        _NavTile(
          icon: Icons.bookmark_outline,
          title: l.watchlistTitle,
          onTap: () => context.push(AppRoutes.watchlist),
        ),
        const _TileDivider(),
        _NavTile(
          icon: Icons.color_lens_outlined,
          title: l.themePickerTitle,
          onTap: () => context.push(AppRoutes.themePicker),
        ),
        const _TileDivider(),
        _NavTile(
          icon: Icons.lock_outline,
          title: l.parentalLockTitle,
          onTap: () => context.push(AppRoutes.parentalLock),
        ),
        const _TileDivider(),
        const CloudSyncTile(),
        const _TileDivider(),
        _NavTile(
          icon: Icons.switch_account,
          title: l.profileSwitcherTitle,
          onTap: () => context.push(AppRoutes.profiles),
        ),
      ],
    );
  }
}

// ── Content section ─────────────────────────────────────────────────────────

class _ContentSection extends ConsumerWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        _NavTile(
          icon: Icons.playlist_play_outlined,
          title: l.settingsPlaylistManagement,
          onTap: () => context.push(AppRoutes.playlists),
        ),
        const _TileDivider(),
        _NavTile(
          icon: Icons.filter_list,
          title: l.categoryFilterTitle,
          subtitle: l.settingsCategoryFilterSubtitle,
          onTap: () => context.push(AppRoutes.categoryFilter),
        ),
      ],
    );
  }
}

// ── Appearance section (Theme + Language) ───────────────────────────────────

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final modeLabel = switch (themeMode) {
      ThemeMode.dark   => l.settingsThemeDark,
      ThemeMode.light  => l.settingsThemeLight,
      ThemeMode.system => l.settingsThemeSystem,
    };

    return Column(
      children: [
        _NavTile(
          icon: themeMode == ThemeMode.dark
              ? Icons.dark_mode_outlined
              : themeMode == ThemeMode.light
                  ? Icons.light_mode_outlined
                  : Icons.brightness_auto_outlined,
          title: l.settingsAppearanceSection,
          trailingText: modeLabel,
          onTap: () => _showThemePicker(context, ref, l),
        ),
        const _TileDivider(),
        _NavTile(
          icon: Icons.language,
          title: l.language,
          trailingText: _localeLabel(l, ref.watch(localeProvider)),
          onTap: () => _showLanguagePicker(context, ref, l),
        ),
      ],
    );
  }
}

// ── EPG section ─────────────────────────────────────────────────────────────

class _EpgSection extends ConsumerWidget {
  final TextEditingController epgCtrl;
  final SettingsState state;
  const _EpgSection({required this.epgCtrl, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Spacing.lg, Spacing.md, Spacing.lg, Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: epgCtrl,
                decoration: InputDecoration(
                  labelText: l.settingsEpgUrlLabel,
                  hintText:  'https://epg.example.com/epg.xml.gz',
                  isDense: true,
                  border:    const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.rss_feed, size: 20),
                ),
                onChanged: (v) =>
                    ref.read(settingsScreenProvider.notifier).setEpgUrl(v),
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
                        epgCtrl.text = p.url;
                        ref.read(settingsScreenProvider.notifier).setEpgUrl(p.url);
                      },
                    ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon:  const Icon(Icons.sync, size: 18),
                  label: Text(l.settingsEpgRefreshNow),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
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
        const _TileDivider(),
        _NavTile(
          icon: Icons.live_tv,
          title: l.epgGuideTitle,
          onTap: () => context.push(AppRoutes.epgGuide),
        ),
        const _TileDivider(),
        // Subtle background tint so Pro tile siniri belirgin olsun
        Container(
          color: cs.surface.withValues(alpha: 0.0),
          child: const EpgAutoRefreshTile(),
        ),
      ],
    );
  }
}

// ── Subtitle section ────────────────────────────────────────────────────────

class _SubtitleSection extends ConsumerWidget {
  final SettingsState state;
  const _SubtitleSection({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    return Column(
      children: [
        _DropdownTile(
          icon: Icons.format_size,
          title: l.settingsSubtitleFontSize,
          value: state.subtitleFontSize,
          items: {
            '14': l.subtitleSizeSmall,
            '16': l.subtitleSizeNormal,
            '20': l.subtitleSizeLarge,
            '24': l.subtitleSizeExtraLarge,
          },
          onChanged: (v) => ref
              .read(settingsScreenProvider.notifier)
              .setSubtitleFontSize(v),
        ),
        const _TileDivider(),
        _DropdownTile(
          icon: Icons.color_lens,
          title: l.settingsSubtitleTextColor,
          value: state.subtitleTextColor,
          items: {
            'white':  l.subtitleColorWhite,
            'yellow': l.subtitleColorYellow,
            'green':  l.subtitleColorGreen,
            'cyan':   l.subtitleColorCyan,
          },
          onChanged: (v) => ref
              .read(settingsScreenProvider.notifier)
              .setSubtitleTextColor(v),
        ),
        const _TileDivider(),
        _DropdownTile(
          icon: Icons.format_color_fill,
          title: l.settingsSubtitleBgColor,
          value: state.subtitleBgColor,
          items: {
            'semi':   l.subtitleBgSemi,
            'opaque': l.subtitleBgOpaque,
            'none':   l.subtitleBgNone,
          },
          onChanged: (v) => ref
              .read(settingsScreenProvider.notifier)
              .setSubtitleBgColor(v),
        ),
      ],
    );
  }
}

// ── Player section: PiP + Ads notice ────────────────────────────────────────

class _PlayerSection extends ConsumerWidget {
  const _PlayerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final isPro = ref.watch(isProProvider);
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        const _PipAutoTile(),
        const _TileDivider(),
        ListTile(
          dense: true,
          leading: Icon(
            isPro ? Icons.block : Icons.campaign_outlined,
            size: 22,
            color: isPro ? Colors.green : cs.onSurfaceVariant,
          ),
          title: Text(
              isPro ? l.settingsAdsRemoved : l.settingsAdsFreeNotice,
              style: TextStyle(
                  fontSize: 13,
                  color: isPro ? null : cs.onSurfaceVariant)),
        ),
      ],
    );
  }
}

// ── About section ───────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  final String appVersion;
  const _AboutSection({required this.appVersion});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.info_outline, size: 22, color: cs.primary),
          title:    Text(l.homeAppTitle),
          subtitle: Text(
              l.settingsAppVersion(appVersion.isEmpty ? '…' : appVersion)),
        ),
        const _TileDivider(),
        _NavTile(
          icon: Icons.gavel_outlined,
          title: l.settingsLegalNotice,
          onTap: () =>
              _launchUrl('https://iptvaiplayer.com.tr/index.php'),
        ),
        const _TileDivider(),
        _NavTile(
          icon: Icons.delete_outline,
          title: l.settingsDataDeletion,
          subtitle: l.settingsDataDeletionSubtitle,
          onTap: () =>
              _launchUrl('https://iptvaiplayer.com.tr/verisilme.php'),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ── Tile primitives ─────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback onTap;
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, size: 22, color: cs.primary),
      title:    Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(trailingText!,
                style: TextStyle(
                    fontSize: 13, color: cs.onSurfaceVariant)),
            const SizedBox(width: 4),
          ],
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;
  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, size: 22, color: cs.primary),
      title:   Text(title),
      trailing: DropdownButton<T>(
        value: value,
        underline: const SizedBox.shrink(),
        icon: Icon(Icons.arrow_drop_down, color: cs.onSurfaceVariant),
        items: items.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

// ── PiP auto-mode tile (Pro gating) ─────────────────────────────────────────

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
    final cs = Theme.of(context).colorScheme;
    if (!_loaded) {
      return const ListTile(title: SizedBox(height: 24));
    }
    return SwitchListTile(
      secondary: Icon(Icons.picture_in_picture_alt,
          size: 22, color: cs.primary),
      title:    Text(l.settingsPipAuto),
      subtitle: Text(l.settingsPipAutoSubtitle,
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_circle, size: 14, color: cs.primary),
                const SizedBox(width: 4),
              ],
              Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Picker helpers ──────────────────────────────────────────────────────────

String _localeLabel(AppLocalizations l, Locale? locale) {
  switch (locale?.languageCode) {
    case 'tr': return l.languageTurkish;
    case 'en': return l.languageEnglish;
    case 'de': return l.languageGerman;
    case 'ar': return l.languageArabic;
    default:   return l.languageSystem;
  }
}

Future<void> _showThemePicker(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l,
) async {
  final current = ref.read(themeModeProvider);
  await showDialog<void>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(l.settingsAppearanceSection),
      children: [
        RadioListTile<ThemeMode>(
          title: Text(l.settingsThemeDark),
          value: ThemeMode.dark,
          groupValue: current,
          onChanged: (v) {
            ref.read(themeModeProvider.notifier).setMode(v!);
            Navigator.of(ctx).pop();
          },
        ),
        RadioListTile<ThemeMode>(
          title: Text(l.settingsThemeLight),
          value: ThemeMode.light,
          groupValue: current,
          onChanged: (v) {
            ref.read(themeModeProvider.notifier).setMode(v!);
            Navigator.of(ctx).pop();
          },
        ),
        RadioListTile<ThemeMode>(
          title: Text(l.settingsThemeSystem),
          value: ThemeMode.system,
          groupValue: current,
          onChanged: (v) {
            ref.read(themeModeProvider.notifier).setMode(v!);
            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
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
            title: Text(label),
            value: loc?.languageCode,
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
