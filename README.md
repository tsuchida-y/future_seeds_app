# Future Seeds 寄付・支援プラットフォームアプリ

特定非営利活動法人Future Seedsの寄付・支援活動をサポートするモバイルアプリケーションです。

## 概要

Future Seedsは、不登校生の居場所作りや、ひとり親家庭等への食料支援（コミュニティフリッジ）を行っている非営利団体です。このアプリは、支援者と支援を必要とする方々を繋ぐプラットフォームとして開発されました。

## 主な機能

### 1. マップ機能
- コミュニティフリッジ（公共冷蔵庫）の位置を地図上に表示
- 食品回収ボックスの場所を表示
- 募金箱設置場所の表示
- 各スポットの詳細情報（住所、受付時間、募集している食品）
- Google Mapsと連携したルート案内

### 2. お知らせ・活動報告
- 運営からの最新情報の配信
- 不足している食品の緊急募集通知
- 活動実績の報告
- プッシュ通知によるリアルタイム通知

### 3. オンライン寄付
- PayPay等のキャッシュレス決済での募金
- QRコードによる簡単な寄付手続き
- 銀行振込情報の確認
- 外部サイトへの誘導（クレジットカード寄付）

## 技術スタック

- **フレームワーク**: Flutter 3.8.1+
- **言語**: Dart
- **地図**: Google Maps Flutter
- **バックエンド**: Firebase (Firestore, Cloud Messaging)
- **主要パッケージ**:
  - `google_maps_flutter`: 地図表示
  - `firebase_core`, `cloud_firestore`: データベース
  - `firebase_messaging`: プッシュ通知
  - `geolocator`: 位置情報取得
  - `url_launcher`: 外部リンク
  - `qr_flutter`: QRコード表示
  - `provider`: 状態管理

## セットアップ

### 前提条件

- Flutter SDK 3.8.1以上
- Dart SDK
- Android Studio / Xcode（プラットフォームに応じて）
- Firebaseプロジェクト

### インストール手順

1. リポジトリのクローン
```bash
git clone https://github.com/your-org/future_seeds_app.git
cd future_seeds_app
```

2. 依存関係のインストール
```bash
flutter pub get
```

3. Firebaseの設定

#### Android
- `android/app/google-services.json` を配置

#### iOS
- `ios/Runner/GoogleService-Info.plist` を配置

4. Google Maps APIキーの設定

#### Android
`android/app/src/main/AndroidManifest.xml` に以下を追加:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

#### iOS
`ios/Runner/AppDelegate.swift` に以下を追加:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

5. アプリの実行
```bash
flutter run
```

## Firebase設定

### Firestoreコレクション構造

#### spots コレクション
```json
{
  "name": "スポット名",
  "type": "communityFridge | foodCollectionBox | donationBox",
  "latitude": 35.6762,
  "longitude": 139.6503,
  "address": "住所",
  "openingHours": "受付時間",
  "neededItems": ["お米", "缶詰", "レトルト食品"],
  "imageUrl": "画像URL（オプション）",
  "description": "説明（オプション）"
}
```

#### news コレクション
```json
{
  "title": "お知らせタイトル",
  "content": "本文",
  "publishedAt": "2025-11-19T00:00:00.000Z",
  "imageUrl": "画像URL（オプション）",
  "isUrgent": false,
  "neededItems": ["募集している食品リスト"]
}
```

### Cloud Messaging設定

プッシュ通知を使用するには、Firebase Consoleで以下を設定してください：

1. Firebase Console > Cloud Messaging
2. Apple Push Notification (iOS用) または Firebase Cloud Messaging (Android用) の設定
3. トピック「all_users」を使用してすべてのユーザーに通知を送信

## ビルド

### Android
```bash
flutter build apk --release
# または
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 管理者機能

現在、スポットやニュースの管理は直接Firestoreコンソールから行います。将来的には専用の管理画面（CMS）を実装予定です。

### データの追加方法

1. Firebase Console > Firestore Database
2. 該当するコレクション（spots / news）を選択
3. 「ドキュメントを追加」から新規データを作成

## 注意事項

- Google Maps APIキーは必ず環境変数やセキュアな方法で管理してください
- PayPay等の決済サービスのリンクは実際のURLに置き換えてください
- 銀行振込情報は正確な情報に更新してください
- 本番環境では、Firebaseのセキュリティルールを適切に設定してください

## ライセンス

MIT License

## 問い合わせ

特定非営利活動法人Future Seeds
- ウェブサイト: [https://future-seeds.example.com](https://future-seeds.example.com)
- メール: contact@future-seeds.example.com

---

## 今後の機能追加予定

- [ ] 管理者用CMS画面
- [ ] 寄付履歴機能
- [ ] ユーザー認証・マイページ
- [ ] 多言語対応
- [ ] アクセシビリティ機能の強化
- [ ] オフライン対応

