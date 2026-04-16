import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/settings_repository.dart';

final disclaimerAcceptedProvider = FutureProvider<bool>((ref) async {
  final val = await ref.read(settingsRepoProvider).get(SettingsKeys.disclaimerAccepted);
  return val == 'true';
});

class DisclaimerScreen extends ConsumerStatefulWidget {
  final VoidCallback onAccepted;
  const DisclaimerScreen({super.key, required this.onAccepted});

  @override
  ConsumerState<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends ConsumerState<DisclaimerScreen> {
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _canAccept = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        if (!_canAccept) setState(() => _canAccept = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// D-pad ile scroll yapar. TV kumandalarinda ok tuslariyla sayfa asagi/yukari.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    const scrollAmount = 80.0;

    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.channelDown) {
      _scrollController.animateTo(
        (_scrollController.offset + scrollAmount)
            .clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.channelUp) {
      _scrollController.animateTo(
        (_scrollController.offset - scrollAmount)
            .clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
      return KeyEventResult.handled;
    }
    // Page down/up icin buyuk adim
    if (key == LogicalKeyboardKey.pageDown) {
      _scrollController.animateTo(
        (_scrollController.offset + 300)
            .clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageUp) {
      _scrollController.animateTo(
        (_scrollController.offset - 300)
            .clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
      return KeyEventResult.handled;
    }
    // Enter/Select → accept butonunu tetikle (sadece canAccept ise)
    if (_canAccept &&
        (key == LogicalKeyboardKey.select ||
         key == LogicalKeyboardKey.enter ||
         key == LogicalKeyboardKey.numpadEnter ||
         key == LogicalKeyboardKey.gameButtonA)) {
      _accept();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _accept() async {
    await ref
        .read(settingsRepoProvider)
        .set(SettingsKeys.disclaimerAccepted, 'true');
    widget.onAccepted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: SafeArea(
        child: ResponsiveCenter(
          maxWidth: Responsive.formMaxWidth(context),
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header
              Row(children: [
                Icon(Icons.play_circle_outline, size: 36, color: AppColors.accent),
                const SizedBox(width: 10),
                const Text('IPTV AI Player',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.gavel, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Text('Yasal Sorumluluk Reddi Beyanı',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accent)),
              ]),
              const SizedBox(height: 12),

              // D-pad ipucu
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.keyboard_arrow_down,
                      size: 14, color: Colors.white30),
                  const SizedBox(width: 4),
                  Text('Kumandayla okuyun',
                      style: TextStyle(fontSize: 10, color: Colors.white30)),
                ],
              ),
              const SizedBox(height: 4),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('1. Uygulamanın Niteliği'),
                      _sectionBody(
                        'IPTV AI Player, yalnızca bir medya oynatıcı uygulamadır (VLC, MX Player benzeri). '
                        'Herhangi bir televizyon yayını, film, dizi, spor müsabakası veya diğer içerikleri '
                        'SAĞLAMAZ, BARINDIRMAZ, DAĞITMAZ veya YÖNLENDİRMEZ. Uygulama, kullanıcının kendi '
                        'temin ettiği M3U/M3U8 oynatma listesi URL\'lerini veya Xtream Codes kimlik bilgilerini '
                        'oynatmak için tasarlanmış genel amaçlı bir araçtır.',
                      ),

                      _sectionTitle('2. İçerik Sorumluluğu'),
                      _sectionBody(
                        'Uygulama üzerinden erişilen TÜM içeriklerden yalnızca KULLANICI sorumludur. '
                        'Geliştirici, kullanıcıların uygulamayı kullanarak eriştikleri içerikler hakkında '
                        'hiçbir bilgiye sahip değildir ve bu içeriklerden hiçbir şekilde sorumlu tutulamaz.',
                      ),

                      _warningBox([
                        '5846 sayılı FSEK madde 71-72: Telif hakkı ihlali 1-5 yıl hapis veya adli para cezası.',
                        'TCK madde 163/2: Şifreli/şifresiz yayınların izinsiz kullanımı 6 ay-2 yıl hapis. Re\'sen soruşturulur.',
                        'FSEK Ek Madde 4: İnternet ortamında telif ihlali 3 ay-2 yıl hapis.',
                        'RTÜK, 6112 sayılı Kanun kapsamında erişim engellemesi ve idari para cezası uygulayabilir.',
                        'BTK, 5651 sayılı Kanun kapsamında içeriğe erişimi engelleyebilir.',
                      ]),

                      _sectionTitle('4. Kullanıcı Yükümlülükleri'),
                      _sectionBody('Bu uygulamayı kullanarak aşağıdaki hususları kabul ve taahhüt edersiniz:'),
                      ...[
                        'Yalnızca yasal olarak abone olduğunuz içeriklere erişeceğinizi,',
                        'Telif hakkıyla korunan içeriklere izinsiz erişmeyeceğinizi,',
                        'Uygulamayı korsan yayın veya lisanssız IPTV hizmeti için kullanmayacağınızı,',
                        'Türkiye Cumhuriyeti kanunlarına uyacağınızı,',
                        'Yasadışı kullanımdan doğacak tüm hukuki sorumluluğun size ait olduğunu,',
                        'İçerik sağlayıcınızın geçerli lisansa sahip olduğunu doğrulamanın sizin sorumluluğunuzda olduğunu.',
                      ].map((t) => _bulletItem(t)),

                      _sectionTitle('5. Kişisel Verilerin Korunması (KVKK)'),
                      _sectionBody(
                        '6698 sayılı KVKK kapsamında: Uygulama, girdiğiniz oynatma listesi URL\'leri ve '
                        'kimlik bilgilerini yalnızca cihazınızda yerel olarak saklar. Üçüncü taraflarla paylaşılmaz.',
                      ),

                      _sectionTitle('6. Sorumluluk Sınırlaması'),
                      _sectionBody(
                        'Geliştirici, bu uygulamanın kullanımından kaynaklanan hiçbir zarardan sorumlu değildir. '
                        'Uygulama \'OLDUĞU GİBİ\' sunulmaktadır.',
                      ),

                      _sectionTitle('7. Yasal İşbirliği'),
                      _sectionBody(
                        'Geliştirici, yetkili makamların (RTÜK, BTK, Savcılıklar) yasal taleplerine eksiksiz uyum sağlar.',
                      ),

                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.white70),
                            children: [
                              TextSpan(
                                text: 'SON UYARI: ',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade300),
                              ),
                              const TextSpan(
                                text: 'Bu uygulamayı yasadışı içeriklere erişmek için kullanmanız durumunda, '
                                    'FSEK ve TCK kapsamında hapis cezası dahil ağır yaptırımlarla karşılaşabilirsiniz. '
                                    'Tüm sorumluluk kullanıcıya aittir.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_canAccept)
                        Center(
                          child: Text('Devam etmek için lütfen tüm metni okuyun ↓',
                              style: TextStyle(fontSize: 12, color: Colors.white38)),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Accept button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  autofocus: false,
                  onPressed: _canAccept ? _accept : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _canAccept
                        ? 'Okudum, Anladım ve Kabul Ediyorum'
                        : 'Asagi ok ile metni okuyun ↓',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 6),
              Text('Devam ederek yukarıdaki tüm şartları kabul etmiş olursunuz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.white38)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accent)),
      );

  Widget _sectionBody(String text) =>
      Text(text, style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.white70));

  Widget _bulletItem(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('• ', style: TextStyle(fontSize: 13, color: AppColors.accent)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.white70))),
        ]),
      );

  Widget _warningBox(List<String> items) => Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.warning, size: 18, color: Colors.red.shade300),
                const SizedBox(width: 8),
                Text('3. Türk Hukuku Kapsamında Önemli Uyarı',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red.shade300)),
              ]),
              const SizedBox(height: 10),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('• ', style: TextStyle(fontSize: 13, color: Colors.red.shade300)),
                      Expanded(child: Text(item, style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.white70))),
                    ]),
                  )),
            ],
          ),
        ),
      );
}
