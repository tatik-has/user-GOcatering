// lib/widgets/order_item_widget.dart
import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;

  const OrderItemWidget({Key? key, required this.order}) : super(key: key);

  String formatPrice(int price) {
    return 'Rp${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.type,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                formatPrice(order.price),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (order.type == 'Paket Bulanan A') ...[
            Text(
              'Mulai berlaku pesanan: ${order.date}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Masa aktif sampai: ${order.expiry}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ] else ...[
            Text(
              'Dipesan pada: ${order.date}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (order.details != null) ...[
              SizedBox(height: 8),
              ...order.details!.entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${entry.key.replaceAll('_', ' ')} ${entry.value is int && entry.value < 100 ? '${entry.value}x' : entry.value.toString()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ],
      ),
    );
  }
}