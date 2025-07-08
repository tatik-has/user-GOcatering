class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['image'] ?? '',
      category: json['category'] ?? '',
    );
  }
}