import 'package:flutter/services.dart';

import '../../../core/utils/ref_counter.dart';

/// Player'in sistem UI (immersive) ve yon kilidi yonetimi — ref-counted.
///
/// Kanal degisiminde (pushReplacement) yeni player immersive moda girer,
/// ardindan eski player'in dispose'u calisir. Geri yukleme (edgeToEdge +
/// serbest yon) yalnizca SON player birakinca yapilir.
class PlayerSystemUi {
  PlayerSystemUi._();

  static final PlayerSystemUiController _controller = PlayerSystemUiController(
    onEnter: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    onRestore: () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // Bos liste = Info.plist ne diyorsa (iPad multitasking kurali).
      SystemChrome.setPreferredOrientations(const []);
    },
  );

  static bool get isActive => _controller.isActive;

  static void acquire() => _controller.acquire();

  static void release() => _controller.release();
}
