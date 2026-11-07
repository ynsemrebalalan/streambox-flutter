/// Basit iptal sayacı: [capture] o anki nesli yakalar; [bump] sonrasında
/// yakalanan predicate true döner (iş iptal edildi). [bump] sonrası yeni
/// yakalamalar etkilenmez.
class CancelEpoch {
  int _epoch = 0;

  bool Function() capture() {
    final e = _epoch;
    return () => e != _epoch;
  }

  void bump() => _epoch++;
}
