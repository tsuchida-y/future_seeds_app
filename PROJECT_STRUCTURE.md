# Future Seeds アプリ プロジェクト構造

## ディレクトリ構造

```
future_seeds_app/
├── android/                      # Androidプラットフォーム固有のコード
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml  # パーミッション、Google Maps API設定
│   │   │   └── kotlin/...
│   │   └── build.gradle.kts
│   └── build.gradle.kts
│
├── ios/                          # iOSプラットフォーム固有のコード
│   ├── Runner/
│   │   ├── AppDelegate.swift    # Google Maps API設定
│   │   └── Info.plist           # パーミッション設定
│   └── Runner.xcodeproj/
│
├── lib/                          # Dartソースコード（メインコード）
│   ├── main.dart                # アプリのエントリーポイント
│   │
│   ├── models/                  # データモデル
│   │   ├── spot.dart           # スポット情報モデル
│   │   └── news.dart           # ニュース情報モデル
│   │
│   ├── screens/                # 画面（UI）
│   │   ├── map_screen.dart     # マップ画面
│   │   ├── news_screen.dart    # お知らせ・活動報告画面
│   │   └── donation_screen.dart # 寄付画面
│   │
│   └── services/               # ビジネスロジック・外部連携
│       ├── spot_service.dart   # スポット情報の取得・管理
│       ├── news_service.dart   # ニュース情報の取得・管理
│       └── notification_service.dart # プッシュ通知サービス
│
├── assets/                      # 静的リソース（画像、フォントなど）
│   └── images/                 # 画像ファイル
│
├── test/                        # テストコード
│   └── widget_test.dart
│
├── .gitignore                   # Git管理対象外ファイル
├── pubspec.yaml                # Flutter依存関係定義
├── README.md                   # プロジェクト概要
├── SETUP_GUIDE.md             # セットアップ手順
├── CUSTOMIZATION_GUIDE.md     # カスタマイズ方法
├── SAMPLE_DATA.md             # サンプルデータ
├── firestore.rules            # Firestoreセキュリティルール
└── .env.example               # 環境変数テンプレート
```

## 主要ファイルの説明

### アプリケーションコア

#### `lib/main.dart`
- アプリのエントリーポイント
- Firebase初期化
- テーマ設定
- ナビゲーション構造（BottomNavigationBar）

#### `lib/models/`
**データモデル層**
- `spot.dart`: スポット情報（冷蔵庫、回収ボックス、募金箱）
- `news.dart`: お知らせ・活動報告情報

#### `lib/screens/`
**UI層（画面）**
- `map_screen.dart`: Google Mapsを使用したスポット表示画面
- `news_screen.dart`: お知らせ一覧・詳細画面
- `donation_screen.dart`: オンライン寄付画面（PayPay、銀行振込、クレカ）

#### `lib/services/`
**ビジネスロジック層**
- `spot_service.dart`: Firestoreからスポット情報を取得・管理
- `news_service.dart`: Firestoreからニュース情報を取得・管理
- `notification_service.dart`: Firebase Cloud Messagingを使用したプッシュ通知

### 設定ファイル

#### `pubspec.yaml`
依存パッケージの定義:
- `google_maps_flutter`: マップ表示
- `firebase_core`, `cloud_firestore`: データベース
- `firebase_messaging`: プッシュ通知
- `geolocator`: 位置情報
- `url_launcher`: 外部リンク
- `qr_flutter`: QRコード表示
- `provider`: 状態管理

#### `android/app/src/main/AndroidManifest.xml`
Android固有の設定:
- 位置情報パーミッション
- インターネットパーミッション
- Google Maps APIキー

#### `ios/Runner/Info.plist`
iOS固有の設定:
- 位置情報利用理由の説明
- カメラ・フォトライブラリアクセス（将来の機能用）

#### `firestore.rules`
Firestoreセキュリティルール:
- 読み取り: すべてのユーザーに許可
- 書き込み: 管理者のみ（実装予定）

## データフロー

```
Firestore Database
    ↓
Services (spot_service.dart, news_service.dart)
    ↓
Models (spot.dart, news.dart)
    ↓
Screens (map_screen.dart, news_screen.dart)
    ↓
User Interface
```

## 状態管理

現在はシンプルな`setState()`を使用していますが、将来的には以下の実装を検討:

- **Provider**: グローバル状態管理
- **Riverpod**: より安全な状態管理
- **Bloc**: 複雑なビジネスロジック用

## 画面遷移

```
MainScreen (BottomNavigationBar)
    ├── MapScreen (index: 0)
    ├── NewsScreen (index: 1)
    └── DonationScreen (index: 2)
```

各画面はBottomNavigationBarで切り替え可能。

## 外部サービス連携

### Firebase
- **Firestore**: データ保存
- **Cloud Messaging**: プッシュ通知
- **Analytics**: 利用状況分析（オプション）

### Google Maps
- **Maps SDK**: 地図表示
- **Geocoding API**: 住所⇔座標変換（将来の機能）

### 決済・寄付
- **PayPay**: QRコード経由
- **銀行振込**: 情報表示のみ
- **外部サイト**: URL遷移

## セキュリティ考慮事項

1. **APIキーの管理**
   - `.gitignore`でAPIキーファイルを除外
   - 環境変数の使用を推奨

2. **Firestoreセキュリティルール**
   - 読み取り: 公開
   - 書き込み: 管理者のみ

3. **個人情報**
   - 現時点ではユーザー認証なし
   - 将来的にはFirebase Authenticationの導入を検討

## パフォーマンス最適化

1. **画像の最適化**
   - `cached_network_image`でキャッシュ
   - 適切なサイズの画像を使用

2. **データ取得**
   - Firestoreのリアルタイムリスナーを使用
   - 必要なデータのみ取得

3. **地図表示**
   - マーカーの数を制限
   - クラスタリング（将来の機能）

## テスト戦略

```
test/
├── unit/           # ユニットテスト（モデル、サービス）
├── widget/         # ウィジェットテスト（UI）
└── integration/    # 統合テスト（E2E）
```

## 今後の拡張予定

### 短期（1-3ヶ月）
- [ ] 管理者用CMS画面
- [ ] エラーハンドリングの強化
- [ ] オフライン対応

### 中期（3-6ヶ月）
- [ ] ユーザー認証（Firebase Auth）
- [ ] 寄付履歴機能
- [ ] マイページ

### 長期（6ヶ月以上）
- [ ] 多言語対応（i18n）
- [ ] アクセシビリティ強化
- [ ] Web版の開発

## 関連ドキュメント

- [README.md](README.md) - プロジェクト概要
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - セットアップ手順
- [CUSTOMIZATION_GUIDE.md](CUSTOMIZATION_GUIDE.md) - カスタマイズ方法
- [SAMPLE_DATA.md](SAMPLE_DATA.md) - テストデータ
