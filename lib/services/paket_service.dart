import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/paket_bulanan.dart';

class PaketService {
  static const String baseUrl = 'https://e18c87dbbcc7.ngrok-free.app/api/paket-bulanan';

  static Future<List<PaketBulanan>> getMenuItems() async {
    final response = await http.get(Uri.parse(baseUrl));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => PaketBulanan.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load paket bulanan');
    }
  }

  static Future<PaketBulanan?> getMenuItemById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    
    if (response.statusCode == 200) {
      return PaketBulanan.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }
}
