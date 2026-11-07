/// EPG rehber grid geometrisi (saf, testli).
class GuideLayout {
  /// Dakika başına piksel — blok genişliği süreyle orantılı.
  final double pxPerMinute;
  final int windowStartMs;
  final int windowEndMs;

  const GuideLayout({
    required this.windowStartMs,
    required this.windowEndMs,
    this.pxPerMinute = 4,
  });

  double get totalWidth => (windowEndMs - windowStartMs) / 60000 * pxPerMinute;

  double offsetOf(int ms) =>
      (ms.clamp(windowStartMs, windowEndMs) - windowStartMs) / 60000 * pxPerMinute;

  /// Programın pencereye kırpılmış (left, width) değeri; pencere dışıysa null.
  (double, double)? block(int startMs, int stopMs) {
    if (stopMs <= windowStartMs || startMs >= windowEndMs || stopMs <= startMs) {
      return null;
    }
    final left = offsetOf(startMs);
    final width = offsetOf(stopMs) - left;
    return width <= 0 ? null : (left, width);
  }

  /// 30 dakikalık zaman çizgileri (ms).
  List<int> ticks({int stepMinutes = 30}) {
    final step = stepMinutes * 60000;
    final first = (windowStartMs + step - 1) ~/ step * step;
    return [for (var t = first; t < windowEndMs; t += step) t];
  }

  /// "Şimdi" çizgisi konumu; pencere dışıysa null.
  double? nowOffset(int nowMs) =>
      nowMs < windowStartMs || nowMs > windowEndMs ? null : offsetOf(nowMs);
}
