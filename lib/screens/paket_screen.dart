import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/paket_bulanan.dart';
import '../services/paket_service.dart';
import '../utils/constants.dart';

class PaketDetailScreen extends StatefulWidget {
  final String menuId;

  const PaketDetailScreen({Key? key, required this.menuId}) : super(key: key);

  @override
  State<PaketDetailScreen> createState() => _PaketDetailScreenState();
}

class _PaketDetailScreenState extends State<PaketDetailScreen> {
  PaketBulanan? menuItem;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMenuDetail();
  }

  Future<void> loadMenuDetail() async {
    try {
      final item = await PaketService.getMenuItemById(widget.menuId);
      setState(() {
        menuItem = item;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail menu')),
      );
    }
  }

  void _showOrderDialog() {
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final requestController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'No HP'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Alamat'),
            ),
            TextField(
              controller: requestController,
              decoration: InputDecoration(labelText: 'Catatan (opsional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (phoneController.text.isEmpty || addressController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nomor dan alamat wajib diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              await _submitOrder(phoneController.text, addressController.text, requestController.text);
            },
            child: Text('Kirim'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrder(String phone, String address, String note) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak ditemukan'), backgroundColor: Colors.red),
      );
      return;
    }

    final orderData = {
      'customer_phone': phone,
      'delivery_address': address,
      'request_note': note,
      'items': [
        {
          'menu_id': menuItem!.id,
          'menu_name': menuItem!.name,
          'quantity': 1,
          'price': menuItem!.price,
        },
      ],
      'total_amount': menuItem!.price,
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
          builder: (context) => AlertDialog(
            title: Text('Sukses'),
            content: Text('Pesanan berhasil dikirim!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Gagal mengirim pesanan: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        title: Text('Menu Paketan'),
        backgroundColor: const Color.fromRGBO(94, 143, 45, 1),
        foregroundColor: const Color.fromRGBO(245, 245, 245, 1),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color.fromRGBO(245, 245, 245, 1)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: const Color.fromRGBO(245, 245, 245, 1)),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : menuItem == null
              ? Center(child: Text('Menu tidak ditemukan'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: menuItem!.images.isNotEmpty
                            ? Image.network(
                                menuItem!.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Icon(Icons.restaurant, size: 50, color: Colors.grey));
                                },
                              )
                            : Center(child: Icon(Icons.restaurant, size: 50, color: Colors.grey)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(menuItem!.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(menuItem!.category, style: TextStyle(color: Colors.grey[600])),
                            SizedBox(height: 16),
                            Text('Rp${menuItem!.price.toInt()}',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber),
                                SizedBox(width: 4),
                                Text('${menuItem!.rating} (${menuItem!.reviewCount}+)'),
                                Spacer(),
                                Text('See Review', style: TextStyle(color: Colors.orange)),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(menuItem!.description, style: TextStyle(height: 1.5)),
                            SizedBox(height: 24),
                            Text('Menu hari:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                            ...menuItem!.menuDetails.asMap().entries.map((entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text('${entry.key + 1}. ${entry.value}'),
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _showOrderDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(94, 143, 45, 1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Pesan', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
