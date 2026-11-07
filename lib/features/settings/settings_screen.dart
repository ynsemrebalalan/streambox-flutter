import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/settings_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/data/auth_state.dart';
import '../auth/providers/auth_providers.dart';
import '../billing/providers/purchases_providers.dart';
import '../billing/widgets/paywall_trigger.dart';
import '../billing/widgets/paywall_widgets.dart';
import '../cloud_sync/widgets/cloud_sync_tile.dart';
import '../epg/widgets/epg_auto_refresh_tile.dart';
import '../onboarding/legal_notice_screen.dart';
import '../other_apps/other_apps_screen.dart';
import 'logic/locale_label.dart';
import 'services/review_service.dart';
import 'widgets/ai_player_settings.dart';
import 'widgets/feedback_dialog.dart';
import 'widgets/settings_data_tiles.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class SettingsState {
  final String openAiApiKey;
  final String openAiLanguage;
  final String groqProxyUrl;
  final String groqProxySecret;
  final bool   isSaving;
  final String subtitleFontSize;
  final String subtitleTextColor;
  final String subtitleBgColor;

  const SettingsState({
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
    String? openAiApiKey,
    String? openAiLanguage,
    String? groqProxyUrl,
    String? groqProxySecret,
    bool?   isSaving,
    String? subtitleFontSize,
    String? subtitleTextColor,
    String? subtitleBgColor,
  }) => SettingsState(
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
      openAiApiKey:     all[SettingsKeys.openAiApiKey]     ?? '',
      openAiLanguage:   all[SettingsKeys.openAiLanguage]   ?? '',
      groqProxyUrl:     all[SettingsKeys.groqProxyUrl]     ?? '',
      groqProxySecret:  all[SettingsKeys.groqProxySecret]  ?? '',
      subtitleFontSize:  all[SettingsKeys.subtitleFontSize]  ?? '16',
      subtitleTextColor: all[SettingsKeys.subtitleTextColor] ?? 'white',
      subtitleBgColor:   all[SettingsKeys.subtitleBgColor]   ?? 'semi',
    );
  }

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
      data: (state) => _buildScaffold(context, state),
    );
  }

  Widget _buildScaffold(BuildContext context, SettingsState state) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title:   Text(l.settingsTitle),
        // Diger ekranlarla tutarli: geri = pop. Yigin yoksa (deep link /
        // context.go ile gelindiyse) Home'a dus.
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.home),
        ),
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
            _GroupedCard(children: const [_EpgSection()]),

            _SectionLabel(text: l.settingsSubtitleSection),
            _GroupedCard(children: [_SubtitleSection(state: state)]),

            _SectionLabel(text: l.settingsAiSection),
            _GroupedCard(children: const [AiSubtitleSettingsSection()]),

            _SectionLabel(text: l.settingsPlayerSection),
            _GroupedCard(children: const [_PlayerSection()]),

            _SectionLabel(text: l.settingsSupportSection),
            _GroupedCard(children: const [_SupportSection()]),

            _SectionLabel(text: l.settingsAboutSection),
            _GroupedCard(children: [_AboutSection(appVersion: _appVersion)]),
          ],
        ),
      ),
    );
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
                        ? [cs.tertiary, cs.primary]
                        : [cs.primary, cs.tertiary],
                  ),
                ),
                alignment: Alignment.center,
                child: initial != null
                    ? Text(initial,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: cs.onPrimary))
                    : Icon(Icons.person_outline,
                        size: 26, color: cs.onPrimary),
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
                          color: isPro ? cs.primary : cs.onSurfaceVariant,
                          fontWeight: isPro ? FontWeight.w600 : null),
                    ),
                  ],
                ),
              ),
              if (!isPro)
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
              // Tema rol cifti (tertiaryContainer / onTertiaryContainer) M3'te
              // AA kontrastli; sabit amber premium temalarda okunmuyordu.
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'PRO',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: cs.onTertiaryContainer),
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
        // Tema tile'i `_AppearanceSection` icinde — burada duplicate'a son.
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
        const _TileDivider(),
        const PlaylistAutoRefreshTile(),
        const _TileDivider(),
        const ClearWatchHistoryTile(),
      ],
    );
  }
}

// ── Appearance section (Theme + Language) ───────────────────────────────────
//
// 2026-05-25: Tema secimi tek source-of-truth oldu (themeVariantProvider).
// Eskiden burada ayri "Gorunum (light/dark/system)" dialog'u vardi ve tam
// sayfa ThemePicker ile catisiyordu — "tema gecisleri pasif" raporunun
// koku buydu. Artik tek "Tema" tile'i dogrudan ThemePicker'a yonlendirir.

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final variant = ref.watch(themeVariantProvider);
    final variantLabel = _themeVariantLabel(l, variant);

    return Column(
      children: [
        _NavTile(
          icon: _themeVariantIcon(variant),
          title: l.themePickerTitle,
          trailingText: variantLabel,
          onTap: () => context.push(AppRoutes.themePicker),
        ),
        const _TileDivider(),
        _NavTile(
          icon: Icons.language,
          title: l.language,
          trailingText: localeLabel(l, ref.watch(localeProvider)),
          onTap: () => _showLanguagePicker(context, ref, l),
        ),
      ],
    );
  }

  static IconData _themeVariantIcon(PremiumTheme v) => switch (v) {
    PremiumTheme.defaultSystem => Icons.brightness_auto_outlined,
    PremiumTheme.defaultLight  => Icons.light_mode_outlined,
    PremiumTheme.defaultDark   => Icons.dark_mode_outlined,
    _                          => Icons.color_lens_outlined,
  };

  static String _themeVariantLabel(AppLocalizations l, PremiumTheme v) =>
      switch (v) {
    PremiumTheme.defaultSystem => l.settingsThemeSystem,
    PremiumTheme.defaultLight  => l.themeDefaultLight,
    PremiumTheme.defaultDark   => l.themeDefaultDark,
    PremiumTheme.crimson       => l.themeCrimson,
    PremiumTheme.royal         => l.themeRoyal,
    PremiumTheme.forest        => l.themeForest,
    PremiumTheme.ocean         => l.themeOcean,
  };
}

// ── EPG section ─────────────────────────────────────────────────────────────

class _EpgSection extends StatelessWidget {
  const _EpgSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        const EpgUrlEditor(),
        const _TileDivider(),
        _NavTile(
          icon: Icons.live_tv,
          title: l.epgGuideTitle,
          onTap: () => context.push(AppRoutes.epgGuide),
        ),
        const _TileDivider(),
        const EpgAutoRefreshTile(),
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
        const _TileDivider(),
        const SubtitleDefaultOnTile(),
      ],
    );
  }
}

// ── Player section ──────────────────────────────────────────────────────────

/// 2026-08-29: "Free surumde banner reklam gorunur / Pro ile reklamsiz"
/// bilgi satiri KALDIRILDI — AdMob uygulamadan tamamen cikarildi, artik
/// hicbir kullaniciya reklam gosterilmiyor. Ilgili l10n anahtarlari
/// (`settingsAdsFreeNotice`, `settingsAdsRemoved`) reklam geri gelirse diye
/// arb dosyalarinda birakildi.
class _PlayerSection extends StatelessWidget {
  const _PlayerSection();

  @override
  Widget build(BuildContext context) {
    // iOS'ta PiP çalışmıyor (media_kit texture render) → ayar gizli.
    final showPip = defaultTargetPlatform != TargetPlatform.iOS;
    return Column(
      children: [
        const BufferDurationTile(),
        if (showPip) ...[
          const _TileDivider(),
          const _PipAutoTile(),
        ],
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
        // Diğer uygulamalar (liste daveddeva.com/apps.json'dan gelir).
        // selfPackage sitedeki Android paket adıdır (iOS bundle id'si farklı).
        _NavTile(
          icon: Icons.apps_rounded,
          title: l.otherAppsTitle,
          subtitle: l.otherAppsSubtitle,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OtherAppsScreen(
                selfPackage: 'com.streambox.app',
                lang: Localizations.localeOf(context).languageCode,
              ),
            ),
          ),
        ),
        const _TileDivider(),
        // Apple 5.1.1(i): Gizlilik + Kullanim Sartlari her zaman erisilebilir.
        // URL'ler Android SettingsScreen ile ayni.
        _NavTile(
          icon: Icons.privacy_tip_outlined,
          title: l.paywallPrivacyLink,
          onTap: () => openExternalUrl(LegalUrls.privacy),
        ),
        const _TileDivider(),
        _NavTile(
          icon: Icons.description_outlined,
          title: l.paywallTermsLink,
          onTap: () => openExternalUrl(LegalUrls.terms),
        ),
        const _TileDivider(),
        _NavTile(
          icon: Icons.gavel_outlined,
          title: l.settingsLegalNotice,
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const LegalNoticeScreen())),
        ),
        const _TileDivider(),
        _NavTile(
          icon: Icons.delete_outline,
          title: l.settingsDataDeletion,
          subtitle: l.settingsDataDeletionSubtitle,
          onTap: () => openExternalUrl(LegalUrls.dataDeletion),
        ),
      ],
    );
  }
}

// ── Support section (geri bildirim + degerlendirme) ────────────────────────

class _SupportSection extends StatelessWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        _NavTile(
          icon: Icons.feedback_outlined,
          title: l.settingsFeedbackTitle,
          subtitle: l.settingsFeedbackSubtitle,
          onTap: () => showFeedbackDialog(context),
        ),
        const _TileDivider(),
        _NavTile(
          icon: Icons.star_outline,
          title: l.settingsRateApp,
          subtitle: l.settingsRateAppSubtitle,
          onTap: PlaybackMilestones.openStoreListing,
        ),
      ],
    );
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

// ── Picker helpers ──────────────────────────────────────────────────────────

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
    (const Locale('it'),   l.languageItalian),
    (const Locale('es'),   l.languageSpanish),
    (const Locale('ro'),   l.languageRomanian),
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
