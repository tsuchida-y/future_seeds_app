class News {
  final String id;
  final String title;
  final String content;
  final DateTime publishedAt;
  final String? imageUrl;
  final bool isUrgent;
  final List<String>? neededItems;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    this.imageUrl,
    this.isUrgent = false,
    this.neededItems,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
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
      'publishedAt': publishedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'isUrgent': isUrgent,
      'neededItems': neededItems,
    };
  }
}
