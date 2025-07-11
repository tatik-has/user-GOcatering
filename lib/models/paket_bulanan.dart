class PaketBulanan {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final List<String> menuDetails;
  final String category;

  PaketBulanan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.menuDetails,
    required this.category,
  });

  factory PaketBulanan.fromJson(Map<String, dynamic> json) {
    return PaketBulanan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      images: List<String>.from(json['images']),
      menuDetails: List<String>.from(json['menuDetails']),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'images': images,
      'menuDetails': menuDetails,
      'category': category,
    };
  }
}