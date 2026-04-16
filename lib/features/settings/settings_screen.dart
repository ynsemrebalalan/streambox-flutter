import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/epg_service.dart';
import '../../data/services/firebase_sync_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(settingsScreenProvider);

    return async.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error:   (e, _) => Scaffold(
          body: Center(child: Text('Hata: $e'))),
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

    return Scaffold(
      appBar: AppBar(
        title:   const Text('Ayarlar'),
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
              tooltip: 'Kaydet',
              onPressed: () async {
                await ref.read(settingsScreenProvider.notifier).save();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ayarlar kaydedildi')),
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
          _SectionHeader(title: 'Görünüm'),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title:   const Text('Koyu Tema'),
                  value:   ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).setMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title:   const Text('Açık Tema'),
                  value:   ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).setMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title:   const Text('Sistem Teması'),
                  value:   ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).setMode(v!),
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.xl),

          // ── EPG ──────────────────────────────────────────────────────────
          _SectionHeader(title: 'EPG'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                children: [
                  TextField(
                    controller: _epgCtrl,
                    decoration: const InputDecoration(
                      labelText: 'EPG URL (.xml veya .xml.gz)',
                      hintText:  'https://epg.example.com/epg.xml.gz',
                      border:    OutlineInputBorder(),
                      prefixIcon: Icon(Icons.rss_feed),
                    ),
                    onChanged: (v) =>
                        ref.read(settingsScreenProvider.notifier).setEpgUrl(v),
                  ),
                  const SizedBox(height: Spacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon:  const Icon(Icons.sync),
                      label: const Text('EPG\'yi Şimdi Güncelle'),
                      onPressed: () async {
                        // Save first
                        await ref
                            .read(settingsScreenProvider.notifier)
                            .save();
                        final activeId = ref.read(activePlaylistProvider);
                        if (activeId.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Önce bir playlist seçin')),
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
                              const SnackBar(
                                  content: Text('EPG başarıyla güncellendi')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('EPG hatası: $e')),
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

          const SizedBox(height: Spacing.xl),

          // ── AI ───────────────────────────────────────────────────────────
          _SectionHeader(title: 'Yapay Zeka'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                children: [
                  TextField(
                    controller: _openAiKeyCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'OpenAI API Key',
                      hintText:  'sk-...',
                      border:    OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                    ),
                    onChanged: (v) =>
                        ref.read(settingsScreenProvider.notifier)
                            .setOpenAiApiKey(v),
                  ),
                  const SizedBox(height: Spacing.md),
                  TextField(
                    controller: _openAiLangCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Dil (opsiyonel)',
                      hintText:  'tr, en, de… — boş bırakılırsa otomatik',
                      border:    OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                    ),
                    onChanged: (v) =>
                        ref.read(settingsScreenProvider.notifier)
                            .setOpenAiLanguage(v),
                  ),
                  const SizedBox(height: Spacing.xl),
                  TextField(
                    controller: _groqProxyUrlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Groq Proxy URL',
                      border:    OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cloud_outlined),
                    ),
                    onChanged: (v) =>
                        ref.read(settingsScreenProvider.notifier)
                            .setGroqProxyUrl(v),
                  ),
                  const SizedBox(height: Spacing.md),
                  TextField(
                    controller: _groqSecretCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Groq Proxy Secret',
                      border:    OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    onChanged: (v) =>
                        ref.read(settingsScreenProvider.notifier)
                            .setGroqProxySecret(v),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: Spacing.xl),

          // ── Subtitle Styling ────────────────────────────────────────────
          _SectionHeader(title: 'Altyazi'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: const Text('Yazi Boyutu'),
                  trailing: DropdownButton<String>(
                    value: state.subtitleFontSize,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: '14', child: Text('Kucuk')),
                      DropdownMenuItem(value: '16', child: Text('Normal')),
                      DropdownMenuItem(value: '20', child: Text('Buyuk')),
                      DropdownMenuItem(value: '24', child: Text('Cok Buyuk')),
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
                  title: const Text('Yazi Rengi'),
                  trailing: DropdownButton<String>(
                    value: state.subtitleTextColor,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'white', child: Text('Beyaz')),
                      DropdownMenuItem(value: 'yellow', child: Text('Sari')),
                      DropdownMenuItem(value: 'green', child: Text('Yesil')),
                      DropdownMenuItem(value: 'cyan', child: Text('Cyan')),
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
                  title: const Text('Arka Plan'),
                  trailing: DropdownButton<String>(
                    value: state.subtitleBgColor,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'semi', child: Text('Yari Saydam')),
                      DropdownMenuItem(value: 'opaque', child: Text('Siyah')),
                      DropdownMenuItem(value: 'none', child: Text('Yok')),
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

          // ── Cloud Sync ──────────────────────────────────────────────────
          _SectionHeader(title: 'Bulut Yedekleme'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_upload_outlined),
                  title:   const Text('Yedekle'),
                  subtitle: const Text('Playlist\'leri buluta yedekle'),
                  onTap: () async {
                    final playlists = await ref
                        .read(playlistRepoProvider)
                        .getAll();
                    try {
                      await FirebaseSyncService.uploadPlaylists(playlists);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Yedekleme tamamlandi')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Yedekleme hatasi: $e')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_download_outlined),
                  title:   const Text('Geri Yukle'),
                  subtitle: const Text('Buluttan playlist\'leri indir'),
                  onTap: () async {
                    try {
                      final playlists =
                          await FirebaseSyncService.downloadPlaylists();
                      if (playlists.isEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Bulutta yedek bulunamadi')),
                          );
                        }
                        return;
                      }
                      for (final p in playlists) {
                        await ref
                            .read(playlistRepoProvider)
                            .insert(p);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${playlists.length} playlist geri yuklendi')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Geri yukleme hatasi: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.xl),

          // ── About ────────────────────────────────────────────────────────
          _SectionHeader(title: 'Hakkında'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title:   const Text('IPTV AI Player'),
                  subtitle: Text('Sürüm 1.0.0',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title:   const Text('Playlist Yönetimi'),
                  onTap:   () => context.push(AppRoutes.playlists),
                ),
                ListTile(
                  leading: const Icon(Icons.filter_list),
                  title:   const Text('Kategori Filtresi'),
                  subtitle: const Text('Kategorileri gizle/göster'),
                  onTap:   () => context.push(AppRoutes.categoryFilter),
                ),
              ],
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
