class PriceListModel {
  final String title;
  final double price;
  final String description;
  final bool isActive;

  PriceListModel({
    required this.title,
    required this.price,
    required this.description,
    required this.isActive,
  });

  factory PriceListModel.fromJson(Map<String, dynamic> json) {
    return PriceListModel(
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'is_active': isActive,
    };
  }
}