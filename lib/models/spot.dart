enum SpotType {
  communityFridge,
  foodCollectionBox,
  donationBox,
}

class Spot {
  final String id;
  final String name;
  final SpotType type;
  final double latitude;
  final double longitude;
  final String address;
  final String openingHours;
  final List<String> neededItems;
  final String? imageUrl;
  final String? description;

  Spot({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.openingHours,
    required this.neededItems,
    this.imageUrl,
    this.description,
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['id'] as String,
      name: json['name'] as String,
      type: SpotType.values.firstWhere(
        (e) => e.toString() == 'SpotType.${json['type']}',
      ),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      openingHours: json['openingHours'] as String,
      neededItems: List<String>.from(json['neededItems'] as List),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'openingHours': openingHours,
      'neededItems': neededItems,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  String get typeLabel {
    switch (type) {
      case SpotType.communityFridge:
        return 'みんなの公共冷蔵庫';
      case SpotType.foodCollectionBox:
        return '食品回収ボックス';
      case SpotType.donationBox:
        return '募金箱';
    }
  }
}
