import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/katering_model.dart';
import '../utils/constants.dart';

class KateringService {
  static Future<List<Katering>> fetchKatering() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/katering'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List dataList = jsonData['data']; // Laravel API biasanya struktur: { data: [ ... ] }
      return dataList.map((item) => Katering.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat daftar katering');
    }
  }

  static Future<Katering> fetchKateringDetail(int id) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/katering/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final data = jsonData['data'] ?? jsonData; // handle jika API mengemas dalam `data` atau tidak
      return Katering.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail katering');
    }
  }
}
