import Flutter
import UIKit
import ObjectiveC.runtime

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // iOS 26.0+ ProMotion siyah ekran guard'i — Flutter engine'in
    // -[FlutterViewController createTouchRateCorrectionVSyncClientIfNeeded]
    // metodu iOS 26.4.1 + ProMotion kombinasyonunda null CADisplayLink
    // donuyor. 3.27'de crash, 3.32.4'te sessiz siyah ekran. iOS 26+'da
    // metodu no-op'a ceviriyoruz; rendering 60Hz'de sorunsuz akiyor.
    //
    // Info.plist'ten de CADisableMinimumFrameDurationOnPhone kaldirildi;
    // bu swizzle ikinci savunma hatti (farkli bir build flag bu metodu
    // baska bir yoldan tetiklerse korur).
    AppDelegate.installVSyncClientGuardIfNeeded()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private static let guardInstallOnce: Void = {
    if #available(iOS 26.0, *) {
      let selector = NSSelectorFromString("createTouchRateCorrectionVSyncClientIfNeeded")
      guard let klass = NSClassFromString("FlutterViewController") as? NSObject.Type,
            let method = class_getInstanceMethod(klass, selector) else {
        NSLog("[VSyncGuard] FlutterViewController.createTouchRateCorrectionVSyncClientIfNeeded not found; skipping swizzle.")
        return
      }
      let noop: @convention(block) (AnyObject) -> Void = { _ in
        NSLog("[VSyncGuard] Skipped createTouchRateCorrectionVSyncClientIfNeeded on iOS 26+ to avoid black screen.")
      }
      let imp = imp_implementationWithBlock(noop)
      method_setImplementation(method, imp)
      NSLog("[VSyncGuard] Installed no-op for createTouchRateCorrectionVSyncClientIfNeeded on iOS 26+.")
    }
  }()

  private static func installVSyncClientGuardIfNeeded() {
    _ = guardInstallOnce
  }
}
