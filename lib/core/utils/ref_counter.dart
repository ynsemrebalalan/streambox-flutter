/// Global (singleton) kaynaklar icin referans sayaci.
///
/// Kanal degistirme `pushReplacement` ile yapiliyor: yeni PlayerScreen'in
/// initState'i, eski ekranin dispose'undan (~220ms fade) ONCE calisir. Sayac
/// olmadan eski dispose, yeninin actigi ses oturumunu / PiP / immersive modu
/// geri kapatiyordu. Yan etki yalniz 0->1 (acquire true) ve 1->0
/// (release true) gecislerinde yapilir.
class RefCounter {
  int _count = 0;

  int get count => _count;
  bool get isActive => _count > 0;

  /// true = ilk sahip (kaynagi simdi ac).
  bool acquire() {
    _count++;
    return _count == 1;
  }

  /// true = son sahip birakti (kaynagi simdi kapat). Sifirin altina inmez.
  bool release() {
    if (_count == 0) return false;
    _count--;
    return _count == 0;
  }
}

/// Ref-counted giris/cikis: ilk acquire'da [onEnter], son release'de
/// [onRestore]. Platform cagrilarindan bagimsiz test edilebilir.
class PlayerSystemUiController {
  PlayerSystemUiController({required this.onEnter, required this.onRestore});

  final void Function() onEnter;
  final void Function() onRestore;
  final RefCounter _counter = RefCounter();

  bool get isActive => _counter.isActive;

  void acquire() {
    if (_counter.acquire()) onEnter();
  }

  void release() {
    if (_counter.release()) onRestore();
  }
}
