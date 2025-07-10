class OrderModel {
  final int orderId;
  final String customerName;
  final String itemsSummary;
  final String itemsQuantities;
  final List<dynamic> detailedItems;
  final String? requestNote;
  final int totalAmount;
  final String orderDate;
  final String deliveryAddress;
  final String status;

  OrderModel({
    required this.orderId,
    required this.customerName,
    required this.itemsSummary,
    required this.itemsQuantities,
    required this.detailedItems,
    this.requestNote,
    required this.totalAmount,
    required this.orderDate,
    required this.deliveryAddress,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      itemsSummary: json['items_summary'] ?? '',
      itemsQuantities: json['items_quantities'] ?? '',
      detailedItems: json['detailed_items'] ?? [],
      requestNote: json['request_note'],
      totalAmount: (json['total_amount'] as num).toInt(),
      orderDate: json['order_date'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}
