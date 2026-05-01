import 'package:flutter/material.dart';

/// Kategori adından tür-özel Material Icon eşleştirmesi.
/// Android `CategoryIcons.kt:mapCategoryToIcon` ile birebir aynı liste —
/// iki platformun aynı genre'lere aynı ikonları göstermesi için merkezi tutulmalı.
///
/// [streamType] fallback: kategori adı hiçbir keyword'le eşleşmezse kullanılır.
IconData mapCategoryToIcon(String name, {String? streamType}) {
  final n = name
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('ç', 'c')
      .replaceAll('ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o');

  // Spor
  if (n.contains('spor') ||
      n.contains('sport') ||
      n.contains('futbol') ||
      n.contains('basket') ||
      n.contains('mac')) {
    return Icons.sports_soccer;
  }
  // Haber
  if (n.contains('haber') ||
      n.contains('news') ||
      n.contains('gundem') ||
      n.contains('politika')) {
    return Icons.newspaper;
  }
  // Çocuk / Animasyon
  if (n.contains('cocuk') ||
      n.contains('kids') ||
      n.contains('baby') ||
      n.contains('kid') ||
      n.contains('cartoon') ||
      n.contains('anime') ||
      n.contains('animasyon')) {
    return Icons.child_care;
  }
  // Müzik
  if (n.contains('muzik') ||
      n.contains('music') ||
      n.contains('mtv') ||
      n.contains('kral') ||
      n.contains('power')) {
    return Icons.music_note;
  }
  // Belgesel
  if (n.contains('belgesel') ||
      n.contains('documentary') ||
      n.contains('discovery') ||
      n.contains('nat geo') ||
      n.contains('national')) {
    return Icons.menu_book;
  }
  // Bilim
  if (n.contains('bilim') || n.contains('science')) {
    return Icons.science;
  }
  // Doğa / Hayvan
  if (n.contains('doga') ||
      n.contains('nature') ||
      n.contains('hayvan') ||
      n.contains('animal')) {
    return Icons.travel_explore;
  }
  // Yemek / Yaşam
  if (n.contains('yemek') || n.contains('food') || n.contains('gurme')) {
    return Icons.favorite;
  }
  // Seyahat / Keşif
  if (n.contains('seyahat') ||
      n.contains('travel') ||
      n.contains('gezi') ||
      n.contains('kesif')) {
    return Icons.explore;
  }
  // Oyun
  if (n.contains('oyun') ||
      n.contains('game') ||
      n.contains('gaming') ||
      n.contains('esport')) {
    return Icons.videogame_asset;
  }
  // Eğitim
  if (n.contains('egitim') ||
      n.contains('education') ||
      n.contains('okul') ||
      n.contains('ders')) {
    return Icons.school;
  }
  // Dini
  if (n.contains('dini') ||
      n.contains('dinler') ||
      n.contains('islam') ||
      n.contains('kuran')) {
    return Icons.menu_book;
  }
  // Komedi / Eğlence
  if (n.contains('komedi') ||
      n.contains('comedy') ||
      n.contains('mizah') ||
      n.contains('eglence')) {
    return Icons.emoji_emotions;
  }
  // Aksiyon / Savaş
  if (n.contains('aksiyon') ||
      n.contains('action') ||
      n.contains('dovus') ||
      n.contains('savas') ||
      n.contains('war')) {
    return Icons.local_fire_department;
  }
  // Korku / Gerilim / Suç
  if (n.contains('korku') ||
      n.contains('horror') ||
      n.contains('gerilim') ||
      n.contains('thriller') ||
      n.contains('suc') ||
      n.contains('crime')) {
    return Icons.gavel;
  }
  // Romantik
  if (n.contains('romantik') ||
      n.contains('romance') ||
      n.contains('ask') ||
      n.contains('love')) {
    return Icons.favorite;
  }
  // Drama
  if (n.contains('drama')) {
    return Icons.theaters;
  }
  // Sinema / Film (genel)
  if (n.contains('sinema') ||
      n.contains('film') ||
      n.contains('cinema') ||
      n.contains('movie')) {
    return Icons.local_movies;
  }
  // Dizi / Series
  if (n.contains('dizi') || n.contains('series') || n.contains('show')) {
    return Icons.theaters;
  }
  // Yetişkin / 18+
  if (n.contains('yetiskin') ||
      n.contains('adult') ||
      n.contains('+18') ||
      n.contains('18+') ||
      n.contains('xxx')) {
    return Icons.nightlife;
  }
  // Bilim kurgu / Fantastik
  if (n.contains('bilim kurgu') ||
      n.contains('sci-fi') ||
      n.contains('scifi') ||
      n.contains('fantastik') ||
      n.contains('fantasy')) {
    return Icons.explore;
  }
  // Otomobil
  if (n.contains('araba') ||
      n.contains('otomobil') ||
      n.contains('auto') ||
      n.contains('motor')) {
    return Icons.directions_car;
  }
  // Moda / Sanat
  if (n.contains('moda') ||
      n.contains('fashion') ||
      n.contains('sanat') ||
      n.contains('art')) {
    return Icons.brush;
  }
  // Yerel / Ulusal
  if (n.contains('ulusal') ||
      n.contains('yerel') ||
      n.contains('bolge') ||
      n.contains('national')) {
    return Icons.public;
  }
  // Radyo
  if (n.contains('radyo') || n.contains('radio')) {
    return Icons.radio;
  }
  // Favori / Premium
  if (n.contains('favori') ||
      n.contains('favorite') ||
      n.contains('premium') ||
      n.contains('one cikan') ||
      n.contains('featured')) {
    return Icons.star;
  }

  // Stream type fallback
  switch (streamType) {
    case 'live':
      return Icons.live_tv;
    case 'movie':
      return Icons.movie;
    case 'series':
      return Icons.theaters;
    default:
      return Icons.tv;
  }
}
