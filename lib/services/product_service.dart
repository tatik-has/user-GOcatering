// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_models.dart';

class ProductService {
  static const String baseUrl = 'http://192.168.0.102:8000/api';
  
  static Future<Map<String, dynamic>> getMenu() async {
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
        
        // Handle different response structures
        List<dynamic> menuList;
        if (data is Map && data.containsKey('data')) {
          menuList = data['data'] ?? [];
        } else if (data is List) {
          menuList = data;
        } else {
          menuList = [];
        }
        
        // Convert to Menu objects with null safety
        List<Menu> menus = menuList.map((item) {
          if (item is Map<String, dynamic>) {
            return Menu.fromJson(item);
          }
          return Menu(
            id: '',
            nama: 'Unknown',
            deskripsi: '',
            harga: 'Rp 0',
            gambar: '',
            kategoriUtama: 'unknown',
            rating: '0.0',
          );
        }).toList();
        
        return {
          'success': true,
          'data': menus,
          'message': 'Menu loaded successfully'
        };
      } else {
        return {
          'success': false,
          'data': <Menu>[],
          'message': 'Failed to load menu: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': <Menu>[],
        'message': 'Error fetching menu: $e'
      };
    }
  }
}