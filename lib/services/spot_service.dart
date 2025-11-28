import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/spot.dart';

class SpotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Spot>> getSpots() {
    debugPrint('SpotService: Firestoreの"spots"コレクションをリスニング開始');
    
    // Firestoreのspotsコレクションのストリームを返す
    return _firestore.collection('spots').snapshots().map((snapshot) {
      debugPrint('SpotService: Firestoreから${snapshot.docs.length}件のドキュメント受信');
      
      final spots = <Spot>[];
      
      // 各ドキュメントを処理
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        debugPrint('SpotService: ドキュメント${i + 1}/${snapshot.docs.length}を処理中...');
        debugPrint('  ドキュメントID: ${doc.id}');
        
        try {
          final data = doc.data();
          debugPrint('  データ内容: $data');
          
          // IDを追加
          data['id'] = doc.id;
          
          // Spotモデルに変換
          debugPrint('  Spot.fromJsonを実行中...');
          final spot = Spot.fromJson(data);
          
          debugPrint('  変換成功: ${spot.name} (タイプ: ${spot.type})');
          spots.add(spot);
          
        } catch (e, stackTrace) {
          debugPrint('  エラー: ドキュメント${doc.id}の変換に失敗');
          debugPrint('  エラー詳細: $e');
          debugPrint('  スタックトレース: $stackTrace');
          debugPrint('  このドキュメントはスキップします');
        }
      }
      
      debugPrint('SpotService: 処理完了 - ${spots.length}個のスポットを返却');
      return spots;
    });
  }

  Future<Spot?> getSpot(String id) async {
    final doc = await _firestore.collection('spots').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return Spot.fromJson(data);
  }

  // 管理者用メソッド
  Future<void> addSpot(Spot spot) async {
    await _firestore.collection('spots').add(spot.toJson());
  }

  Future<void> updateSpot(Spot spot) async {
    await _firestore.collection('spots').doc(spot.id).update(spot.toJson());
  }

  Future<void> deleteSpot(String id) async {
    await _firestore.collection('spots').doc(id).delete();
  }
}
