import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../l10n/generated/app_localizations.dart';

/// Tam yasal bildirim ekrani.
/// Disclaimer / Settings'ten ulasilir; blokaj ekrani DEGIL.
class LegalNoticeScreen extends StatelessWidget {
  const LegalNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l.legalNoticeTitle),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: Responsive.formMaxWidth(context),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(l.legalSection1Title),
                _sectionBody(l.legalSection1En),
                const SizedBox(height: 8),
                _sectionBody(l.legalSection1Tr),

                _sectionTitle(l.legalSection2Title),
                _sectionBody(l.legalSection2En),
                const SizedBox(height: 8),
                _sectionBody(l.legalSection2Tr),

                _warningBox(l.legalSection3Title, [
                  l.legalSection3Item1,
                  l.legalSection3Item2,
                  l.legalSection3Item3,
                  l.legalSection3Item4,
                ]),

                _sectionTitle(l.legalSection4Title),
                _sectionBody(l.legalSection4Body),

                _sectionTitle(l.legalSection5Title),
                _sectionBody(l.legalSection5Body),

                _sectionTitle(l.legalSection6Title),
                _sectionBody(l.legalSection6Body),

                _sectionTitle(l.legalSection7Title),
                _sectionBody(l.legalSection7Body),

                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l.legalReminder,
                    style: const TextStyle(
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

  Widget _warningBox(String title, List<String> items) => Padding(
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
                  title,
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
