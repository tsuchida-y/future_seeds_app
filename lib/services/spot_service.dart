import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/spot.dart';

class SpotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Spot>> getSpots() {
    return _firestore.collection('spots').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Spot.fromJson(data);
      }).toList();
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
