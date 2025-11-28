# Google Maps表示とピン表示フロー

## 📱 アプリ全体の流れ

### 1. アプリ起動時の初期化
```
main() 関数実行
    ↓
Flutter初期化 (WidgetsFlutterBinding.ensureInitialized())
    ↓
.envファイル読み込み (Google Maps APIキー取得)
    ↓
Firebase初期化 (Firestore接続準備)
    ↓
プッシュ通知初期化
    ↓
FutureSeedsApp起動 (MaterialApp)
    ↓
MainScreen表示 (BottomNavigationBar)
    ↓
MapScreen初期表示 (初期状態：マーカー0個)
```

## 🗺️ MapScreen内部の詳細フロー

### 2. MapScreen初期化プロセス
```
MapScreen.initState() 実行
    ↓
├─ _requestLocationPermission() 並行実行
│     ↓
│  位置情報パーミッション要求
│     ↓ (許可された場合)
│  _getCurrentLocation() 実行
│     ↓
│  Geolocator.getCurrentPosition() 
│     ↓
│  現在地取得成功 → カメラ移動
│
└─ _loadSpots() 並行実行
      ↓
   SpotService.getSpots() 開始
      ↓
   Firestoreリスニング開始
```

### 3. Firestoreからのデータ取得フロー
```
SpotService.getSpots() 内部処理:

Firestore.collection('spots').snapshots() 開始
    ↓
Firebase接続・クエリ実行
    ↓
ドキュメント一覧取得 (例: 3件のスポット)
    ↓
各ドキュメントを順次処理:
    ├─ ドキュメント1: spot_渋谷フリッジ
    │     ↓
    │  JSON → Spot.fromJson() 変換
    │     ↓
    │  Spotオブジェクト作成成功
    │
    ├─ ドキュメント2: spot_新宿ボックス  
    │     ↓ (同様の処理)
    │  Spotオブジェクト作成成功
    │
    └─ ドキュメント3: spot_池袋募金箱
          ↓ (同様の処理)
       Spotオブジェクト作成成功
    ↓
List<Spot> として返却 (3個のSpotオブジェクト)
    ↓
MapScreen._loadSpots()のlistenコールバック実行
```

### 4. マーカー生成とGoogle Maps表示フロー
```
SpotServiceから List<Spot> 受信
    ↓
MapScreen.setState() 実行
    ├─ _spots = spots (受信したデータを保存)
    └─ _updateMarkers() 実行
          ↓
       既存マーカーをクリア (_markers.clear())
          ↓
       各Spotに対してMarkerを生成:
          ├─ Spot1 → Marker1 (緯度35.6617, 経度139.7040, 青アイコン)
          ├─ Spot2 → Marker2 (緯度35.6895, 経度139.6917, 緑アイコン) 
          └─ Spot3 → Marker3 (緯度35.7295, 経度139.7109, オレンジアイコン)
          ↓
       _markers Setに追加完了 (3個のマーカー)
          ↓
       setState()によりbuild()メソッド再実行
          ↓
       GoogleMapウィジェット再構築
          ↓
       markers: _markers でマーカー表示
          ↓
🎉 **地図上にピンが表示される！**
```

## 🔧 重要なコンポーネント

### A. データモデル (Spot)
```dart
class Spot {
  final String id;           // Firestore ドキュメントID
  final String name;         // スポット名
  final SpotType type;       // タイプ（冷蔵庫/回収ボックス/募金箱）
  final double latitude;     // 緯度 (Google Mapsで使用)
  final double longitude;    // 経度 (Google Mapsで使用)
  final String address;      // 住所
  // ... その他のプロパティ
}
```

### B. Firestoreデータ構造
```json
// Collection: "spots"
// Document: "spot1_shibuya"
{
  "name": "渋谷コミュニティフリッジ",
  "type": "communityFridge",
  "latitude": 35.6617,
  "longitude": 139.7040,
  "address": "東京都渋谷区○○1-2-3",
  "openingHours": "24時間利用可能",
  "neededItems": ["お米", "缶詰", "レトルト食品"]
}
```

### C. Marker生成ロジック
```dart
Marker(
  markerId: MarkerId(spot.id),                    // 一意のID
  position: LatLng(spot.latitude, spot.longitude), // 地図上の位置
  infoWindow: InfoWindow(                         // タップ時の情報表示
    title: spot.name,
    snippet: spot.typeLabel,
  ),
  icon: _getMarkerIcon(spot.type),               // タイプ別アイコン色
)
```

## ⏱️ 実行タイミング

| タイミング | 処理内容 | 所要時間(目安) |
|-----------|---------|---------------|
| アプリ起動 | Firebase初期化 | ~1秒 |
| MapScreen表示 | 初期レンダリング | ~0.5秒 |
| 位置情報取得 | GPS/ネットワーク位置 | 1-5秒 |
| Firestore接続 | データ取得 | 1-3秒 |
| マーカー生成 | UI更新 | ~0.1秒 |

## 🚫 失敗ケースと対処

### 1. Google Maps APIエラー
```
症状: 地図が灰色で表示される
原因: APIキーが無効・制限設定ミス
対処: Google Cloud Consoleで設定確認
```

### 2. Firestoreデータ取得失敗  
```
症状: マーカーが表示されない
原因: ネットワーク接続・Firebase設定
対処: コンソールでエラーログ確認
```

### 3. 位置情報パーミッション拒否
```
症状: 現在地ボタンが機能しない
原因: ユーザーがパーミッションを拒否
対処: 設定から手動で許可
```

## 📊 データフロー図

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Firestore │────│ SpotService │────│  MapScreen  │
│  (spots)    │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       │ snapshots()       │ getSpots()        │ setState()
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ QuerySnapshot│────│ List<Spot>  │────│Set<Marker>  │
│             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
                                             │
                                             ▼
                                    ┌─────────────┐
                                    │ GoogleMap   │
                                    │ Widget      │
                                    └─────────────┘
```

## 🔍 デバッグポイント

アプリが正常に動作しない場合、以下の順番でログを確認：

1. **アプリ起動ログ**: Firebase初期化成功？
2. **MapScreen初期化ログ**: initState実行？  
3. **SpotService接続ログ**: Firestore接続成功？
4. **データ受信ログ**: スポットデータ取得できた？
5. **マーカー生成ログ**: Markerオブジェクト作成成功？
6. **GoogleMap作成ログ**: マップウィジェット生成成功？

各段階でログが出力されれば、その段階は正常に動作しています。

---

このフローを理解することで、Google Mapsとピン表示機能のトラブルシューティングが効率的に行えます。


## 🚀 URL Launcher方式PayPay決済 実装ガイド
### 実装タスク一覧
Phase 1: 基盤準備 (30分)
 Task 1-1: 依存関係の追加
 Task 1-2: Android権限設定
 Task 1-3: iOS設定
Phase 2: PayPayサービス実装 (1時間)
 Task 2-1: PayPayService作成
 Task 2-2: URL生成ロジック
 Task 2-3: アプリ起動チェック機能
Phase 3: UI実装 (2時間)
 Task 3-1: DonationScreen修正
 Task 3-2: 金額選択UI
 Task 3-3: PayPayボタン実装
Phase 4: エラーハンドリング (1時間)
 Task 4-1: PayPayアプリ未インストール対応
 Task 4-2: エラーダイアログ実装
 Task 4-3: ユーザーガイダンス
Phase 5: テスト・調整 (1時間)
 Task 5-1: 実機テスト
 Task 5-2: UI調整
 Task 5-3: ログ追加