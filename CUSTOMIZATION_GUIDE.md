# アプリ設定とカスタマイズガイド

## アプリ名とアイコンの変更

### アプリ名の変更

#### Android
`android/app/src/main/AndroidManifest.xml`を編集:
```xml
<application
    android:label="Future Seeds"  <!-- ここを変更 -->
```

#### iOS
`ios/Runner/Info.plist`を編集:
```xml
<key>CFBundleDisplayName</key>
<string>Future Seeds</string>  <!-- ここを変更 -->
```

### アプリアイコンの変更

1. アイコン画像を準備（1024x1024px推奨）
2. [App Icon Generator](https://appicon.co/)などのツールで各サイズを生成
3. 生成されたアイコンを配置:
   - Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

または、`flutter_launcher_icons`パッケージを使用:

```yaml
# pubspec.yaml に追加
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
```

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## カラーテーマのカスタマイズ

`lib/main.dart`のテーマ設定を編集:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4CAF50), // メインカラーを変更
    brightness: Brightness.light,
  ),
  // その他のテーマ設定...
)
```

### おすすめの配色

```dart
// 温かみのある緑（デフォルト）
seedColor: const Color(0xFF4CAF50)

// 優しいブルー
seedColor: const Color(0xFF42A5F5)

// 明るいオレンジ
seedColor: const Color(0xFFFF9800)
```

## フォントのカスタマイズ

### Google Fontsを使用する場合

1. `pubspec.yaml`に追加:
```yaml
dependencies:
  google_fonts: ^6.1.0
```

2. `lib/main.dart`で使用:
```dart
import 'package:google_fonts/google_fonts.dart';

theme: ThemeData(
  textTheme: GoogleFonts.notoSansJpTextTheme(),
  // ...
)
```

### カスタムフォントを使用する場合

1. フォントファイルを`fonts/`フォルダに配置
2. `pubspec.yaml`に追加:
```yaml
flutter:
  fonts:
    - family: CustomFont
      fonts:
        - asset: fonts/CustomFont-Regular.ttf
        - asset: fonts/CustomFont-Bold.ttf
          weight: 700
```

3. `lib/main.dart`で使用:
```dart
theme: ThemeData(
  fontFamily: 'CustomFont',
)
```

## マップのカスタマイズ

### マップスタイルの変更

`lib/screens/map_screen.dart`でカスタムスタイルを適用:

```dart
GoogleMap(
  // ...
  onMapCreated: (controller) {
    _mapController = controller;
    // カスタムマップスタイルを適用
    _mapController?.setMapStyle(_mapStyle);
  },
)

// カスタムスタイル（例：夜モード）
String _mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#242f3e"}]
  },
  // ... 他のスタイル設定
]
''';
```

### マーカーアイコンのカスタマイズ

カスタム画像を使用する場合:

```dart
BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
  const ImageConfiguration(size: Size(48, 48)),
  'assets/images/marker_icon.png',
);

Marker(
  markerId: MarkerId(spot.id),
  position: LatLng(spot.latitude, spot.longitude),
  icon: customIcon,  // カスタムアイコンを使用
)
```

## PayPay寄付URLの設定

実際のPayPay URLを設定してください:

`lib/screens/donation_screen.dart`:
```dart
QrImageView(
  data: 'paypay://payment?link_id=YOUR_ACTUAL_LINK_ID',  // ここを変更
  // ...
)
```

## 銀行振込情報の更新

`lib/screens/donation_screen.dart`の`_showBankInfo`メソッドを編集:

```dart
_buildBankInfoRow('銀行名', '実際の銀行名'),
_buildBankInfoRow('支店名', '実際の支店名'),
_buildBankInfoRow('口座種別', '普通'),
_buildBankInfoRow('口座番号', '実際の口座番号'),
_buildBankInfoRow('口座名義', '実際の口座名義'),
```

## プッシュ通知の設定

### 通知トピックの変更

`lib/main.dart`:
```dart
// 全ユーザー向け通知
await notificationService.subscribeToTopic('all_users');

// 特定トピックの追加
await notificationService.subscribeToTopic('urgent_needs');  // 緊急募集
await notificationService.subscribeToTopic('events');        // イベント情報
```

### 通知の送信方法

Firebase Consoleから送信:
1. Cloud Messaging > 新しい通知
2. タイトルと本文を入力
3. トピック: `all_users`を選択
4. 送信

## デフォルト位置の変更

`lib/screens/map_screen.dart`の初期位置を変更:

```dart
initialCameraPosition: const CameraPosition(
  target: LatLng(35.6762, 139.6503), // 東京の座標 → 実際の拠点に変更
  zoom: 12,
)
```

## ビルド設定

### バージョン番号の更新

`pubspec.yaml`:
```yaml
version: 1.0.0+1  # メジャー.マイナー.パッチ+ビルド番号
```

### アプリIDの変更

#### Android
`android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "com.futureseeds.future_seeds_app"  // 変更
    // ...
}
```

#### iOS
Xcodeで変更:
1. `ios/Runner.xcworkspace`を開く
2. General > Identity > Bundle Identifier を変更

## 本番環境への準備

### セキュリティチェックリスト

- [ ] Google Maps APIキーの本番用制限を設定
- [ ] Firebaseセキュリティルールを本番用に更新
- [ ] すべてのプレースホルダーURL/データを実際の値に置き換え
- [ ] デバッグログの無効化
- [ ] ProGuard/R8の設定（Android）
- [ ] Bitcodeの有効化（iOS）

### リリースビルド

```bash
# Android
flutter build appbundle --release

# iOS
flutter build ios --release
```

## パフォーマンス最適化

### 画像の最適化
- WebP形式の使用を検討
- 適切な解像度の画像を使用
- キャッシュの活用

### ビルドサイズの削減
```bash
flutter build apk --split-per-abi  # Android: ABIごとに分割
```

## アクセシビリティ

### セマンティクスの追加
```dart
Semantics(
  label: 'スポット名',
  hint: 'タップして詳細を表示',
  child: Widget(),
)
```

### テキストサイズの対応
```dart
Text(
  'テキスト',
  style: TextStyle(fontSize: 16),
  textScaleFactor: 1.0,  // ユーザー設定に応じて調整
)
```

## デバッグツール

### Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### ログ出力
```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  debugPrint('デバッグ情報');
}
```

---

以上で基本的なカスタマイズが完了です。
詳しい設定については、各パッケージの公式ドキュメントを参照してください。
