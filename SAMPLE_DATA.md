# Firebaseサンプルデータ

このファイルには、アプリのテスト用サンプルデータを記載しています。
Firebase Consoleから手動で追加するか、スクリプトで一括インポートしてください。

## spotsコレクションのサンプルデータ

### ドキュメント1: コミュニティフリッジ（渋谷）
```json
{
  "name": "渋谷コミュニティフリッジ",
  "type": "communityFridge",
  "latitude": 35.6617,
  "longitude": 139.7040,
  "address": "東京都渋谷区○○1-2-3",
  "openingHours": "24時間利用可能",
  "neededItems": ["お米", "缶詰", "レトルト食品", "インスタント麺"],
  "imageUrl": "https://example.com/images/fridge1.jpg",
  "description": "渋谷駅から徒歩5分。いつでもご自由にお取りいただけます。"
}
```

### ドキュメント2: 食品回収ボックス（新宿）
```json
{
  "name": "新宿食品回収ボックス",
  "type": "foodCollectionBox",
  "latitude": 35.6895,
  "longitude": 139.6917,
  "address": "東京都新宿区○○2-3-4",
  "openingHours": "平日 9:00-18:00",
  "neededItems": ["調味料", "お菓子", "飲料", "缶詰"],
  "imageUrl": "https://example.com/images/box1.jpg",
  "description": "賞味期限が1ヶ月以上あるものをお願いします。"
}
```

### ドキュメント3: 募金箱（池袋）
```json
{
  "name": "池袋募金箱（カフェA）",
  "type": "donationBox",
  "latitude": 35.7295,
  "longitude": 139.7109,
  "address": "東京都豊島区○○3-4-5 カフェA店内",
  "openingHours": "営業時間内（10:00-20:00）",
  "neededItems": [],
  "imageUrl": "https://example.com/images/donation1.jpg",
  "description": "カフェ店内に設置しております。ご支援ありがとうございます。"
}
```

## newsコレクションのサンプルデータ

### ドキュメント1: 緊急募集
```json
{
  "title": "お米が不足しています！",
  "content": "現在、コミュニティフリッジのお米が大幅に不足しております。ご家庭で余っているお米がございましたら、ぜひご寄付をお願いいたします。少量でも大変助かります。",
  "publishedAt": "2025-11-19T10:00:00.000Z",
  "imageUrl": "https://example.com/images/rice.jpg",
  "isUrgent": true,
  "neededItems": ["お米", "無洗米"]
}
```

### ドキュメント2: 活動報告
```json
{
  "title": "10月の活動報告",
  "content": "10月は延べ150世帯の方々にご利用いただきました。皆さまからのご支援により、多くの方々に食料をお届けすることができました。心より感謝申し上げます。\n\n【配布実績】\n・お米: 120kg\n・缶詰: 300個\n・レトルト食品: 200個\n・その他: 多数",
  "publishedAt": "2025-11-01T09:00:00.000Z",
  "imageUrl": "https://example.com/images/report-oct.jpg",
  "isUrgent": false,
  "neededItems": null
}
```

### ドキュメント3: イベント告知
```json
{
  "title": "フードドライブイベント開催のお知らせ",
  "content": "12月10日(日)に渋谷区民会館にてフードドライブイベントを開催します。食品の寄付だけでなく、活動紹介や子どもたちの作品展示も行います。ぜひお越しください。\n\n日時: 12月10日(日) 10:00-16:00\n場所: 渋谷区民会館",
  "publishedAt": "2025-11-15T14:00:00.000Z",
  "imageUrl": "https://example.com/images/event.jpg",
  "isUrgent": false,
  "neededItems": ["缶詰", "レトルト食品", "お菓子"]
}
```

## データのインポート方法

### Firebase Consoleから手動で追加
1. Firebase Console (https://console.firebase.google.com/) にアクセス
2. プロジェクトを選択
3. Firestore Database を開く
4. コレクション（spots または news）を選択
5. 「ドキュメントを追加」をクリック
6. 上記JSONデータをコピーして貼り付け

### コマンドラインツール（Firebase CLI）を使用
```bash
# Firebase CLIをインストール（未インストールの場合）
npm install -g firebase-tools

# Firebaseにログイン
firebase login

# プロジェクトを初期化
firebase init firestore

# データをインポート（要スクリプト作成）
# 注: データインポート用のスクリプトを別途作成する必要があります
```

## 注意事項

- `imageUrl`のURLは実際の画像URLに置き換えてください
- 住所や位置情報は実際のスポット情報に更新してください
- `publishedAt`は適切な日時に変更してください
- テストデータは本番環境にデプロイする前に削除または更新してください
