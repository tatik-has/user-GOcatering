//menu_service.dart
// import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item_model.dart';
import '../models/order_item_model.dart';

class MenuService {
  static const String baseUrl = 'http://192.168.0.102:8000/api'; // Ganti dengan URL API Anda
  
  static Future<List<MenuItem>> getMenuItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menu'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> menuList = data['data'] ?? data;
        
        return menuList.map((item) => MenuItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load menu items');
      }
    } catch (e) {
      throw Exception('Error fetching menu: $e');
    }
  }
  
  static Future<bool> submitOrder(List<OrderItem> orderItems) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/order'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'orders': orderItems.map((item) => item.toJson()).toList(),
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error submitting order: $e');
      return false;
    }
  }
}