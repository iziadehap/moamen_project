class PriceListModel {
  final String id;
  final String title;
  final double price;
  final String description;
  final bool isActive;
  final List<String> photoUrls;

  PriceListModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.photoUrls,
    required this.isActive,
  });

  factory PriceListModel.fromJson(Map<String, dynamic> json) {
    return PriceListModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      photoUrls: List<String>.from(json['photo_urls'] ?? []),
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'photo_urls': photoUrls,
      'is_active': isActive,
    };
  }
}
