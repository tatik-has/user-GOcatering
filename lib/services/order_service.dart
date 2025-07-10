import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class OrderService {
  static const String baseUrl = 'http://192.168.0.107:8000/api';

  static Future<List<OrderModel>> getOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pesanan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> ordersJson = responseData['data'];

        return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data pesanan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
