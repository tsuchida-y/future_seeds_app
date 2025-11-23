# Future Seeds アプリ セットアップガイド

このガイドでは、Future Seedsアプリの初期セットアップ手順を説明します。

## 目次
1. [開発環境の準備](#開発環境の準備)
2. [Firebaseプロジェクトの作成](#firebaseプロジェクトの作成)
3. [Google Maps APIの設定](#google-maps-apiの設定)
4. [依存パッケージのインストール](#依存パッケージのインストール)
5. [アプリの実行](#アプリの実行)

---

## 開発環境の準備

### 必要なツール
- **Flutter SDK**: 3.8.1以上
- **Dart SDK**: 3.0以上
- **Android Studio** (Android開発用)
- **Xcode** (iOS開発用、macOSのみ)
- **Git**

### Flutterのインストール確認
```bash
flutter --version
flutter doctor
```

`flutter doctor`を実行して、すべての項目にチェックマークがついていることを確認してください。

---

## Firebaseプロジェクトの作成

### 1. Firebaseコンソールでプロジェクトを作成

1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. 「プロジェクトを追加」をクリック
3. プロジェクト名: `future-seeds-app`（任意）
4. Google Analyticsは任意で有効化
5. プロジェクトを作成

### 2. Firestoreデータベースの作成

1. Firebaseコンソールで「Firestore Database」を選択
2. 「データベースを作成」をクリック
3. 「テストモードで開始」を選択（後でルールを更新）
4. ロケーション: `asia-northeast1` (東京)を推奨
5. 「有効にする」をクリック

### 3. Androidアプリの追加

1. Firebaseコンソールで「プロジェクトの設定」→「アプリを追加」→「Android」
2. Androidパッケージ名: `com.futureseeds.future_seeds_app`
   - `android/app/build.gradle`の`applicationId`を確認
3. `google-services.json`をダウンロード
4. ダウンロードしたファイルを`android/app/`に配置

### 4. iOSアプリの追加

1. Firebaseコンソールで「アプリを追加」→「iOS」
2. iOSバンドルID: `com.futureseeds.futureSeedsApp`
   - Xcode > Runner > General > Bundle Identifierを確認
3. `GoogleService-Info.plist`をダウンロード
4. Xcodeで`ios/Runner/`フォルダにドラッグ&ドロップ
   - 「Copy items if needed」をチェック

### 5. Firebase Cloud Messagingの有効化

1. Firebaseコンソールで「Cloud Messaging」を選択
2. 「始める」をクリック

#### iOS用の追加設定
1. Apple Developer Programに登録（要年会費）
2. Certificates, Identifiers & Profilesで認証キーを作成
3. Firebaseコンソールで認証キーをアップロード

### 6. Firestoreセキュリティルールの更新

プロジェクトルートの`firestore.rules`の内容を、Firebaseコンソールの「Firestore Database」→「ルール」タブに貼り付けて公開してください。

---

## Google Maps APIの設定

### 1. Google Cloud Platformでプロジェクトを作成

1. [Google Cloud Console](https://console.cloud.google.com/)にアクセス
2. 新しいプロジェクトを作成（またはFirebaseプロジェクトを選択）

### 2. Maps SDK for Android/iOSを有効化

1. 「APIとサービス」→「ライブラリ」
2. 「Maps SDK for Android」を検索して有効化
3. 「Maps SDK for iOS」を検索して有効化

### 3. APIキーの作成

1. 「APIとサービス」→「認証情報」
2. 「認証情報を作成」→「APIキー」
3. 作成されたAPIキーをコピー
4. 「キーを制限」をクリック
   - Android用: パッケージ名とSHA-1フィンガープリントを追加
   - iOS用: バンドルIDを追加

### 4. APIキーの設定

#### Android
`android/app/src/main/AndroidManifest.xml`の以下の部分を更新:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

#### iOS
`ios/Runner/AppDelegate.swift`の以下の部分を更新:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
```

---

## 依存パッケージのインストール

プロジェクトルートで以下のコマンドを実行:

```bash
# 依存関係の取得
flutter pub get

# コード生成（必要に応じて）
flutter pub run build_runner build

# iOS用（macOSのみ）
cd ios
pod install
cd ..
```

---

## アプリの実行

### エミュレータ/シミュレータの起動

#### Android
```bash
# 利用可能なエミュレータの一覧
flutter emulators

# エミュレータの起動
flutter emulators --launch <emulator_id>
```

#### iOS
```bash
# シミュレータを開く
open -a Simulator
```

### アプリの実行

```bash
# デバイス/エミュレータの確認
flutter devices

# アプリの実行
flutter run

# 特定のデバイスで実行
flutter run -d <device_id>

# リリースモードで実行
flutter run --release
```

---

## テストデータの追加

1. Firebase Console > Firestore Database
2. `SAMPLE_DATA.md`に記載されているサンプルデータを参考に、テストデータを追加してください

### spotsコレクション
- コレクション名: `spots`
- 各スポットのデータを追加

### newsコレクション
- コレクション名: `news`
- お知らせデータを追加

---

## トラブルシューティング

### Google Maps が表示されない
- APIキーが正しく設定されているか確認
- Google Cloud Consoleでbilling（課金）が有効になっているか確認
- Maps SDK for Android/iOSが有効化されているか確認

### Firebaseに接続できない
- `google-services.json`（Android）が正しい場所に配置されているか確認
- `GoogleService-Info.plist`（iOS）がXcodeプロジェクトに追加されているか確認
- パッケージ名/バンドルIDが一致しているか確認

### ビルドエラー
```bash
# クリーンビルド
flutter clean
flutter pub get

# iOS
cd ios
pod deintegrate
pod install
cd ..
```

### 位置情報が取得できない
- AndroidManifest.xml / Info.plistにパーミッションが追加されているか確認
- 実機/エミュレータで位置情報の許可を与えているか確認

---

## 次のステップ

1. ✅ 開発環境のセットアップ完了
2. ✅ Firebaseプロジェクトの作成完了
3. ✅ Google Maps APIの設定完了
4. ⬜ テストデータの追加
5. ⬜ アプリのカスタマイズ
6. ⬜ 本番環境へのデプロイ

アプリが正常に動作したら、`README.md`の「今後の機能追加予定」を参考に、追加機能の実装を検討してください。

---

## サポート

質問や問題が発生した場合は、以下にお問い合わせください：

- Email: dev@future-seeds.example.com
- GitHub Issues: https://github.com/your-org/future_seeds_app/issues
