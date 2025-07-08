// lib/services/order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class OrderService {
  static const String baseUrl = 'http://192.168.0.102:8000/api';
  
  // Ganti dengan URL API Anda
  static Future<List<OrderModel>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          // Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data pesanan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Mock data untuk testing - hapus ketika sudah terhubung dengan API
  static Future<List<OrderModel>> getMockOrders() async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi delay API
    
    return [
      OrderModel(
        id: 1,
        type: 'Paket Bulanan A',
        date: '17 mei 2025',
        expiry: '17 mei 2025',
        price: 400000,
        status: 'completed',
      ),
      OrderModel(
        id: 2,
        type: 'Menu harian',
        date: '5 April 2025',
        price: 12000,
        status: 'completed',
        details: {
          'rendang': 4,
          'ayam_gulai': 4,
          'gulai_tambuih': 4,
        },
      ),
      OrderModel(
        id: 3,
        type: 'Menu harian',
        date: '3 April 2025',
        price: 18000,
        status: 'completed',
        details: {
          'rendang': 6000,
          'ayam_gulai': 6000,
          'gulai_tambuih': 6000,
        },
      ),
    ];
  }
}
