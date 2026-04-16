import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

/// Tam yasal bildirim ekrani.
/// Disclaimer / Settings'ten ulasilir; blokaj ekrani DEGIL.
class LegalNoticeScreen extends StatelessWidget {
  const LegalNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Legal Notice / Yasal Bildirim'),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: Responsive.formMaxWidth(context),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('1. Nature of the App / Uygulamanin Niteligi'),
                _sectionBody(
                  'IPTV AI Player is a general-purpose media player (similar '
                  'to VLC or MX Player). It does NOT provide, host, '
                  'distribute, or redirect to any TV broadcasts, movies, '
                  'series, sports events, or other content. The app is a '
                  'tool that plays M3U / M3U8 playlist URLs or Xtream Codes '
                  'credentials supplied by the user.',
                ),
                const SizedBox(height: 8),
                _sectionBody(
                  'IPTV AI Player, genel amacli bir medya oynaticidir '
                  '(VLC, MX Player benzeri). Herhangi bir televizyon '
                  'yayini, film, dizi veya icerik SAGLAMAZ, BARINDIRMAZ, '
                  'DAGITMAZ. Uygulama, kullanicinin kendi temin ettigi '
                  'oynatma listesi URL\'lerini veya Xtream Codes '
                  'kimlik bilgilerini oynatir.',
                ),

                _sectionTitle('2. Content Responsibility / Icerik Sorumlulugu'),
                _sectionBody(
                  'The user is solely responsible for all content accessed '
                  'via the app. The developer has no knowledge of and bears '
                  'no responsibility for content accessed through the app.',
                ),
                const SizedBox(height: 8),
                _sectionBody(
                  'Uygulama uzerinden erisilen TUM iceriklerden yalnizca '
                  'KULLANICI sorumludur. Gelistirici, kullanicilarin '
                  'uygulamayi kullanarak eristikleri icerikler hakkinda '
                  'hicbir bilgiye sahip degildir.',
                ),

                _warningBox([
                  '5846 sayili FSEK madde 71-72: Telif hakki ihlali hukuki ve cezai yaptirim.',
                  'TCK madde 163/2: Sifreli/sifresiz yayinlarin izinsiz kullanimi.',
                  'FSEK Ek Madde 4: Internet ortaminda telif ihlali.',
                  'RTUK ve BTK, 6112 ve 5651 sayili Kanunlar kapsaminda erisim engellemesi uygulayabilir.',
                ]),

                _sectionTitle('4. User Obligations / Kullanici Yukumlulukleri'),
                _sectionBody(
                  'By using this app you acknowledge that you will only '
                  'access content you are legally subscribed to, you will '
                  'not access copyrighted content without permission, and '
                  'you will not use the app for pirated broadcasts or '
                  'unlicensed IPTV services.',
                ),

                _sectionTitle('5. Data Protection / KVKK'),
                _sectionBody(
                  'The app stores your playlist URLs and credentials only '
                  'locally on your device. They are not shared with third '
                  'parties. / Uygulama, girdiginiz oynatma listesi URL '
                  've kimlik bilgilerini yalnizca cihazinizda yerel olarak '
                  'saklar.',
                ),

                _sectionTitle('6. Limitation of Liability / Sorumluluk Sinirlamasi'),
                _sectionBody(
                  'The app is provided "AS IS". The developer is not liable '
                  'for any damages arising from the use of the app. / '
                  'Uygulama "OLDUGU GIBI" sunulmaktadir. Gelistirici, '
                  'uygulamanin kullanimindan kaynaklanan hicbir zarardan '
                  'sorumlu degildir.',
                ),

                _sectionTitle('7. Legal Cooperation / Yasal Isbirligi'),
                _sectionBody(
                  'The developer complies with lawful requests from '
                  'competent authorities (RTUK, BTK, prosecutors). / '
                  'Gelistirici, yetkili makamlarin (RTUK, BTK, Savciliklar) '
                  'yasal taleplerine uyum saglar.',
                ),

                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Reminder: Using this app to access unauthorized / '
                    'copyrighted content is illegal. The user bears full '
                    'legal responsibility.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
      );

  Widget _sectionBody(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.5,
          color: Colors.white70,
        ),
      );

  Widget _warningBox(List<String> items) => Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.info_outline, size: 18, color: Colors.red.shade300),
                const SizedBox(width: 8),
                Text(
                  '3. Turkiye Yasal Cercevesi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade300,
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red.shade300,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      );
}
