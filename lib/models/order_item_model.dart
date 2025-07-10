class OrderItem {
  final String menuId;
  final String menuName;
  final int quantity;
  final double price;
  final String image;

  OrderItem({
    required this.menuId,
    required this.menuName,
    required this.quantity,
    required this.price,
    required this.image,
  });

  Map<String, dynamic> toJson() {
  return {
    'menu_id': menuId,
    'menu_name': menuName, // <-- ini penting jika backend tidak ambil relasi
    'quantity': quantity,
    'price': price,
    'image': image,
  };
}

}