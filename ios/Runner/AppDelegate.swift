import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Dartから環境変数を取得してGoogle Maps APIキーを設定
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.futureseeds.app/config",
        binaryMessenger: controller.binaryMessenger
      )
      
      channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "getGoogleMapsApiKey" {
          if let args = call.arguments as? [String: Any],
             let apiKey = args["apiKey"] as? String {
            GMSServices.provideAPIKey(apiKey)
            result(true)
          } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "API Key not provided", details: nil))
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}