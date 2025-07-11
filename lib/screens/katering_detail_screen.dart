import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/katering_model.dart';
import '../services/katering_service.dart';
import '../utils/constants.dart';

class KateringDetailScreen extends StatefulWidget {
  final int id;

  const KateringDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<KateringDetailScreen> createState() => _KateringDetailScreenState();
}

class _KateringDetailScreenState extends State<KateringDetailScreen> {
  Katering? katering;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadKateringDetail();
  }

  Future<void> loadKateringDetail() async {
    try {
      final item = await KateringService.fetchKateringDetail(widget.id);
      setState(() {
        katering = item;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat detail katering')),
      );
    }
  }

  void _showOrderDialog() {
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final requestController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Konfirmasi Pesanan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 13, 184, 19),
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Masukkan no hp:',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 0, 9, 0),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: requestController,
                    decoration: const InputDecoration(
                      labelText: 'Masukkan request anda :',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (phoneController.text.isEmpty ||
                          addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nomor HP dan alamat wajib diisi'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      await _submitOrder(
                        phoneController.text,
                        addressController.text,
                        requestController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Pesan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _submitOrder(String phone, String address, String note) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final orderData = {
      'customer_phone': phone,
      'delivery_address': address,
      'request_note': note,
      'items': [
        {
          'menu_id': katering!.id,
          'menu_name': katering!.nama,
          'quantity': 1,
          'price': katering!.harga,
        },
      ],
      'total_amount': katering!.harga,
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/pesanan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Sukses'),
                content: const Text('Pesanan berhasil dikirim!'),
                actions: [
                  TextButton(
                    onPressed:
                        () => Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        ),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } else {
        throw Exception('Gagal mengirim pesanan: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        title: const Text('Detail Katering'),
        backgroundColor: const Color.fromRGBO(94, 143, 45, 1),
        foregroundColor: const Color.fromRGBO(245, 245, 245, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(245, 245, 245, 1)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color.fromRGBO(245, 245, 245, 1)),
            onPressed: () {
              // Tambahkan fungsi favorit di sini
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : katering == null
              ? const Center(child: Text('Katering tidak ditemukan'))
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                        color: Colors.grey,
                      ),
                      child:
                          katering!.gambar.isNotEmpty
                              ? Image.network(
                                katering!.gambar,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Center(
                                          child: Icon(
                                            Icons.restaurant,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                              )
                              : const Center(
                                child: Icon(
                                  Icons.restaurant,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            katering!.nama,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            katering!.deskripsi,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Rp${katering!.harga}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${katering!.rating}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _showOrderDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(94, 143, 45, 1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Pesan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
