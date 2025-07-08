// lib/models/order_model.dart
class OrderModel {
  final int id;
  final String type;
  final String date;
  final String? expiry;
  final int price;
  final String status;
  final Map<String, dynamic>? details;

  OrderModel({
    required this.id,
    required this.type,
    required this.date,
    this.expiry,
    required this.price,
    required this.status,
    this.details,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      type: json['type'],
      date: json['date'],
      expiry: json['expiry'],
      price: json['price'],
      status: json['status'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'date': date,
      'expiry': expiry,
      'price': price,
      'status': status,
      'details': details,
    };
  }
}
