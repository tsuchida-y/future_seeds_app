import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  //DartとSwift間で通信するためのチャネル
  private var mapsChannel: FlutterMethodChannel?
  
  //アプリ起動時の初期化処理
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 先にプラグインを登録(Firebase,位置情報など)
    GeneratedPluginRegistrant.register(with: self)
    
    // FlutterViewControllerの取得
    //Flutterの画面コントローラーを取得
    guard let controller = window?.rootViewController as? FlutterViewController else {
      print("❌ エラー: FlutterViewControllerが見つかりません")
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MethodChannelの設定
    mapsChannel = FlutterMethodChannel(
      name: "com.futureseeds.app/config",
      binaryMessenger: controller.binaryMessenger     //通信メッセンジャー
    )
    
    // MethodCallハンドラの設定
    //Dartからメソッドが呼ばれた時の処理を設定
    mapsChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      self?.handleMethodCall(call: call, result: result)
    }
    
    print("✅ AppDelegate: MethodChannel設定完了")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MethodCallの処理
  private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getGoogleMapsApiKey":

      // 引数からAPIキーを取得
      if let args = call.arguments as? [String: Any],
         let apiKey = args["apiKey"] as? String {
        
        // APIキーのバリデーション
        if apiKey.isEmpty {
          print("❌ エラー: APIキーが空です")
          //Dart側にエラーを返す
          result(FlutterError(
            code: "EMPTY_API_KEY",
            message: "Google Maps APIキーが空です。.envファイルを確認してください。",
            details: nil
          ))
          return
        }
        
        // GoogleMapsSDKにAPIキーを設定
        GMSServices.provideAPIKey(apiKey)
        print("✅ Google Maps APIキー設定完了: \(apiKey.prefix(10))...")
        result(true)
        
      } else {
        print("❌ エラー: APIキーの取得に失敗")
        result(FlutterError(
          code: "INVALID_ARGUMENT",
          message: "APIキーが不正です",
          details: nil
        ))
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}