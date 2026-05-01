/// Hazır EPG (TV Rehberi) kaynakları — settings ekranından "preset" butonu olarak gösterilir.
///
/// Kullanıcının EPG URL'sini elle yazmak yerine, bilinen Türkiye XMLTV
/// kaynaklarından birini tek tıkla doldurmasını sağlar. Liste zamanla
/// büyüyebilir; her giriş `(label, url)` çifti.
///
/// Android tarafındaki `TURKISH_EPG_PRESETS` ile birebir aynı liste —
/// iki platformun parite içinde kalması için merkezi tutulmalı.
class EpgPreset {
  final String label;
  final String url;
  const EpgPreset(this.label, this.url);
}

const List<EpgPreset> kTurkishEpgPresets = <EpgPreset>[
  EpgPreset('EPGShare01 TR', 'https://epgshare01.online/epgshare01/epg_ripper_TR1.xml.gz'),
  EpgPreset('Open-EPG TR',  'https://www.open-epg.com/turkey.xml'),
  EpgPreset('XMLTV.ch TR',  'https://xmltv.ch/xmltv/xmltv-tr.xml'),
];
