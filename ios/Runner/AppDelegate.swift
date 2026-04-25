import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  // iOS 26 ProMotion siyah ekran + VSyncClient crash kesin cozumu:
  //
  // Flutter'in default "implicit engine" pattern'inde FlutterViewController
  // viewDidLoad icinde engine'e attach oluyor. Race condition: viewDidLoad
  // calistiginda engine.platformTaskRunner henuz hazir degil ->
  // -[VSyncClient initWithTaskRunner:callback:] null pointer alir ->
  //   iOS 26.0-26.3: EXC_BAD_ACCESS crash (v1.0.1 crashlog'lari)
  //   iOS 26.4+: sessiz siyah ekran (v1.1.4 - eski swizzle ile)
  //
  // Ref: https://github.com/flutter/flutter/issues/183900
  //      https://github.com/flutter/flutter/issues/179592
  //
  // Cozum: Explicit engine prewarm. AppDelegate'te engine'i didFinishLaunching
  // icinde .run() ile baslatiyoruz; FlutterViewController'a hazir halde
  // veriyoruz. viewDidLoad cagrildiginda task runner zaten attach olmus
  // durumda, VSyncClient sagliklica CADisplayLink aliyor, rendering loop
  // normal 60-120Hz'de akiyor. Eski no-op swizzle kaldirildi (rendering'i
  // de olduruyordu).
  lazy var flutterEngine = FlutterEngine(name: "iptv_ai_engine")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 1) Engine'i onceden baslat — plugin'ler ve task runner hazir olur.
    flutterEngine.run()

    // 2) Plugin'leri explicit engine'e register et (implicit'te self'e olurdu).
    GeneratedPluginRegistrant.register(with: flutterEngine)

    // 3) FlutterViewController'a prewarmed engine ver, window'u manuel kur.
    //    super.application cagrilmiyor; FlutterAppDelegate'in implicit
    //    window setup'i bu kurulumu ezerdi.
    let flutterViewController = FlutterViewController(
      engine: flutterEngine,
      nibName: nil,
      bundle: nil
    )
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = flutterViewController
    window?.makeKeyAndVisible()

    NSLog("[Flutter] Explicit engine prewarmed + FlutterViewController ready.")
    return true
  }
}
