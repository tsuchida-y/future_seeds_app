import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  final String id;
  final String title;
  final String content;
  final DateTime publishedAt;//公開日時
  final bool isUrgent;
  final List<String>? neededItems;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    this.isUrgent = false,
    this.neededItems,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    DateTime publishedDate;

    publishedDate = (json['publishedAt'] as Timestamp).toDate();

    return News(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      publishedAt: publishedDate,
      isUrgent: json['isUrgent'] as bool? ?? false,
      neededItems: json['neededItems'] != null
          ? List<String>.from(json['neededItems'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'isUrgent': isUrgent,
      'neededItems': neededItems,
    };
  }
}