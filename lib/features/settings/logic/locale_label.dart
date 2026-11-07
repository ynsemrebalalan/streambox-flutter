import 'package:flutter/widgets.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Dil secici satirinda gosterilen etiket. (Eski switch es/ro'yu atliyor ve
/// "Sistem dili" gosteriyordu.)
String localeLabel(AppLocalizations l, Locale? locale) =>
    switch (locale?.languageCode) {
      'tr' => l.languageTurkish,
      'en' => l.languageEnglish,
      'de' => l.languageGerman,
      'it' => l.languageItalian,
      'es' => l.languageSpanish,
      'ro' => l.languageRomanian,
      'ar' => l.languageArabic,
      _ => l.languageSystem,
    };
