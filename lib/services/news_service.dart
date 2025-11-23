import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news.dart';

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<News>> getNews() {
    return _firestore
        .collection('news')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return News.fromJson(data);
      }).toList();
    });
  }

  Future<News?> getNewsById(String id) async {
    final doc = await _firestore.collection('news').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return News.fromJson(data);
  }

  // 管理者用メソッド
  Future<void> addNews(News news) async {
    await _firestore.collection('news').add(news.toJson());
  }

  Future<void> updateNews(News news) async {
    await _firestore.collection('news').doc(news.id).update(news.toJson());
  }

  Future<void> deleteNews(String id) async {
    await _firestore.collection('news').doc(id).delete();
  }
}
